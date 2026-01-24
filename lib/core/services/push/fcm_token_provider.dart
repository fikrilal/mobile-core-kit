import 'package:mobile_core_kit/core/services/push/push_permission_state.dart';

/// Wraps Firebase Cloud Messaging (FCM) SDK usage behind a stable interface.
///
/// This keeps platform SDK imports out of feature code and makes it easier to:
/// - test orchestration logic (by stubbing this interface)
/// - swap/extend providers (APNs, web push) without large refactors
abstract interface class FcmTokenProvider {
  /// Returns the current FCM registration token, or null if unavailable.
  Future<String?> getToken();

  /// Emits new FCM registration tokens when the SDK rotates them.
  Stream<String> get onTokenRefresh;

  /// Requests user notification permission (best-effort).
  ///
  /// Note: This method may trigger a platform prompt. Do not call it at
  /// startup; wire it behind product UX.
  Future<PushPermissionState> requestPermission();
}
