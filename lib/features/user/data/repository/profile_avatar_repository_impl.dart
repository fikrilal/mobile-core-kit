import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_avatar_download_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_avatar_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_image_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_avatar_cache_entry_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_avatar_repository.dart';

class ProfileAvatarRepositoryImpl implements ProfileAvatarRepository {
  ProfileAvatarRepositoryImpl(this._remote, this._download, this._cache);

  final ProfileImageRemoteDataSource _remote;
  final ProfileAvatarDownloadDataSource _download;
  final ProfileAvatarCacheLocalDataSource _cache;

  @override
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> getCachedAvatar({
    required String userId,
    required String? profileImageFileId,
  }) async {
    try {
      final entry = await _cache.get(
        userId: userId,
        profileImageFileId: profileImageFileId,
      );
      if (entry == null) return right(null);
      return right(_toEntity(entry));
    } catch (e, st) {
      Log.error(
        'Get cached profile avatar unexpected error',
        e,
        st,
        true,
        'ProfileAvatarRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> refreshAvatar({
    required String userId,
    required String profileImageFileId,
  }) async {
    try {
      final apiResponse = await _remote.getProfileImageUrl();

      if (apiResponse.isError) {
        return left(
          mapProfileImageFailure(ApiFailure.fromApiResponse(apiResponse)),
        );
      }

      final model = apiResponse.data;
      if (model == null) {
        // Backend indicates no profile image is set (204). Treat as "no avatar".
        await _cache.clear(userId: userId);
        return right(null);
      }

      final url = model.url.trim();
      if (url.isEmpty) {
        // Fail-safe: treat empty URL as no avatar.
        await _cache.clear(userId: userId);
        return right(null);
      }

      final bytes = await _download.downloadBytes(url: url);

      final saved = await _cache.save(
        userId: userId,
        profileImageFileId: profileImageFileId,
        bytes: bytes,
      );
      if (saved == null) return left(const AuthFailure.unexpected());

      return right(_toEntity(saved));
    } on PresignedDownloadFailure catch (e) {
      return left(mapProfileAvatarDownloadFailure(e));
    } on Exception catch (e, st) {
      Log.error(
        'Refresh profile avatar cache unexpected error',
        e,
        st,
        true,
        'ProfileAvatarRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> saveAvatarBytes({
    required String userId,
    required String profileImageFileId,
    required Uint8List bytes,
  }) async {
    try {
      final saved = await _cache.save(
        userId: userId,
        profileImageFileId: profileImageFileId,
        bytes: bytes,
      );
      if (saved == null) return left(const AuthFailure.unexpected());
      return right(_toEntity(saved));
    } on Exception catch (e, st) {
      Log.error(
        'Save profile avatar bytes unexpected error',
        e,
        st,
        true,
        'ProfileAvatarRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> clearAvatar({
    required String userId,
  }) async {
    try {
      await _cache.clear(userId: userId);
      return right(unit);
    } catch (e, st) {
      Log.error(
        'Clear profile avatar cache unexpected error',
        e,
        st,
        true,
        'ProfileAvatarRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> clearAllAvatars() async {
    try {
      await _cache.clearAll();
      return right(unit);
    } catch (e, st) {
      Log.error(
        'Clear all profile avatar caches unexpected error',
        e,
        st,
        true,
        'ProfileAvatarRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  static ProfileAvatarCacheEntryEntity _toEntity(
    ProfileAvatarCacheEntryLocal local,
  ) {
    return ProfileAvatarCacheEntryEntity(
      filePath: local.filePath,
      cachedAt: local.cachedAt,
      isExpired: local.isExpired,
    );
  }
}
