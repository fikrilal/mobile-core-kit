import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_avatar_repository.dart';

class ClearProfileAvatarCacheUseCase {
  ClearProfileAvatarCacheUseCase(this._repository);

  final ProfileAvatarRepository _repository;

  Future<Either<AuthFailure, Unit>> call({required String userId}) =>
      _repository.clearAvatar(userId: userId);
}
