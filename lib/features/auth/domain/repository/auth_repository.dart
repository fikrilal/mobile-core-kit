import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/refresh_request_entity.dart';
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

  /// Sign in with Google via Firebase Auth, then exchange the Firebase ID token
  /// with the backend to obtain an app session (access/refresh tokens).
  Future<Either<AuthFailure, AuthSessionEntity>> googleSignIn();
}
