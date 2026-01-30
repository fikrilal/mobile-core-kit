import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/events/app_event.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';

class SessionManager {
  SessionManager(
    this._repository, {
    required TokenRefresher tokenRefresher,
    required AppEventBus events,
  }) : _tokenRefresher = tokenRefresher,
       _events = events;

  final SessionRepository _repository;
  final TokenRefresher _tokenRefresher;
  final StreamController<AuthSessionEntity?> _sessionController =
      StreamController<AuthSessionEntity?>.broadcast();
  final ValueNotifier<AuthSessionEntity?> _sessionNotifier =
      ValueNotifier<AuthSessionEntity?>(null);
  final AppEventBus _events;
  AuthSessionEntity? _currentSession;
  Future<void>? _initFuture;
  Future<void>? _restoreCachedUserFuture;

  Future<void> init() {
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = _initInternal();
    _initFuture = future;
    return future;
  }

  Future<void> _initInternal() async {
    try {
      _currentSession = await _repository.loadSession();
      Log.debug(
        'Session init: session loaded=${_currentSession != null}',
        name: 'SessionManager',
      );
      if (_currentSession != null) {
        Log.debug(
          'Session init: user cached=${_currentSession!.user != null}',
          name: 'SessionManager',
        );
      }
      _emit(_currentSession);

      // Best-effort: restore cached user *after* tokens are available without
      // blocking startup readiness.
      unawaited(restoreCachedUserIfNeeded());
    } catch (e) {
      _initFuture = null;
      rethrow;
    }
  }

  AuthSessionEntity? get session => _currentSession;
  bool get isAuthenticated => _currentSession != null;
  bool get isAuthPending =>
      _currentSession != null && _currentSession!.user == null;
  Stream<AuthSessionEntity?> get stream => _sessionController.stream;
  String? get accessToken => _currentSession?.tokens.accessToken;
  String? get refreshToken => _currentSession?.tokens.refreshToken;
  DateTime? get accessTokenExpiresAt => _currentSession?.tokens.expiresAt;

  static const Duration _accessTokenExpiryLeeway = Duration(minutes: 1);
  bool get isAccessTokenExpiringSoon {
    final expiresAt = accessTokenExpiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt.subtract(_accessTokenExpiryLeeway));
  }

  ValueListenable<AuthSessionEntity?> get sessionNotifier => _sessionNotifier;

  void dispose() {
    _sessionController.close();
    _sessionNotifier.dispose();
  }

  Future<void> restoreCachedUserIfNeeded() {
    final existing = _restoreCachedUserFuture;
    if (existing != null) return existing;

    final current = _currentSession;
    if (current == null) return Future.value();
    if (current.user != null) return Future.value();

    final accessTokenAtStart = current.tokens.accessToken;

    final future = () async {
      try {
        final cachedUser = await _repository.loadCachedUser();
        if (cachedUser == null) return;

        final latest = _currentSession;
        if (latest == null) return;
        if (latest.user != null) return;
        if (latest.tokens.accessToken != accessTokenAtStart) return;

        _currentSession = latest.copyWith(user: cachedUser);
        _emit(_currentSession);
      } catch (e, st) {
        Log.error(
          'Failed to restore cached user',
          e,
          st,
          true,
          'SessionManager',
        );
      } finally {
        _restoreCachedUserFuture = null;
      }
    }();

    _restoreCachedUserFuture = future;
    return future;
  }

  Future<void> login(AuthSessionEntity session) async {
    final enriched = session.copyWith(
      tokens: _withComputedExpiresAt(session.tokens),
    );
    Log.info('Login: saving session', name: 'SessionManager');
    await _repository.saveSession(enriched);
    _currentSession = enriched;
    Log.debug(
      'Login saved. user cached=${enriched.user != null}',
      name: 'SessionManager',
    );
    _emit(_currentSession);
  }

  Future<void> setUser(UserEntity user) async {
    final current = _currentSession;
    if (current == null) return;
    final updated = current.copyWith(user: user);
    await _repository.saveSession(updated);
    _currentSession = updated;
    _emit(_currentSession);
  }

  AuthSessionEntity _attachTokens(
    AuthSessionEntity session,
    AuthTokensEntity tokens,
  ) => session.copyWith(tokens: _withComputedExpiresAt(tokens));

  AuthTokensEntity _withComputedExpiresAt(AuthTokensEntity tokens) {
    if (tokens.expiresAt != null) return tokens;
    // A non-positive expiresIn is treated as "unknown" (temporary placeholder)
    // and must not trigger preflight refresh loops.
    if (tokens.expiresIn <= 0) return tokens;
    return tokens.copyWith(
      expiresAt: DateTime.now().add(Duration(seconds: tokens.expiresIn)),
    );
  }

  Future<bool> refreshTokens() async {
    final current = _currentSession;
    if (current == null) return false;
    final refreshTokenAtStart = current.tokens.refreshToken;
    Log.debug('Refreshing tokens…', name: 'SessionManager');
    final result = await _tokenRefresher.refresh(refreshTokenAtStart);

    return result.match(
      (SessionFailure failure) async {
        final shouldLogout = failure.isUnauthenticated;

        if (shouldLogout) {
          Log.error(
            'Refresh failed – logging out',
            Exception('Token refresh failure: $failure'),
            StackTrace.current,
            true,
            'SessionManager',
          );
          _events.publish(const SessionExpired(reason: 'refresh_failed'));
          await logout(reason: 'refresh_failed');
          return false;
        }

        Log.warning(
          'Refresh failed (not logging out): ${failure.type}',
          name: 'SessionManager',
        );
        return false;
      },
      (tokens) async {
        // Guard against races: if the session was cleared or replaced (e.g. user
        // logged out or switched accounts) while refresh was in-flight, do not
        // persist the refreshed tokens.
        final latest = _currentSession;
        if (latest == null) return false;
        if (latest.tokens.refreshToken != refreshTokenAtStart) return false;

        Log.debug('Refresh success. Tokens updated.', name: 'SessionManager');
        final updated = _attachTokens(latest, tokens);
        await _repository.saveSession(updated);
        Log.debug('Session persisted after refresh', name: 'SessionManager');
        _currentSession = updated;
        _emit(_currentSession);
        return true;
      },
    );
  }

  Future<void> logout({String reason = 'manual_logout'}) async {
    Log.info('Logout: clearing session', name: 'SessionManager');
    await _repository.clearSession();
    _currentSession = null;
    _emit(_currentSession);
    _events.publish(SessionCleared(reason: reason));
  }

  void _emit(AuthSessionEntity? session) {
    _sessionController.add(session);
    _sessionNotifier.value = session;
  }
}
