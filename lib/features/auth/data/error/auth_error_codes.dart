/// Auth feature backend error codes (RFC7807 `code`).
///
/// Keep these codes feature-scoped to avoid growing `core/` with app-specific
/// contracts.
class AuthErrorCodes {
  AuthErrorCodes._();

  /// Login failed due to invalid email/password.
  static const String invalidCredentials = 'INVALID_CREDENTIALS';

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

  /// User exists but must verify email before proceeding.
  static const String emailNotVerified = 'EMAIL_NOT_VERIFIED';
}
