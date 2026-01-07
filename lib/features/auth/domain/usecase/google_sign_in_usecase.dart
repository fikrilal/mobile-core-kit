import 'package:fpdart/fpdart.dart';
import '../entity/auth_session_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository _repository;
  GoogleSignInUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call() =>
      _repository.googleSignIn();
}
