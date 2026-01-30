class AuthEndpoint {
  static const String login = '/auth/password/login';
  static const String register = '/auth/password/register';
  static const String changePassword = '/auth/password/change';
  static const String passwordResetRequest = '/auth/password/reset/request';
  static const String passwordResetConfirm = '/auth/password/reset/confirm';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String oidcExchange = '/auth/oidc/exchange';
  static const String verifyEmail = '/auth/email/verify';
  static const String resendEmailVerification =
      '/auth/email/verification/resend';
}
