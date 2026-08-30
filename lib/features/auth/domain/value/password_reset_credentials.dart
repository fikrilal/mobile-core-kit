import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/reset_token.dart';

/// Validated credentials accepted by the reset-confirm repository boundary.
class PasswordResetCredentials {
  const PasswordResetCredentials._({
    required this.token,
    required this.newPassword,
  });

  final ResetToken token;
  final Password newPassword;

  static Either<List<ValidationError>, PasswordResetCredentials> create({
    required String token,
    required String newPassword,
  }) {
    final tokenResult = ResetToken.create(token);
    final passwordResult = Password.create(newPassword);
    final errors = <ValidationError>[];
    ResetToken? validToken;
    Password? validPassword;

    tokenResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'token', message: '', code: failure.code),
      ),
      (value) => validToken = value,
    );
    passwordResult.fold(
      (ValueFailure failure) => errors.add(
        ValidationError(field: 'newPassword', message: '', code: failure.code),
      ),
      (value) => validPassword = value,
    );

    if (errors.isNotEmpty) return left(errors);

    return right(
      PasswordResetCredentials._(
        token: validToken!,
        newPassword: validPassword!,
      ),
    );
  }
}
