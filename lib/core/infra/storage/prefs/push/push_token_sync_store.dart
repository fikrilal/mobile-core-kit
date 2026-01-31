import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for push token sync dedupe + cooldown state.
///
/// Contract:
/// - Stores only hashes (never stores raw tokens).
/// - `lastSentSessionHash` + `lastSentTokenHash` are used to dedupe repeated
///   `PUT /me/push-token` calls for the same session + token.
/// - `pushNotConfiguredUntil` is used to back off after the backend returns
///   `PUSH_NOT_CONFIGURED` (501).
class PushTokenSyncStore {
  PushTokenSyncStore({Future<SharedPreferences>? prefs})
    : _prefsFuture = prefs ?? SharedPreferences.getInstance();

  static const String _kLastSentSessionHashKey = 'push_last_sent_session_hash';
  static const String _kLastSentTokenHashKey = 'push_last_sent_token_hash';
  static const String _kPushNotConfiguredUntilMsKey =
      'push_not_configured_until_ms';

  final Future<SharedPreferences> _prefsFuture;

  Future<bool> isDeduped({
    required String sessionKey,
    required String token,
  }) async {
    final sessionHash = await readLastSentSessionHash();
    final tokenHash = await readLastSentTokenHash();
    if (sessionHash == null || tokenHash == null) return false;
    return sessionHash == _stableHash(sessionKey) &&
        tokenHash == _stableHash(token);
  }

  Future<String?> readLastSentSessionHash() async {
    final prefs = await _prefsFuture;
    return _normalizeNullableString(prefs.getString(_kLastSentSessionHashKey));
  }

  Future<String?> readLastSentTokenHash() async {
    final prefs = await _prefsFuture;
    return _normalizeNullableString(prefs.getString(_kLastSentTokenHashKey));
  }

  Future<DateTime?> readPushNotConfiguredUntil() async {
    final prefs = await _prefsFuture;
    final epochMs = prefs.getInt(_kPushNotConfiguredUntilMsKey);
    if (epochMs == null || epochMs <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  Future<void> writeLastSent({
    required String sessionKey,
    required String token,
  }) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_kLastSentSessionHashKey, _stableHash(sessionKey));
    await prefs.setString(_kLastSentTokenHashKey, _stableHash(token));
  }

  Future<void> clearLastSent() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_kLastSentSessionHashKey);
    await prefs.remove(_kLastSentTokenHashKey);
  }

  Future<void> writePushNotConfiguredUntil(DateTime until) async {
    final prefs = await _prefsFuture;
    await prefs.setInt(
      _kPushNotConfiguredUntilMsKey,
      until.millisecondsSinceEpoch,
    );
  }

  Future<void> clearPushNotConfiguredUntil() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_kPushNotConfiguredUntilMsKey);
  }

  static String? _normalizeNullableString(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  /// Stable, deterministic hash used for persistence.
  ///
  /// Notes:
  /// - We avoid Dart's `String.hashCode` because it is not stable across runs.
  /// - We use a simple FNV-1a 64-bit hash to avoid extra dependencies.
  /// - This is used only for dedupe/backoff state; it is not a security feature.
  static String _stableHash(String input) {
    final bytes = utf8.encode(input);
    final fnvOffsetBasis = BigInt.parse('cbf29ce484222325', radix: 16);
    final fnvPrime = BigInt.parse('100000001b3', radix: 16);
    final mask64 = (BigInt.one << 64) - BigInt.one;

    var hash = fnvOffsetBasis;
    for (final b in bytes) {
      hash = hash ^ BigInt.from(b);
      hash = (hash * fnvPrime) & mask64;
    }

    // 64-bit hex string, left-padded for stable storage.
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
