import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/input/change_password_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_change_credentials.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(ChangePasswordInput input) async {
    final credentials = PasswordChangeCredentials.create(
      currentPassword: input.currentPassword,
      newPassword: input.newPassword,
    );

    return credentials.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.changePassword,
    );
  }
}
