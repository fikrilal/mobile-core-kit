/// Centralized analytics event names used across the app.
class AnalyticsEvents {
  AnalyticsEvents._();

  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String buttonClick = 'button_click';
  static const String search = 'search';
  static const String startupMetrics = 'startup_metrics';
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

  static const String startupPreRunAppMs = 'startup_pre_runapp_ms';
  static const String startupTtffMs = 'startup_ttff_ms';
  static const String startupReadyMs = 'startup_ready_ms';
  static const String startupBootstrapMs = 'startup_bootstrap_ms';

  static const String startupFirebaseInitMs = 'startup_firebase_init_ms';
  static const String startupCrashlyticsMs = 'startup_crashlytics_ms';
  static const String startupIntlMs = 'startup_intl_ms';

  static const String startupFirstFrameBuildMs = 'startup_first_frame_build_ms';
  static const String startupFirstFrameRasterMs = 'startup_first_frame_raster_ms';
}
