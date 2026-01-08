import '../entity/login_request_entity.dart';
import '../entity/refresh_request_entity.dart';
import '../entity/auth_session_entity.dart';
import '../entity/auth_tokens_entity.dart';
import '../entity/register_request_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../failure/auth_failure.dart';

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

  /// Revoke all server-side sessions for the current user.
  ///
  /// Backend: `POST /v1/auth/sessions/revoke` (204 No Content, requires Bearer access token).
  Future<Either<AuthFailure, Unit>> revokeSessions();

  /// Sign in with Google via Firebase Auth, then exchange the Firebase ID token
  /// with the backend to obtain an app session (access/refresh tokens).
  Future<Either<AuthFailure, AuthSessionEntity>> googleSignIn();
}
