import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/entity/revoke_me_session_request_entity.dart';

abstract class MeSessionRepository {
  Future<Either<AuthFailure, MeSessionsPageEntity>> listSessions(
    ListMeSessionsRequestEntity request,
  );

  Future<Either<AuthFailure, Unit>> revokeSession(
    RevokeMeSessionRequestEntity request,
  );
}
