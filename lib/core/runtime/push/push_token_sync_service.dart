import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/push/push_token_sync_store.dart';
import 'package:mobile_core_kit/core/platform/push/fcm_token_provider.dart';
import 'package:mobile_core_kit/core/platform/push/push_platform.dart';
import 'package:mobile_core_kit/core/runtime/push/push_error_codes.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';

/// Template-level orchestration for syncing push registration tokens to backend.
///
/// Responsibilities:
/// - Observe session lifecycle (signed-in / signed-out)
/// - Observe token rotation from FCM SDK
/// - Dedupe repeated calls via [PushTokenSyncStore]
/// - Apply cooldown when backend returns `PUSH_NOT_CONFIGURED`
///
/// Non-goals:
/// - Notification permission UX (product-driven)
/// - Push message handling/routing
class PushTokenSyncService {
  PushTokenSyncService({
    required SessionManager sessionManager,
    required FcmTokenProvider tokenProvider,
    required PushTokenRegistrar registrar,
    required PushTokenSyncStore store,
    Duration notConfiguredCooldown = const Duration(hours: 24),
    Duration retryCooldown = const Duration(seconds: 15),
    DateTime Function()? now,
  }) : _sessionManager = sessionManager,
       _tokenProvider = tokenProvider,
       _registrar = registrar,
       _store = store,
       _notConfiguredCooldown = notConfiguredCooldown,
       _retryCooldown = retryCooldown,
       _now = now ?? DateTime.now;

  final String _tag = 'PushTokenSyncService';
  final SessionManager _sessionManager;
  final FcmTokenProvider _tokenProvider;
  final PushTokenRegistrar _registrar;
  final PushTokenSyncStore _store;
  final Duration _notConfiguredCooldown;
  final Duration _retryCooldown;
  final DateTime Function() _now;

  late final VoidCallback _sessionListener;
  StreamSubscription<String>? _tokenRefreshSub;

  Future<void>? _initFuture;

  bool _isSyncing = false;
  DateTime? _lastAttemptAt;

  /// When an upsert fails with UNAUTHORIZED, stop further attempts for the
  /// current session key until the session changes.
  String? _unauthorizedSessionKey;

  /// Starts observing session + token changes and performs best-effort sync.
  ///
  /// Idempotent.
  Future<void> init() {
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = _initInternal();
    _initFuture = future;
    return future;
  }

  Future<void> _initInternal() async {
    _sessionListener = _onSessionChanged;
    _sessionManager.sessionNotifier.addListener(_sessionListener);

    _tokenRefreshSub = _tokenProvider.onTokenRefresh.listen((token) {
      // Token refresh can happen when signed-out; we only sync when a session is active.
      unawaited(_maybeSync(force: true, tokenOverride: token));
    });

    // Best-effort: if the app starts with an active session and an existing FCM
    // token, try to sync without waiting for a token refresh event.
    await _maybeSync(force: true);
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    if (_initFuture != null) {
      _sessionManager.sessionNotifier.removeListener(_sessionListener);
    }
  }

  void _onSessionChanged() {
    final refreshToken = _sessionManager.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      _unauthorizedSessionKey = null;
      // Do not clear store here; Phase 6 handles revoke/clear ordering.
      return;
    }

    // If the session changed, clear the unauthorized stop flag.
    if (_unauthorizedSessionKey != null &&
        _unauthorizedSessionKey != refreshToken) {
      _unauthorizedSessionKey = null;
    }

    unawaited(_maybeSync());
  }

  Future<void> _maybeSync({bool force = false, String? tokenOverride}) async {
    final platform = currentPushPlatformOrNull();
    if (platform == null) return;

    final refreshToken = _sessionManager.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;

    if (_unauthorizedSessionKey == refreshToken) return;

    if (_isSyncing) return;

    final now = _now();
    if (!force && _lastAttemptAt != null) {
      final diff = now.difference(_lastAttemptAt!);
      if (diff < _retryCooldown) return;
    }

    // Respect cooldown for `PUSH_NOT_CONFIGURED`.
    final notConfiguredUntil = await _store.readPushNotConfiguredUntil();
    if (notConfiguredUntil != null) {
      if (now.isBefore(notConfiguredUntil)) return;
      await _store.clearPushNotConfiguredUntil();
    }

    final token = tokenOverride ?? await _tokenProvider.getToken();
    if (token == null || token.trim().isEmpty) return;

    final deduped = await _store.isDeduped(
      sessionKey: refreshToken,
      token: token,
    );
    if (deduped) return;

    _lastAttemptAt = now;
    _isSyncing = true;

    final tokenLen = token.length;
    Log.info(
      'Syncing push token (platform=${platform.apiValue}, len=$tokenLen)',
      name: _tag,
    );

    try {
      final response = await _registrar.upsert(
        platform: platform,
        token: token,
      );

      // Guard against races: if session changed while the request was in-flight, ignore.
      if (_sessionManager.refreshToken != refreshToken) return;

      if (response.isSuccess) {
        await _store.writeLastSent(sessionKey: refreshToken, token: token);
        return;
      }

      final code = response.code;
      final statusCode = response.statusCode;

      final isUnauthorized =
          code == ApiErrorCodes.unauthorized || statusCode == 401;
      if (isUnauthorized) {
        _unauthorizedSessionKey = refreshToken;
        Log.debug('Push token sync skipped (unauthorized)', name: _tag);
        return;
      }

      if (code == PushErrorCodes.pushNotConfigured || statusCode == 501) {
        final until = now.add(_notConfiguredCooldown);
        await _store.writePushNotConfiguredUntil(until);
        Log.warning(
          'Push token sync disabled by backend (code=$code). Backing off until $until',
          name: _tag,
        );
        return;
      }

      Log.warning(
        'Push token sync failed (status=$statusCode, code=$code): ${response.message}',
        name: _tag,
      );
    } catch (e, st) {
      Log.warning('Push token sync unexpected error: $e', name: _tag);
      Log.debug('Stack trace: $st', name: _tag);
    } finally {
      _isSyncing = false;
    }
  }
}
