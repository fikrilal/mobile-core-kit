import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository _repository;
  GoogleSignInUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call() =>
      _repository.googleSignIn();
}
