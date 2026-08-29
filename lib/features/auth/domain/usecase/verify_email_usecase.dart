import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_verification_token.dart';

class VerifyEmailUseCase {
  final AuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(String rawToken) {
    return EmailVerificationToken.create(rawToken).match(
      (failure) async => left(
        AuthFailure.validation([
          ValidationError(field: 'token', message: '', code: failure.code),
        ]),
      ),
      _repository.verifyEmail,
    );
  }
}
