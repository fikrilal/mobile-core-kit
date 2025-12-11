/// Centralized analytics event names used across the app.
class AnalyticsEvents {
  AnalyticsEvents._();

  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String buttonClick = 'button_click';
  static const String search = 'search';
}

/// Centralized analytics parameter names.
class AnalyticsParams {
  AnalyticsParams._();

  static const String screenName = 'screen_name';
  static const String previousScreenName = 'previous_screen_name';

  static const String method = 'method';

  static const String buttonId = 'button_id';

  static const String searchQuery = 'search_query';
  static const String searchType = 'search_type';

  static const String appEnvironment = 'app_environment';
}
