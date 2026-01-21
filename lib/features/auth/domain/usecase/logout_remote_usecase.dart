import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class LogoutRemoteUseCase {
  final AuthRepository _repository;

  LogoutRemoteUseCase(this._repository);

  Future<Either<AuthFailure, Unit>> call(LogoutRequestEntity request) async {
    return _repository.logout(request);
  }
}
