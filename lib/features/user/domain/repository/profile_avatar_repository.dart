import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_avatar_cache_entry_entity.dart';

/// Avatar cache orchestration.
///
/// Notes:
/// - The cache is per-user (scoped by [userId]).
/// - The backend `profileImageFileId` is used to invalidate stale cache.
abstract interface class ProfileAvatarRepository {
  /// Returns cached avatar entry when available.
  ///
  /// If [profileImageFileId] is null/empty, implementations should clear cache
  /// and return `right(null)`.
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> getCachedAvatar({
    required String userId,
    required String? profileImageFileId,
  });

  /// Refreshes avatar cache by requesting a presigned render URL from backend
  /// and downloading bytes to disk.
  ///
  /// If the backend indicates no profile image (e.g. `204`), implementations
  /// should clear cache and return `right(null)`.
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> refreshAvatar({
    required String userId,
    required String profileImageFileId,
  });

  /// Saves avatar bytes to the local disk cache.
  ///
  /// Intended for seeding the cache after a successful upload, so UI can render
  /// immediately without re-downloading the newly uploaded image.
  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> saveAvatarBytes({
    required String userId,
    required String profileImageFileId,
    required Uint8List bytes,
  });

  Future<Either<AuthFailure, Unit>> clearAvatar({required String userId});

  /// Clears caches for all users (safe default for session teardown).
  Future<Either<AuthFailure, Unit>> clearAllAvatars();
}
