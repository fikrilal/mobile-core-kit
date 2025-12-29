class AppRoutes {
  AppRoutes._();

  /// App entry/root route.
  ///
  /// GoRouter's platform default initial location is `/` when there's no
  /// deep link, so we always provide a route for it.
  static const String root = '/';
  static const String home = '/home';
  static const String profile = '/profile';
}
