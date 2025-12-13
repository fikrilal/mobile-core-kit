class AuthEndpoint {
  /// Email/password login.
  static const String passwordLogin = '/auth/password/login';

  @Deprecated('Use passwordLogin.')
  static const String login = passwordLogin;

  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String googleMobile = '/auth/google/mobile';
}
