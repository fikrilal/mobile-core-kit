import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/reset_token.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository _repository;

  ConfirmPasswordResetUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(
    PasswordResetConfirmRequestEntity request,
  ) async {
    // Final gate validation: non-empty token + new password policy.
    final errors = <ValidationError>[];

    final token = ResetToken.create(request.token);
    String normalizedToken = request.token.trim();

    token.fold(
      (ValueFailure f) => errors.add(
        ValidationError(field: 'token', message: '', code: f.code),
      ),
      (_) {},
    );
    token.match((_) {}, (value) => normalizedToken = value.value);

    final newPassword = Password.create(request.newPassword);
    String normalizedPassword = request.newPassword;

    newPassword.fold(
      (ValueFailure f) => errors.add(
        ValidationError(field: 'newPassword', message: '', code: f.code),
      ),
      (value) => normalizedPassword = value.value,
    );

    if (errors.isNotEmpty) {
      return left<AuthFailure, Unit>(AuthFailure.validation(errors));
    }

    return _repository.confirmPasswordReset(
      PasswordResetConfirmRequestEntity(
        token: normalizedToken,
        newPassword: normalizedPassword,
      ),
    );
  }
}
