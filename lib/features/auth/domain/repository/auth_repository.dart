import '../entity/login_request_entity.dart';
import '../entity/refresh_request_entity.dart';
import '../entity/auth_session_entity.dart';
import '../entity/auth_tokens_entity.dart';
import '../entity/register_request_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../failure/auth_failure.dart';
import '../entity/logout_request_entity.dart';

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

  /// Sign in with Google via Firebase Auth, then exchange the Firebase ID token
  /// with the backend to obtain an app session (access/refresh tokens).
  Future<Either<AuthFailure, AuthSessionEntity>> googleSignIn();
}
