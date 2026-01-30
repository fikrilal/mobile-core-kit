import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class LoginUserUseCase {
  final AuthRepository _repository;

  LoginUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(
    LoginRequestEntity request,
  ) async {
    // Final gate validation: email format + non-empty password
    final email = EmailAddress.create(request.email);
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

    final password = LoginPassword.create(request.password);
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

    return _repository.login(
      LoginRequestEntity(email: normalizedEmail, password: normalizedPassword),
    );
  }
}
