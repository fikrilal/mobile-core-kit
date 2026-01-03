/// Centralized analytics event names used across the app.
class AnalyticsEvents {
  AnalyticsEvents._();

  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String buttonClick = 'button_click';
  static const String search = 'search';
  static const String startupMetrics = 'startup_metrics';

  static const String deepLinkReceived = 'deep_link_received';
  static const String deepLinkRejected = 'deep_link_rejected';
  static const String deepLinkPendingSet = 'deep_link_pending_set';
  static const String deepLinkResumed = 'deep_link_resumed';
  static const String deepLinkCleared = 'deep_link_cleared';
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

  static const String deepLinkSource = 'deep_link_source';
  static const String deepLinkScheme = 'deep_link_scheme';
  static const String deepLinkHost = 'deep_link_host';
  static const String deepLinkPath = 'deep_link_path';
  static const String deepLinkReason = 'deep_link_reason';
  static const String deepLinkQueryKeyCount = 'deep_link_query_key_count';
  static const String deepLinkLatencyMs = 'deep_link_latency_ms';
  static const String deepLinkWasReplaced = 'deep_link_was_replaced';

  static const String startupPreRunAppMs = 'startup_pre_runapp_ms';
  static const String startupTtffMs = 'startup_ttff_ms';
  static const String startupReadyMs = 'startup_ready_ms';
  static const String startupBootstrapMs = 'startup_bootstrap_ms';

  static const String startupFirebaseInitMs = 'startup_firebase_init_ms';
  static const String startupCrashlyticsMs = 'startup_crashlytics_ms';
  static const String startupIntlMs = 'startup_intl_ms';

  static const String startupFirstFrameBuildMs = 'startup_first_frame_build_ms';
  static const String startupFirstFrameRasterMs = 'startup_first_frame_raster_ms';

  static const String startupSecureStorageReadMs = 'startup_secure_storage_read_ms';
}
