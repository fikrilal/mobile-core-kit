import 'dart:async';

import 'package:flutter/foundation.dart';

import 'deep_link_intent.dart';
import 'deep_link_parser.dart';
import 'pending_deep_link_store.dart';

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
    DateTime Function()? now,
  }) : _store = store,
       _parser = parser,
       _now = now ?? DateTime.now;

  final PendingDeepLinkStore _store;
  final DeepLinkParser _parser;
  final DateTime Function() _now;

  DeepLinkIntent? _pending;
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
      notifyListeners();
    } catch (_) {
      // Best-effort: deep link persistence should never break startup.
      _pending = null;
    }
  }

  /// Sets a pending deep link location (last intent wins) and persists it.
  ///
  /// Use this for link events received outside of router redirects (e.g. from
  /// a platform deep link stream).
  Future<void> setPendingLocation(
    String location, {
    String? source,
  }) async {
    if (!_parser.isAllowedInternalLocation(location)) return;

    _pending = DeepLinkIntent(
      location: location,
      receivedAt: _now(),
      source: source,
    );
    try {
      await _store.save(_pending!);
    } catch (_) {
      // Persistence failure should not prevent in-memory behavior.
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
    await setPendingLocation(location, source: source);
  }

  /// Sets pending intent during a GoRouter redirect without notifying.
  ///
  /// This avoids re-entrant refresh/redirect cycles.
  void setPendingLocationForRedirect(
    String location, {
    String? source,
  }) {
    if (!_parser.isAllowedInternalLocation(location)) return;

    _pending = DeepLinkIntent(
      location: location,
      receivedAt: _now(),
      source: source,
    );

    unawaited(_store.save(_pending!));
  }

  /// Consumes the pending location during a GoRouter redirect (no notify).
  ///
  /// Clears persistence best-effort. Returns the consumed location, or null.
  String? consumePendingLocationForRedirect() {
    final location = _pending?.location;
    if (location == null) return null;

    _pending = null;
    unawaited(_store.clear());
    return location;
  }

  Future<void> clear() async {
    _pending = null;
    try {
      await _store.clear();
    } catch (_) {
      // Best-effort.
    }
    notifyListeners();
  }
}

