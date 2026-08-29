import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/input/register_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/registration_credentials.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(
    RegisterInput input,
  ) async {
    final credentials = RegistrationCredentials.create(
      email: input.email,
      password: input.password,
    );

    return credentials.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.register,
    );
  }
}
