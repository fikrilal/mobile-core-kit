import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenSecureStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kExpiry = 'expires_in';
  static const _kExpiresAtMs = 'expires_at_ms';

  final FlutterSecureStorage _storage;

  const TokenSecureStorage([FlutterSecureStorage? storage])
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

  Future<void> save({
    required String access,
    required String refresh,
    required int expiresIn,
    int? expiresAtMs,
  }) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
    await _storage.write(key: _kExpiry, value: expiresIn.toString());
    if (expiresAtMs == null) {
      await _storage.delete(key: _kExpiresAtMs);
    } else {
      await _storage.write(key: _kExpiresAtMs, value: expiresAtMs.toString());
    }
  }

  Future<({String? access, String? refresh, int? expiresIn, int? expiresAtMs})>
  read() async {
    try {
      final all = await _storage.readAll();
      final access = all[_kAccess];
      final refresh = all[_kRefresh];
      final expStr = all[_kExpiry];
      final expiry = expStr == null ? null : int.tryParse(expStr);
      final expiresAtStr = all[_kExpiresAtMs];
      final expiresAtMs =
          expiresAtStr == null ? null : int.tryParse(expiresAtStr);
      return (
        access: access,
        refresh: refresh,
        expiresIn: expiry,
        expiresAtMs: expiresAtMs,
      );
    } catch (_) {
      // Best-effort fallback: on any plugin/readAll failure, retry via
      // per-key reads to avoid failing startup session restoration.
      final access = await _storage.read(key: _kAccess);
      final refresh = await _storage.read(key: _kRefresh);
      final expStr = await _storage.read(key: _kExpiry);
      final expiry = expStr == null ? null : int.tryParse(expStr);
      final expiresAtStr = await _storage.read(key: _kExpiresAtMs);
      final expiresAtMs =
          expiresAtStr == null ? null : int.tryParse(expiresAtStr);
      return (
        access: access,
        refresh: refresh,
        expiresIn: expiry,
        expiresAtMs: expiresAtMs,
      );
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kExpiry);
    await _storage.delete(key: _kExpiresAtMs);
  }
}
