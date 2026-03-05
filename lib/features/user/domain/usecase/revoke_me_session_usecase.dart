import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/revoke_me_session_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/me_session_repository.dart';

class RevokeMeSessionUseCase {
  RevokeMeSessionUseCase(this._repository);

  final MeSessionRepository _repository;

  Future<Either<AuthFailure, Unit>> call(RevokeMeSessionRequestEntity request) {
    return _repository.revokeSession(request);
  }
}
