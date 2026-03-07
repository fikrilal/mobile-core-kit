/// Auth feature backend error codes (RFC7807 `code`).
///
/// Keep these codes feature-scoped to avoid growing `core/` with app-specific
/// contracts.
class AuthErrorCodes {
  AuthErrorCodes._();

  /// Login failed due to invalid email/password.
  static const String invalidCredentials = 'AUTH_INVALID_CREDENTIALS';

  /// Legacy login failure code (kept for backwards compatibility).
  static const String legacyInvalidCredentials = 'INVALID_CREDENTIALS';

  /// Email already exists (register).
  static const String emailAlreadyExists = 'AUTH_EMAIL_ALREADY_EXISTS';

  /// Legacy refresh failure code (kept for backwards compatibility).
  static const String invalidRefreshToken = 'INVALID_REFRESH_TOKEN';

  /// Refresh token is invalid.
  static const String refreshTokenInvalid = 'AUTH_REFRESH_TOKEN_INVALID';

  /// Refresh token is expired.
  static const String refreshTokenExpired = 'AUTH_REFRESH_TOKEN_EXPIRED';

  /// Refresh token reuse detected (session may be revoked server-side).
  static const String refreshTokenReused = 'AUTH_REFRESH_TOKEN_REUSED';

  /// Session has been revoked (e.g., user logged out all devices).
  static const String sessionRevoked = 'AUTH_SESSION_REVOKED';

  /// User is suspended.
  static const String userSuspended = 'AUTH_USER_SUSPENDED';

  /// Legacy (non-kit) code used by some backends.
  static const String emailNotVerified = 'EMAIL_NOT_VERIFIED';

  /// OIDC email is not verified (provider).
  static const String oidcEmailNotVerified = 'AUTH_OIDC_EMAIL_NOT_VERIFIED';

  /// OIDC token invalid/expired.
  static const String oidcTokenInvalid = 'AUTH_OIDC_TOKEN_INVALID';

  /// OIDC exchange found an existing password account; client must link first.
  static const String oidcLinkRequired = 'AUTH_OIDC_LINK_REQUIRED';

  /// OIDC provider is not configured on backend.
  static const String oidcNotConfigured = 'AUTH_OIDC_NOT_CONFIGURED';

  /// Email verification token is invalid (malformed/unknown/redeemed).
  static const String emailVerificationTokenInvalid =
      'AUTH_EMAIL_VERIFICATION_TOKEN_INVALID';

  /// Email verification token is expired.
  static const String emailVerificationTokenExpired =
      'AUTH_EMAIL_VERIFICATION_TOKEN_EXPIRED';

  /// User does not have a password set (OIDC-only account).
  static const String passwordNotSet = 'AUTH_PASSWORD_NOT_SET';

  /// Current password is invalid (change password).
  static const String currentPasswordInvalid = 'AUTH_CURRENT_PASSWORD_INVALID';

  /// Password reset token is invalid (malformed/unknown/redeemed).
  static const String passwordResetTokenInvalid =
      'AUTH_PASSWORD_RESET_TOKEN_INVALID';

  /// Password reset token is expired.
  static const String passwordResetTokenExpired =
      'AUTH_PASSWORD_RESET_TOKEN_EXPIRED';
}
