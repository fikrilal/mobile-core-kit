abstract class IAnalyticsService {
  /// Initializes the underlying analytics SDK and applies environment defaults.
  Future<void> initialize();

  /// Logs a raw analytics event.
  ///
  /// Prefer using a higher-level tracker where possible.
  Future<void> logEvent(String eventName, {Map<String, Object?>? parameters});

  /// Logs a screen view.
  Future<void> logScreenView(
    String screenName, {
    String? previousScreenName,
    Map<String, Object?>? parameters,
  });

  /// Associates analytics data with a user identifier.
  Future<void> setUserId(String userId);

  /// Clears any user identifier and user scope properties.
  Future<void> clearUser();

  /// Sets a user-scoped property.
  Future<void> setUserProperty(String propertyName, String propertyValue);

  /// Enables or disables analytics collection at runtime.
  Future<void> setAnalyticsCollectionEnabled(bool enabled);

  /// Returns whether analytics collection is currently enabled.
  bool isAnalyticsCollectionEnabled();
}
