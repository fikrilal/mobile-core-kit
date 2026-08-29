import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';

/// Validated credentials accepted by the registration repository boundary.
class RegistrationCredentials {
  const RegistrationCredentials._({
    required this.email,
    required this.password,
  });

  final EmailAddress email;
  final Password password;

  static Either<List<ValidationError>, RegistrationCredentials> create({
    required String email,
    required String password,
  }) {
    final emailResult = EmailAddress.create(email);
    final passwordResult = Password.create(password);
    final errors = <ValidationError>[];
    EmailAddress? validEmail;
    Password? validPassword;

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
      RegistrationCredentials._(email: validEmail!, password: validPassword!),
    );
  }
}
