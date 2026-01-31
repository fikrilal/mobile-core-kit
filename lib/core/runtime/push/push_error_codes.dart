/// Backend error codes used by template-level push token sync.
abstract final class PushErrorCodes {
  PushErrorCodes._();

  /// Backend push provider is not configured/enabled.
  ///
  /// The backend may return this when FCM/APNs integration is disabled via
  /// environment configuration. Clients should treat it as non-fatal and back
  /// off for a cooldown period.
  static const String pushNotConfigured = 'PUSH_NOT_CONFIGURED';
}
