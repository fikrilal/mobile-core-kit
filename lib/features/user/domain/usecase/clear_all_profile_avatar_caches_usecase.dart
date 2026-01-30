import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_avatar_repository.dart';

class ClearAllProfileAvatarCachesUseCase {
  ClearAllProfileAvatarCachesUseCase(this._repository);

  final ProfileAvatarRepository _repository;

  Future<Either<AuthFailure, Unit>> call() => _repository.clearAllAvatars();
}
