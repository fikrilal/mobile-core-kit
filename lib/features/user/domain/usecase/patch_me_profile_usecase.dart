import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';

class PatchMeProfileUseCase {
  PatchMeProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call(
    PatchMeProfileRequestEntity request,
  ) => _repository.patchMeProfile(request);
}
