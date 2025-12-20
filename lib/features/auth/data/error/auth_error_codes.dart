/// Auth feature backend error codes (RFC7807 `code`).
///
/// Keep these codes feature-scoped to avoid growing `core/` with app-specific
/// contracts.
class AuthErrorCodes {
  AuthErrorCodes._();

  /// Login failed due to invalid email/password.
  static const String invalidCredentials = 'INVALID_CREDENTIALS';

  /// Refresh failed because the refresh token is invalid/expired/revoked.
  static const String invalidRefreshToken = 'INVALID_REFRESH_TOKEN';

  /// User exists but must verify email before proceeding.
  static const String emailNotVerified = 'EMAIL_NOT_VERIFIED';
}

