import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/input/login_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_credentials.dart';

class LoginUserUseCase {
  final AuthRepository _repository;

  LoginUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(LoginInput input) async {
    final credentials = LoginCredentials.create(
      email: input.email,
      password: input.password,
    );

    return credentials.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.login,
    );
  }
}
