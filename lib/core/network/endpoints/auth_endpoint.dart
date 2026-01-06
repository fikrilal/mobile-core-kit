class AuthEndpoint {
  /// Email/password login.
  static const String passwordLogin = '/auth/password/login';

  @Deprecated('Use passwordLogin.')
  static const String login = passwordLogin;

  /// Email/password register.
  static const String register = '/auth/password/register';

  /// Refresh access token using a refresh token.
  static const String refreshToken = '/auth/password/refresh';
  static const String logout = '/auth/logout';
  static const String googleMobile = '/auth/google';
}
