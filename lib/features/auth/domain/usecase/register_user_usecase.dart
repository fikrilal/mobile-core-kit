import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(
    RegisterRequestEntity request,
  ) async {
    // Final gate validation: email format + password.
    final email = EmailAddress.create(request.email);
    final password = Password.create(request.password);

    final errors = <ValidationError>[];
    String normalizedEmail = request.email.trim();
    String normalizedPassword = request.password;

    email.fold(
      (f) => errors.add(
        ValidationError(field: 'email', message: '', code: f.code),
      ),
      (_) {},
    );
    email.match((_) {}, (value) => normalizedEmail = value.value);

    password.fold(
      (f) => errors.add(
        ValidationError(field: 'password', message: '', code: f.code),
      ),
      (value) => normalizedPassword = value.value,
    );

    if (errors.isNotEmpty) {
      return left<AuthFailure, AuthSessionEntity>(
        AuthFailure.validation(errors),
      );
    }

    return _repository.register(
      RegisterRequestEntity(
        email: normalizedEmail,
        password: normalizedPassword,
      ),
    );
  }
}
