/// Default dimensions for navigation patterns (rail/drawer widths).
///
/// These are used as fallbacks by [NavigationPolicy] and `AdaptiveScaffold`
/// when the derived [NavigationSpec] does not specify explicit widths.
class NavigationTokens {
  NavigationTokens._();

  static const double railWidth = 72;
  static const double extendedRailWidth = 256;
  static const double drawerWidth = 304;
}
