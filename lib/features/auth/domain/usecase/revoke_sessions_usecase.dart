import 'package:fpdart/fpdart.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class RevokeSessionsUseCase {
  final AuthRepository _repository;

  RevokeSessionsUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call() async {
    return _repository.revokeSessions();
  }
}
