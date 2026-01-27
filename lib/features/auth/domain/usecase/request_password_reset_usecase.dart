import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  RequestPasswordResetUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(
    PasswordResetRequestEntity request,
  ) async {
    // Final gate validation: email format.
    final email = EmailAddress.create(request.email);

    final errors = <ValidationError>[];
    String normalizedEmail = request.email.trim();

    email.fold(
      (ValueFailure f) => errors.add(
        ValidationError(field: 'email', message: '', code: f.code),
      ),
      (_) {},
    );
    email.match((_) {}, (value) => normalizedEmail = value.value);

    if (errors.isNotEmpty) {
      return left<AuthFailure, Unit>(AuthFailure.validation(errors));
    }

    return _repository.requestPasswordReset(
      PasswordResetRequestEntity(email: normalizedEmail),
    );
  }
}
