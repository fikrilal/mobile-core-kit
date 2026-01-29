import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_avatar_cache_entry_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_avatar_repository.dart';

class RefreshProfileAvatarCacheUseCase {
  RefreshProfileAvatarCacheUseCase(this._repository);

  final ProfileAvatarRepository _repository;

  Future<Either<AuthFailure, ProfileAvatarCacheEntryEntity?>> call({
    required String userId,
    required String profileImageFileId,
  }) => _repository.refreshAvatar(
    userId: userId,
    profileImageFileId: profileImageFileId,
  );
}
