import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';

class PatchMeProfileUseCase {
  PatchMeProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call({
    required String givenName,
    String? familyName,
    String? displayName,
  }) => _repository.patchMeProfile(
    givenName: givenName,
    familyName: familyName,
    displayName: displayName,
  );
}
