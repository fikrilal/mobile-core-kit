import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for device identity metadata.
///
/// Template note:
/// - This data is not user/session scoped. It must NOT be cleared on logout.
/// - The stored ID is used as the backend `deviceId` field for auth/session APIs.
class DeviceIdentitySecureStorage {
  static const _kDeviceId = 'device_id';

  final FlutterSecureStorage _storage;

  const DeviceIdentitySecureStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              resetOnError: true,
              migrateOnAlgorithmChange: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
            ),
          );

  Future<String?> readDeviceId() => _storage.read(key: _kDeviceId);

  Future<void> writeDeviceId(String id) =>
      _storage.write(key: _kDeviceId, value: id);

  /// Clears the stored device id.
  ///
  /// Not used by logout; intended for debugging/tests only.
  Future<void> clearDeviceId() => _storage.delete(key: _kDeviceId);
}
