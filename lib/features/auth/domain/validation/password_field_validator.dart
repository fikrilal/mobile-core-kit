import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/confirm_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';

/// Shared field validators for password forms (change password, password
/// reset, registration, sign in).
abstract final class PasswordFieldValidator {
  /// Validates the current/legacy password field (non-empty only).
  static ValidationError? validateCurrentPassword(String value) {
    return LoginPassword.create(value).fold(
      (ValueFailure f) =>
          ValidationError(field: 'currentPassword', message: '', code: f.code),
      (_) => null,
    );
  }

  /// Validates a new password. When [currentPassword] is provided and the new
  /// password equals it, reports `passwordSameAsCurrent`.
  static ValidationError? validateNewPassword(
    String value, {
    String? currentPassword,
  }) {
    final result = Password.create(value);
    final baseError = result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'newPassword', message: '', code: f.code),
      (_) => null,
    );

    if (baseError != null) return baseError;

    final canCheckSameAsCurrent =
        value.isNotEmpty && (currentPassword?.isNotEmpty ?? false);
    if (canCheckSameAsCurrent && value == currentPassword) {
      return const ValidationError(
        field: 'newPassword',
        message: '',
        code: ValidationErrorCodes.passwordSameAsCurrent,
      );
    }

    return null;
  }

  /// Validates the confirm-password field. Returns null while the new password
  /// itself is invalid, to avoid noisy "does not match" errors.
  static ValidationError? validateConfirmPassword({
    required String newPassword,
    required String confirmNewPassword,
    ValidationError? newPasswordError,
  }) {
    if (newPasswordError != null) return null;

    return ConfirmPassword.create(newPassword, confirmNewPassword).fold(
      (ValueFailure f) => ValidationError(
        field: 'confirmNewPassword',
        message: '',
        code: f.code,
      ),
      (_) => null,
    );
  }
}
