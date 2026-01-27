import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
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

  /// Verifies a user email using a one-time token sent via email.
  ///
  /// Backend: `POST /v1/auth/email/verify` (204 No Content, does not require auth).
  Future<Either<AuthFailure, Unit>> verifyEmail(
    VerifyEmailRequestEntity request,
  );

  /// Resends the verification email for the current user (rate limited).
  ///
  /// Backend: `POST /v1/auth/email/verification/resend` (204 No Content, requires auth).
  Future<Either<AuthFailure, Unit>> resendEmailVerification();

  /// Changes the current user's password.
  ///
  /// Backend: `POST /v1/auth/password/change` (204 No Content, requires auth).
  ///
  /// Note: Backend revokes other sessions but keeps the current session active.
  Future<Either<AuthFailure, Unit>> changePassword(
    ChangePasswordRequestEntity request,
  );

  /// Request a password reset email (no account enumeration).
  ///
  /// Backend: `POST /v1/auth/password/reset/request` (204 No Content, public).
  Future<Either<AuthFailure, Unit>> requestPasswordReset(
    PasswordResetRequestEntity request,
  );

  /// Confirm a password reset using a one-time token.
  ///
  /// Backend: `POST /v1/auth/password/reset/confirm` (204 No Content, public).
  ///
  /// Note: Backend revokes all sessions/refresh tokens on success.
  Future<Either<AuthFailure, Unit>> confirmPasswordReset(
    PasswordResetConfirmRequestEntity request,
  );
}
