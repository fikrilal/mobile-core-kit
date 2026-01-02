import 'package:shared_preferences/shared_preferences.dart';

import 'deep_link_intent.dart';

/// Persists a single pending deep link intent with expiry.
///
/// This is intentionally minimal:
/// - one pending intent at a time (last write wins),
/// - stored in SharedPreferences,
/// - TTL-based expiry (fail safe: expired intents are cleared).
class PendingDeepLinkStore {
  PendingDeepLinkStore({
    Future<SharedPreferences>? prefs,
    Duration ttl = const Duration(hours: 1),
    DateTime Function()? now,
  }) : _prefsFuture = prefs ?? SharedPreferences.getInstance(),
       _ttl = ttl,
       _now = now ?? DateTime.now;

  static const String _kLocationKey = 'pending_deep_link_location';
  static const String _kReceivedAtMsKey = 'pending_deep_link_received_at_ms';
  static const String _kSourceKey = 'pending_deep_link_source';

  final Future<SharedPreferences> _prefsFuture;
  final Duration _ttl;
  final DateTime Function() _now;

  Future<void> save(DeepLinkIntent intent) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_kLocationKey, intent.location);
    await prefs.setInt(
      _kReceivedAtMsKey,
      intent.receivedAt.millisecondsSinceEpoch,
    );
    final source = intent.source;
    if (source == null || source.isEmpty) {
      await prefs.remove(_kSourceKey);
    } else {
      await prefs.setString(_kSourceKey, source);
    }
  }

  Future<DeepLinkIntent?> readValid() async {
    final prefs = await _prefsFuture;
    final location = prefs.getString(_kLocationKey);
    final receivedAtMs = prefs.getInt(_kReceivedAtMsKey);
    if (location == null || receivedAtMs == null) return null;

    if (receivedAtMs <= 0) {
      await clear();
      return null;
    }

    final receivedAt = DateTime.fromMillisecondsSinceEpoch(receivedAtMs);
    final age = _now().difference(receivedAt);
    if (age >= _ttl) {
      await clear();
      return null;
    }

    final source = prefs.getString(_kSourceKey);
    return DeepLinkIntent(
      location: location,
      receivedAt: receivedAt,
      source: source,
    );
  }

  Future<void> clear() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_kLocationKey);
    await prefs.remove(_kReceivedAtMsKey);
    await prefs.remove(_kSourceKey);
  }
}

