import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/domain/repository/current_user_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final CurrentUserRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call() =>
      _repository.getCurrentUser();
}
