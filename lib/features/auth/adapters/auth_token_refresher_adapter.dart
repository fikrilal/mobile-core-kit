import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/session/auth_to_session_failure_mapper.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/session/token_refresher.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class AuthTokenRefresherAdapter implements TokenRefresher {
  AuthTokenRefresherAdapter(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<SessionFailure, AuthTokensEntity>> refresh(
    String refreshToken,
  ) async {
    final result = await _repository.refreshToken(
      RefreshRequestEntity(refreshToken: refreshToken),
    );
    return result.mapLeft(mapAuthFailureToSessionFailure);
  }
}
