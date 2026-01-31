import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_cached_profile_avatar_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/refresh_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit(
    this._userContext,
    this._uploadProfileImage,
    this._clearProfileImage,
    this._getCachedProfileAvatar,
    this._refreshProfileAvatarCache,
    this._saveProfileAvatarCache,
    this._clearProfileAvatarCache,
  ) : super(ProfileImageState.initial());

  final UserContextService _userContext;
  final UploadProfileImageUseCase _uploadProfileImage;
  final ClearProfileImageUseCase _clearProfileImage;
  final GetCachedProfileAvatarUseCase _getCachedProfileAvatar;
  final RefreshProfileAvatarCacheUseCase _refreshProfileAvatarCache;
  final SaveProfileAvatarCacheUseCase _saveProfileAvatarCache;
  final ClearProfileAvatarCacheUseCase _clearProfileAvatarCache;

  Future<void>? _refreshFuture;
  String? _refreshKey;

  Future<void> upload({
    required Uint8List bytes,
    required String contentType,
    String? idempotencyKey,
  }) async {
    if (state.isUploading || state.isClearing) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.upload,
        failure: null,
      ),
    );

    final result = await _uploadProfileImage(
      UploadProfileImageRequestEntity(
        bytes: bytes,
        contentType: contentType,
        idempotencyKey: idempotencyKey,
      ),
    );

    await result.match(
      (failure) async {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ProfileImageStatus.failure,
            action: ProfileImageAction.upload,
            failure: failure,
          ),
        );
      },
      (user) async {
        final fileId = user.profile.profileImageFileId?.trim();
        if (fileId != null && fileId.isNotEmpty) {
          final saved = await _saveProfileAvatarCache(
            userId: user.id,
            profileImageFileId: fileId,
            bytes: bytes,
          );

          await saved.match((_) async {}, (entry) async {
            final filePath = entry?.filePath;
            if (filePath == null || filePath.isEmpty) return;
            await _evictFileImage(filePath);
          });
        }

        if (isClosed) return;
        emit(
          state.copyWith(
            status: ProfileImageStatus.success,
            action: ProfileImageAction.upload,
            failure: null,
          ),
        );
      },
    );
  }

  Future<void> clear({String? idempotencyKey}) async {
    if (state.isUploading || state.isClearing) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
        failure: null,
      ),
    );

    final result = await _clearProfileImage(
      ClearProfileImageRequestEntity(idempotencyKey: idempotencyKey),
    );

    if (isClosed) return;
    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileImageStatus.failure,
          action: ProfileImageAction.clear,
          failure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ProfileImageStatus.success,
          action: ProfileImageAction.clear,
          failure: null,
        ),
      ),
    );
  }

  Future<void> loadAvatar() async {
    if (state.isUploading || state.isClearing) return;

    final user = _userContext.user;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileImageStatus.initial,
          action: ProfileImageAction.none,
          cachedFilePath: null,
          failure: null,
        ),
      );
      return;
    }

    final userId = user.id;
    final profileImageFileId = user.profile.profileImageFileId?.trim();
    final hasFileId =
        profileImageFileId != null && profileImageFileId.isNotEmpty;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadAvatar,
        failure: null,
      ),
    );

    final cachedResult = await _getCachedProfileAvatar(
      userId: userId,
      profileImageFileId: profileImageFileId,
    );

    await cachedResult.match(
      (failure) async {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ProfileImageStatus.failure,
            action: ProfileImageAction.loadAvatar,
            failure: failure,
          ),
        );
      },
      (entry) async {
        if (isClosed) return;

        if (entry != null) {
          emit(
            state.copyWith(
              status: ProfileImageStatus.initial,
              action: ProfileImageAction.none,
              cachedFilePath: entry.filePath,
              failure: null,
            ),
          );

          if (entry.isExpired && hasFileId) {
            _refreshInBackground(
              userId: userId,
              profileImageFileId: profileImageFileId,
            );
          }
          return;
        }

        // Cache miss.
        if (!hasFileId) {
          await _clearProfileAvatarCache(userId: userId);
          if (isClosed) return;
          emit(
            state.copyWith(
              status: ProfileImageStatus.initial,
              action: ProfileImageAction.none,
              cachedFilePath: null,
              failure: null,
            ),
          );
          return;
        }

        await _refreshAndEmit(
          userId: userId,
          profileImageFileId: profileImageFileId,
        );
      },
    );
  }

  void resetStatus() {
    if (state.status == ProfileImageStatus.initial) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        failure: null,
      ),
    );
  }

  Future<void> _refreshAndEmit({
    required String userId,
    required String profileImageFileId,
  }) async {
    if (isClosed) return;

    final key = '$userId:$profileImageFileId';
    final existing = _refreshFuture;
    if (existing != null && _refreshKey == key) {
      await existing;
      return;
    }

    _refreshKey = key;
    final Future<void> future = () async {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileImageStatus.loading,
          action: ProfileImageAction.loadAvatar,
          failure: null,
        ),
      );

      final result = await _refreshProfileAvatarCache(
        userId: userId,
        profileImageFileId: profileImageFileId,
      );

      if (isClosed) return;

      // Guard: ignore if user/fileId changed mid-flight.
      final currentUser = _userContext.user;
      if (currentUser == null ||
          currentUser.id != userId ||
          currentUser.profile.profileImageFileId?.trim() !=
              profileImageFileId) {
        return;
      }

      await result.match(
        (failure) async {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: ProfileImageStatus.failure,
              action: ProfileImageAction.loadAvatar,
              failure: failure,
            ),
          );
        },
        (entry) async {
          final filePath = entry?.filePath;
          if (filePath != null) {
            await _evictFileImage(filePath);
          }

          if (isClosed) return;
          emit(
            state.copyWith(
              status: ProfileImageStatus.initial,
              action: ProfileImageAction.none,
              cachedFilePath: filePath,
              failure: null,
            ),
          );
        },
      );
    }();

    _refreshFuture = future;
    await future;
    _refreshFuture = null;
    _refreshKey = null;
  }

  void _refreshInBackground({
    required String userId,
    required String profileImageFileId,
  }) {
    if (isClosed) return;
    unawaited(
      _refreshAndEmit(userId: userId, profileImageFileId: profileImageFileId),
    );
  }

  Future<void> _evictFileImage(String filePath) async {
    try {
      await FileImage(File(filePath)).evict();
    } catch (_) {
      // Ignore cache eviction failures; worst case the old image stays until
      // the next rebuild or app restart.
    }
  }
}
