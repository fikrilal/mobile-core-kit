import 'package:mobile_core_kit/core/services/device_identity/device_identity.dart';

abstract interface class DeviceIdentityService {
  /// Returns a stable app-scoped device identity.
  ///
  /// - `id` is stable across app restarts (and typically across reinstalls on iOS
  ///   due to Keychain persistence).
  /// - `name` is best-effort and may be null.
  Future<DeviceIdentity> get();
}
