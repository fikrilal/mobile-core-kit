import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/navigation/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_intent.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_telemetry.dart';

/// Holds a single "pending deep link" intent and exposes it as a [Listenable]
/// so GoRouter can refresh redirect decisions when it changes.
///
/// Policy:
/// - persisted with TTL via [PendingDeepLinkStore]
/// - last intent wins
/// - redirect-time mutations should not call `notifyListeners()` to avoid
///   re-entrancy/loops in router redirects
class PendingDeepLinkController extends ChangeNotifier {
  PendingDeepLinkController({
    required PendingDeepLinkStore store,
    required DeepLinkParser parser,
    DeepLinkTelemetry? telemetry,
    DateTime Function()? now,
  }) : _store = store,
       _parser = parser,
       _telemetry = telemetry,
       _now = now ?? DateTime.now;

  final PendingDeepLinkStore _store;
  final DeepLinkParser _parser;
  final DeepLinkTelemetry? _telemetry;
  final DateTime Function() _now;

  DeepLinkIntent? _pending;
  DeepLinkIntent? _inFlightRedirectResume;
  Future<void>? _initFuture;

  DeepLinkIntent? get pending => _pending;
  String? get pendingLocation => _pending?.location;
  bool get hasPending => pendingLocation != null;

  Future<void> initialize() {
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = _initializeInternal();
    _initFuture = future;
    return future;
  }

  Future<void> _initializeInternal() async {
    try {
      final loaded = await _store.readValid();
      _pending = loaded;
      _inFlightRedirectResume = null;
      notifyListeners();
    } catch (_) {
      // Best-effort: deep link persistence should never break startup.
      _pending = null;
      _inFlightRedirectResume = null;
    }
  }

  /// Sets a pending deep link location (last intent wins) and persists it.
  ///
  /// Use this for link events received outside of router redirects (e.g. from
  /// a platform deep link stream).
  Future<void> setPendingLocation(
    String location, {
    String? source,
    String reason = 'set',
  }) async {
    if (!_parser.isAllowedInternalLocation(location)) return;

    final previous = _pending;
    _pending = DeepLinkIntent(
      location: location,
      receivedAt: _now(),
      source: source,
    );
    _inFlightRedirectResume = null;
    try {
      await _store.save(_pending!);
    } catch (_) {
      // Persistence failure should not prevent in-memory behavior.
    }
    final telemetry = _telemetry;
    if (telemetry != null) {
      unawaited(
        telemetry.trackPendingSet(
          _pending!,
          reason: reason,
          previous: previous,
        ),
      );
    }
    notifyListeners();
  }

  /// Convenience helper for HTTPS deep links (universal/app links).
  Future<void> setPendingFromExternalUri(
    Uri uri, {
    String source = 'https',
  }) async {
    final location = _parser.parseExternalUri(uri);
    if (location == null) return;
    await setPendingLocation(location, source: source, reason: 'external');
  }

  /// Sets pending intent during a GoRouter redirect without notifying.
  ///
  /// This avoids re-entrant refresh/redirect cycles.
  void setPendingLocationForRedirect(
    String location, {
    String? source,
    String reason = 'redirect',
  }) {
    if (!_parser.isAllowedInternalLocation(location)) return;
    if (_pending?.location == location) return;

    final previous = _pending;
    _pending = DeepLinkIntent(
      location: location,
      receivedAt: _now(),
      source: source,
    );
    _inFlightRedirectResume = null;

    unawaited(_store.save(_pending!));
    final telemetry = _telemetry;
    if (telemetry != null) {
      unawaited(
        telemetry.trackPendingSet(
          _pending!,
          reason: reason,
          previous: previous,
        ),
      );
    }
  }

  /// Consumes the pending intent during a GoRouter redirect (no notify).
  ///
  /// Clears persistence best-effort. Returns the consumed intent, or null.
  DeepLinkIntent? consumePendingIntentForRedirect() {
    final intent = _pending;
    if (intent == null) return _inFlightRedirectResume;

    _inFlightRedirectResume = intent;
    _pending = null;
    unawaited(_store.clear());
    final telemetry = _telemetry;
    if (telemetry != null) {
      unawaited(telemetry.trackResumed(intent));
    }
    return intent;
  }

  /// Consumes the pending location during a GoRouter redirect (no notify).
  ///
  /// Clears persistence best-effort. Returns the consumed location, or null.
  String? consumePendingLocationForRedirect() {
    return consumePendingIntentForRedirect()?.location;
  }

  /// Clears in-flight redirect resume state once the router arrives there.
  ///
  /// This is used to avoid stale "resume target" carry-over after successful
  /// redirect resumption in multi-pass GoRouter redirect evaluation.
  void acknowledgeRedirectLocation(String location) {
    final resume = _inFlightRedirectResume;
    if (resume == null) return;
    if (!_matchesLocation(resume.location, location)) return;
    _inFlightRedirectResume = null;
  }

  Future<void> clear({String reason = 'clear'}) async {
    final previous = _pending;
    _pending = null;
    _inFlightRedirectResume = null;
    try {
      await _store.clear();
    } catch (_) {
      // Best-effort.
    }
    if (previous != null) {
      final telemetry = _telemetry;
      if (telemetry != null) {
        unawaited(telemetry.trackCleared(previous, reason: reason));
      }
    }
    notifyListeners();
  }

  static bool _matchesLocation(String a, String b) {
    final ua = Uri.parse(a);
    final ub = Uri.parse(b);
    final pathA = _normalizePath(ua.path);
    final pathB = _normalizePath(ub.path);
    return pathA == pathB && ua.query == ub.query;
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    if (path == '/') return '/';
    if (path.endsWith('/')) return path.substring(0, path.length - 1);
    return path;
  }
}
