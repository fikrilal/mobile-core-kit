import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';

class RequestPasswordResetUseCase {
  final AuthRepository _repository;

  RequestPasswordResetUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(String rawEmail) async {
    return EmailAddress.create(rawEmail).match(
      (failure) async => left(
        AuthFailure.validation([
          ValidationError(field: 'email', message: '', code: failure.code),
        ]),
      ),
      _repository.requestPasswordReset,
    );
  }
}
