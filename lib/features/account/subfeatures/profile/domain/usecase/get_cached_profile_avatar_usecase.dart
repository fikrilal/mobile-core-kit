import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_avatar_cache_entry_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_avatar_repository.dart';

class GetCachedProfileAvatarUseCase {
  GetCachedProfileAvatarUseCase(this._repository);

  final ProfileAvatarRepository _repository;

  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> call({
    required String userId,
    required String? profileImageFileId,
  }) => _repository.getCachedAvatar(
    userId: userId,
    profileImageFileId: profileImageFileId,
  );
}
