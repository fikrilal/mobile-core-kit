import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
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
    return result.mapLeft(_toSessionFailure);
  }

  SessionFailure _toSessionFailure(AuthFailure failure) {
    return failure.when(
      network: () => const SessionFailure.network(),
      cancelled: () => const SessionFailure.unexpected(),
      unauthenticated: () => const SessionFailure.unauthenticated(),
      passwordNotSet: () => const SessionFailure.unexpected(),
      emailTaken: () => const SessionFailure.unexpected(),
      emailNotVerified: () => const SessionFailure.unexpected(),
      oidcLinkRequired: () => const SessionFailure.unexpected(),
      validation: (_) => const SessionFailure.unexpected(),
      invalidCredentials: () => const SessionFailure.unexpected(),
      tooManyRequests: () => const SessionFailure.tooManyRequests(),
      userSuspended: () => const SessionFailure.unexpected(),
      serverError: (message) => SessionFailure.serverError(message),
      unexpected: (message) => SessionFailure.unexpected(message),
    );
  }
}
