import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/me_session_repository.dart';

class ListMeSessionsUseCase {
  ListMeSessionsUseCase(this._repository);

  final MeSessionRepository _repository;

  Future<Either<AuthFailure, MeSessionsPageEntity>> call(
    ListMeSessionsRequestEntity request,
  ) {
    return _repository.listSessions(request);
  }
}
