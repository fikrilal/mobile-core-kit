import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/input/profile_image_upload_input.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_avatar_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit(
    this._userContext,
    this._uploadProfileImage,
    this._clearProfileImage,
    this._avatarRepository,
  ) : super(ProfileImageState.initial());

  final UserContextService _userContext;
  final UploadProfileImageUseCase _uploadProfileImage;
  final ClearProfileImageUseCase _clearProfileImage;
  final ProfileAvatarRepository _avatarRepository;
  final _effects = StreamController<ProfileImageEffect>();

  Future<void>? _refreshFuture;
  String? _refreshKey;

  Stream<ProfileImageEffect> get effects => _effects.stream;

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
      ProfileImageUploadInput(
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
            status: ProfileImageStatus.initial,
            action: ProfileImageAction.none,
            failure: null,
          ),
        );
        _effects.add(ShowProfileImageFailure(failure));
      },
      (user) async {
        var nextCachedFilePath = state.cachedFilePath;
        final fileId = user.profile.profileImageFileId?.trim();
        if (fileId != null && fileId.isNotEmpty) {
          final saved = await _avatarRepository.saveAvatarBytes(
            userId: user.id,
            profileImageFileId: fileId,
            bytes: bytes,
          );

          await saved.match((_) async {}, (entry) async {
            final filePath = entry?.filePath;
            if (filePath == null || filePath.isEmpty) return;
            await _evictFileImage(filePath);
            nextCachedFilePath = filePath;
          });
        }

        if (isClosed) return;
        emit(
          state.copyWith(
            status: ProfileImageStatus.initial,
            action: ProfileImageAction.none,
            cachedFilePath: nextCachedFilePath,
            failure: null,
          ),
        );
        _effects.add(const ShowProfileImageUpdated());
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
      (failure) {
        emit(
          state.copyWith(
            status: ProfileImageStatus.initial,
            action: ProfileImageAction.none,
            failure: null,
          ),
        );
        _effects.add(ShowProfileImageFailure(failure));
      },
      (_) {
        emit(
          state.copyWith(
            status: ProfileImageStatus.initial,
            action: ProfileImageAction.none,
            cachedFilePath: null,
            failure: null,
          ),
        );
        _effects.add(const ShowProfileImageRemoved());
      },
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

    final cachedResult = await _avatarRepository.getCachedAvatar(
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
          await _avatarRepository.clearAvatar(userId: userId);
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

      final result = await _avatarRepository.refreshAvatar(
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

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
