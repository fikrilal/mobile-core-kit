import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_verification_token.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(VerifyEmailRequestEntity request) {
    final token = EmailVerificationToken.create(request.token);

    final errors = <ValidationError>[];
    String normalizedToken = request.token.trim();

    token.fold(
      (f) => errors.add(
        ValidationError(field: 'token', message: '', code: f.code),
      ),
      (value) => normalizedToken = value.value,
    );

    if (errors.isNotEmpty) {
      return Future.value(left(AuthFailure.validation(errors)));
    }

    return _repository.verifyEmail(
      VerifyEmailRequestEntity(token: normalizedToken),
    );
  }
}
