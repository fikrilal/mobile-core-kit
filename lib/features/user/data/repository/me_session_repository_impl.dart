import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/me_session_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/error/user_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/list_me_sessions_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/me_session_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/revoke_me_session_request_model.dart';
import 'package:mobile_core_kit/features/user/domain/entity/list_me_sessions_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/me_session_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/revoke_me_session_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/me_session_repository.dart';

class MeSessionRepositoryImpl implements MeSessionRepository {
  MeSessionRepositoryImpl(this._remote);

  final MeSessionRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, MeSessionsPageEntity>> listSessions(
    ListMeSessionsRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.listSessions(
        request: request.toModel(),
      );
      return apiResponse
          .toEitherWithFallback('Failed to load sessions.')
          .mapLeft(mapUserFailure)
          .map((result) => result.toEntity());
    } catch (e, st) {
      Log.error('ListSessions unexpected error', e, st, true, 'MeSessionRepo');
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> revokeSession(
    RevokeMeSessionRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.revokeSession(
        request: request.toModel(),
      );
      return apiResponse
          .toEitherWithFallback('Failed to revoke session.')
          .mapLeft(mapUserFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error('RevokeSession unexpected error', e, st, true, 'MeSessionRepo');
      return left(const AuthFailure.unexpected());
    }
  }
}
