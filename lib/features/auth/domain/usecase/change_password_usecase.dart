import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(
    ChangePasswordRequestEntity request,
  ) async {
    // Final gate validation: current password non-empty + new password policy,
    // and enforce new != current to avoid backend CONFLICT.
    final errors = <ValidationError>[];

    final currentPassword = LoginPassword.create(request.currentPassword);
    currentPassword.fold(
      (ValueFailure f) => errors.add(
        ValidationError(field: 'currentPassword', message: '', code: f.code),
      ),
      (_) {},
    );

    final newPassword = Password.create(request.newPassword);
    newPassword.fold(
      (ValueFailure f) => errors.add(
        ValidationError(field: 'newPassword', message: '', code: f.code),
      ),
      (_) {},
    );

    if (request.newPassword == request.currentPassword) {
      errors.add(
        const ValidationError(
          field: 'newPassword',
          message: '',
          code: ValidationErrorCodes.passwordSameAsCurrent,
        ),
      );
    }

    if (errors.isNotEmpty) {
      return left<AuthFailure, Unit>(AuthFailure.validation(errors));
    }

    return _repository.changePassword(request);
  }
}
