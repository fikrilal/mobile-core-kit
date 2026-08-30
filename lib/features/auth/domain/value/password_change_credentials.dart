import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';

/// Validated credentials accepted by the change-password repository boundary.
class PasswordChangeCredentials {
  const PasswordChangeCredentials._({
    required this.currentPassword,
    required this.newPassword,
  });

  final LoginPassword currentPassword;
  final Password newPassword;

  static Either<List<ValidationError>, PasswordChangeCredentials> create({
    required String currentPassword,
    required String newPassword,
  }) {
    final currentResult = LoginPassword.create(currentPassword);
    final newResult = Password.create(newPassword);
    final errors = <ValidationError>[];
    LoginPassword? validCurrent;
    Password? validNew;

    currentResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(
          field: 'currentPassword',
          message: '',
          code: failure.code,
        ),
      ),
      (value) => validCurrent = value,
    );
    newResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'newPassword', message: '', code: failure.code),
      ),
      (value) => validNew = value,
    );

    if (newPassword == currentPassword) {
      errors.add(
        const ValidationError(
          field: 'newPassword',
          message: '',
          code: ValidationErrorCodes.passwordSameAsCurrent,
        ),
      );
    }

    if (errors.isNotEmpty) return left(errors);

    return right(
      PasswordChangeCredentials._(
        currentPassword: validCurrent!,
        newPassword: validNew!,
      ),
    );
  }
}
