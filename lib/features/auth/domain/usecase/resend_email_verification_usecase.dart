import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class ResendEmailVerificationUseCase {
  final AuthRepository _repository;

  ResendEmailVerificationUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call() {
    return _repository.resendEmailVerification();
  }
}

