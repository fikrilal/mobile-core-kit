import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';

/// Validated credentials accepted by the login repository boundary.
class LoginCredentials {
  const LoginCredentials._({required this.email, required this.password});

  final EmailAddress email;
  final LoginPassword password;

  static Either<List<ValidationError>, LoginCredentials> create({
    required String email,
    required String password,
  }) {
    final emailResult = EmailAddress.create(email);
    final passwordResult = LoginPassword.create(password);
    final errors = <ValidationError>[];
    EmailAddress? validEmail;
    LoginPassword? validPassword;

    emailResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'email', message: '', code: failure.code),
      ),
      (value) => validEmail = value,
    );
    passwordResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'password', message: '', code: failure.code),
      ),
      (value) => validPassword = value,
    );

    if (errors.isNotEmpty) return left(errors);

    return right(
      LoginCredentials._(email: validEmail!, password: validPassword!),
    );
  }
}
