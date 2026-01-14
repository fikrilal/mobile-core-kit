import 'package:fpdart/fpdart.dart';
import '../entity/logout_request_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class LogoutRemoteUseCase {
  final AuthRepository _repository;

  LogoutRemoteUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(LogoutRequestEntity request) async {
    return _repository.logout(request);
  }
}
