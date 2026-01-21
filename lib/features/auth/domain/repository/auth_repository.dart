import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, AuthSessionEntity>> register(
    RegisterRequestEntity request,
  );

  Future<Either<AuthFailure, AuthSessionEntity>> login(
    LoginRequestEntity request,
  );

  Future<Either<AuthFailure, AuthTokensEntity>> refreshToken(
    RefreshRequestEntity request,
  );

  /// Logout (revoke the session associated with the refresh token).
  ///
  /// Backend: `POST /v1/auth/logout` (204 No Content, does not require access token).
  Future<Either<AuthFailure, Unit>> logout(LogoutRequestEntity request);

  /// Sign in with Google via OIDC and exchange the provider `id_token` with the backend.
  ///
  /// Backend: `POST /v1/auth/oidc/exchange` (provider=GOOGLE).
  Future<Either<AuthFailure, AuthSessionEntity>> signInWithGoogleOidc();
}
