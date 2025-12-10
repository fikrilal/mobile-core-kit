import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenSecureStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kExpiry = 'expires_in';

  final FlutterSecureStorage _storage;

  const TokenSecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save({
    required String access,
    required String refresh,
    required int expiresIn,
  }) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
    await _storage.write(key: _kExpiry, value: expiresIn.toString());
  }

  Future<({String? access, String? refresh, int? expiresIn})> read() async {
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    final expStr = await _storage.read(key: _kExpiry);
    final expiry = expStr == null ? null : int.tryParse(expStr);
    return (access: access, refresh: refresh, expiresIn: expiry);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kExpiry);
  }
}
