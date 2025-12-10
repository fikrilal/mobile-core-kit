import 'package:fpdart/fpdart.dart';
import '../entity/refresh_request_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class LogoutUserUseCase {
  final AuthRepository _repository;

  LogoutUserUseCase(this._repository);

  Future<Either<AuthFailure, String?>> call(
    RefreshRequestEntity request,
  ) async {
    return _repository.logout(request);
  }
}
