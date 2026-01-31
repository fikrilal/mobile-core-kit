import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/name_utils.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/user_context/current_user_state.dart';

/// Template-level service for reading the current signed-in user ("me").
///
/// This service is intentionally small:
/// - It observes [SessionManager.sessionNotifier] and exposes a stable view model
///   for UI and shared services.
/// - It can trigger an explicit refresh via [CurrentUserFetcher] (network) with
///   single-flight semantics and race guards.
class UserContextService {
  UserContextService({
    required SessionManager sessionManager,
    required CurrentUserFetcher currentUserFetcher,
    required AppEventBus events,
    DateTime Function()? now,
  }) : _sessionManager = sessionManager,
       _currentUserFetcher = currentUserFetcher,
       _events = events,
       _now = now ?? DateTime.now {
    _sessionListener = _syncFromSession;
    _sessionManager.sessionNotifier.addListener(_sessionListener);
    _eventsSub = _events.stream.listen(_onEvent);
    _syncFromSession();
  }

  final SessionManager _sessionManager;
  final CurrentUserFetcher _currentUserFetcher;
  final AppEventBus _events;
  final DateTime Function() _now;

  late final VoidCallback _sessionListener;
  StreamSubscription<AppEvent>? _eventsSub;

  final ValueNotifier<CurrentUserState> _state =
      ValueNotifier<CurrentUserState>(const CurrentUserState.signedOut());

  Future<Either<SessionFailure, UserEntity>>? _refreshFuture;
  String? _refreshSessionKey;

  ValueListenable<CurrentUserState> get stateListenable => _state;
  CurrentUserState get state => _state.value;
  UserEntity? get user => _state.value.user;

  bool get isAuthenticated => _state.value.isAuthenticated;
  bool get isAuthPending => _state.value.isAuthPending;
  bool get hasUser => _state.value.hasUser;

  String? get email => user?.email;

  String? get displayName {
    final u = user;
    if (u == null) return null;
    final profile = u.profile;
    final explicitDisplayName = profile.displayName?.trim();
    if (explicitDisplayName != null && explicitDisplayName.isNotEmpty) {
      return explicitDisplayName;
    }

    final given = profile.givenName?.trim();
    final family = profile.familyName?.trim();
    final hasGiven = given != null && given.isNotEmpty;
    final hasFamily = family != null && family.isNotEmpty;
    if (hasGiven && hasFamily) return '$given $family';
    if (hasGiven) return given;
    if (hasFamily) return family;
    return u.email.trim().isEmpty ? null : u.email;
  }

  String? get initials => NameUtils.initialsFrom(displayName ?? email);

  Future<Either<SessionFailure, UserEntity>> ensureUserFresh({
    String reason = 'ensure_user_fresh',
  }) async {
    final existing = user;
    if (existing != null) return right<SessionFailure, UserEntity>(existing);
    return refreshUser(reason: reason);
  }

  Future<Either<SessionFailure, UserEntity>> refreshUser({
    String reason = 'refresh_user',
    bool logoutOnUnauthenticated = true,
  }) async {
    final refreshTokenAtStart = _sessionManager.refreshToken;
    if (refreshTokenAtStart == null || refreshTokenAtStart.isEmpty) {
      return left<SessionFailure, UserEntity>(
        const SessionFailure.unauthenticated(),
      );
    }

    final existingFuture = _refreshFuture;
    if (existingFuture != null && _refreshSessionKey == refreshTokenAtStart) {
      return existingFuture;
    }

    _refreshSessionKey = refreshTokenAtStart;

    final Future<Either<SessionFailure, UserEntity>> future = () async {
      _state.value = _state.value.copyWith(
        isRefreshing: true,
        lastFailure: null,
        lastFailureIsSet: true,
      );

      try {
        final result = await _currentUserFetcher.fetch();

        // Guard: if the session changed while the request was in-flight, ignore.
        if (_sessionManager.refreshToken != refreshTokenAtStart) {
          return left<SessionFailure, UserEntity>(
            const SessionFailure.unexpected('session_changed'),
          );
        }

        return result.match(
          (failure) async {
            _state.value = _state.value.copyWith(
              lastFailure: failure,
              lastFailureIsSet: true,
              lastRefreshedAt: _now(),
              lastRefreshedAtIsSet: true,
            );

            if (logoutOnUnauthenticated && failure.isUnauthenticated) {
              await _sessionManager.logout(
                reason: 'user_refresh_unauthenticated',
              );
            }

            return left<SessionFailure, UserEntity>(failure);
          },
          (user) async {
            await _sessionManager.setUser(user);
            _state.value = _state.value.copyWith(
              lastFailure: null,
              lastFailureIsSet: true,
              lastRefreshedAt: _now(),
              lastRefreshedAtIsSet: true,
            );
            return right<SessionFailure, UserEntity>(user);
          },
        );
      } finally {
        _state.value = _state.value.copyWith(isRefreshing: false);
        _refreshFuture = null;
        _refreshSessionKey = null;
      }
    }();

    _refreshFuture = future;
    return future;
  }

  void dispose() {
    _eventsSub?.cancel();
    _sessionManager.sessionNotifier.removeListener(_sessionListener);
    _state.dispose();
  }

  void _syncFromSession() {
    final session = _sessionManager.sessionNotifier.value;
    if (session == null) {
      _state.value = const CurrentUserState.signedOut();
      return;
    }

    final user = session.user;
    if (user == null) {
      _state.value = _state.value.copyWith(
        status: CurrentUserStatus.authPending,
        user: null,
        userIsSet: true,
      );
      return;
    }

    _state.value = _state.value.copyWith(
      status: CurrentUserStatus.available,
      user: user,
      userIsSet: true,
    );
  }

  void _onEvent(AppEvent event) {
    switch (event) {
      case SessionCleared():
      case SessionExpired():
        // Clear any derived caches/slices and in-flight work. Do not attempt to
        // own session lifecycle here; [SessionManager] remains the source of truth.
        _refreshFuture = null;
        _refreshSessionKey = null;
        _state.value = _state.value.copyWith(
          isRefreshing: false,
          lastFailure: null,
          lastFailureIsSet: true,
          lastRefreshedAt: null,
          lastRefreshedAtIsSet: true,
        );
        // Re-sync to avoid transient inconsistency if events are published
        // slightly before the session notifier updates.
        _syncFromSession();
      default:
        return;
    }
  }
}
