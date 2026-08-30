import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/input/password_reset_confirmation_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_reset_credentials.dart';

class ConfirmPasswordResetUseCase {
  final AuthRepository _repository;

  ConfirmPasswordResetUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(
    PasswordResetConfirmationInput input,
  ) async {
    final credentials = PasswordResetCredentials.create(
      token: input.token,
      newPassword: input.newPassword,
    );

    return credentials.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.confirmPasswordReset,
    );
  }
}
