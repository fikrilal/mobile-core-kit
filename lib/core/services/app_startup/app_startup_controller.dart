import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/services/startup_metrics/startup_metrics.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';

enum AppStartupStatus { idle, initializing, ready }

class AppStartupController extends ChangeNotifier {
  AppStartupController({
    required AppLaunchService appLaunch,
    required ConnectivityService connectivity,
    required SessionManager sessionManager,
    required CurrentUserFetcher currentUserFetcher,
    Duration sessionInitTimeout = const Duration(seconds: 5),
    Duration onboardingReadTimeout = const Duration(seconds: 2),
  }) : _appLaunch = appLaunch,
       _connectivity = connectivity,
       _sessionManager = sessionManager,
       _sessionInitTimeout = sessionInitTimeout,
       _onboardingReadTimeout = onboardingReadTimeout {
    _currentUserFetcher = currentUserFetcher;
    _sessionListener = () {
      notifyListeners();
      _maybeHydrateUser();
    };
    _sessionManager.sessionNotifier.addListener(_sessionListener);

    _connectivitySub = _connectivity.networkStatusStream.listen((status) {
      final wasOffline = _lastNetworkStatus == NetworkStatus.offline;
      _lastNetworkStatus = status;

      if (status == NetworkStatus.online) {
        // If connectivity flaps and emits repeated `online` values, apply the
        // cooldown to avoid request spam. Only bypass the cooldown when we
        // observed an offline -> online transition.
        _maybeHydrateUser(force: wasOffline);
      }
    });
  }

  final AppLaunchService _appLaunch;
  final ConnectivityService _connectivity;
  final SessionManager _sessionManager;
  late final CurrentUserFetcher _currentUserFetcher;
  final Duration _sessionInitTimeout;
  final Duration _onboardingReadTimeout;
  late final VoidCallback _sessionListener;
  StreamSubscription<NetworkStatus>? _connectivitySub;
  NetworkStatus? _lastNetworkStatus;

  AppStartupStatus _status = AppStartupStatus.idle;
  bool? _shouldShowOnboarding;
  bool _isHydratingUser = false;
  DateTime? _lastHydrationAttemptAt;

  static const Duration _hydrationCooldown = Duration(seconds: 15);

  AppStartupStatus get status => _status;
  bool get isReady => _status == AppStartupStatus.ready;

  /// Whether onboarding should be shown on app start.
  ///
  /// This is null until [initialize] completes.
  bool? get shouldShowOnboarding => _shouldShowOnboarding;

  bool get isAuthenticated => _sessionManager.isAuthenticated;
  bool get isAuthPending => _sessionManager.isAuthPending;
  UserEntity? get user => _sessionManager.sessionNotifier.value?.user;

  /// Whether the app should fetch `GET /v1/me` to hydrate user data.
  ///
  /// The template treats `MeDto.roles` as a hydration marker:
  /// - Auth responses (`AuthUserDto`) omit roles, so an auth-derived user will
  ///   typically have `roles = []`.
  /// - `/v1/me` always returns roles (and other profile fields).
  bool get needsUserHydration {
    final session = _sessionManager.sessionNotifier.value;
    if (session == null) return false;
    final u = session.user;
    if (u == null) return true;
    return u.roles.isEmpty;
  }

  /// Whether the user must complete required profile fields before proceeding.
  ///
  /// This only becomes `true` once the user has been hydrated from `/v1/me`.
  bool get needsProfileCompletion {
    final u = user;
    if (u == null) return false;
    if (u.roles.isEmpty) return false;
    final given = u.profile.givenName?.trim();
    return given == null || given.isEmpty;
  }

  Future<void> initialize() async {
    if (_status == AppStartupStatus.ready) return;
    if (_status == AppStartupStatus.initializing) return;

    _status = AppStartupStatus.initializing;
    notifyListeners();

    // Load persisted session tokens before deciding initial routing.
    try {
      await _sessionManager.init().timeout(_sessionInitTimeout);
    } on TimeoutException catch (e, st) {
      Log.error(
        'Timed out loading persisted session after $_sessionInitTimeout. Continuing as signed-out.',
        e,
        st,
        false,
        'AppStartupController',
      );
    } catch (e, st) {
      Log.error(
        'Failed to load persisted session. Continuing as signed-out.',
        e,
        st,
        false,
        'AppStartupController',
      );
    }

    // Best-effort: restore cached user without blocking startup readiness.
    final restoreCachedUserFuture = _sessionManager.restoreCachedUserIfNeeded();

    try {
      _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding().timeout(
        _onboardingReadTimeout,
      );
    } on TimeoutException catch (e, st) {
      // Fail open: if we cannot read persisted onboarding state, default to
      // showing onboarding instead of blocking app startup forever.
      _shouldShowOnboarding = true;
      Log.error(
        'Timed out reading onboarding state after $_onboardingReadTimeout. Defaulting to show onboarding.',
        e,
        st,
        true,
        'AppStartupController',
      );
    } catch (e, st) {
      // Fail open: if we cannot read persisted onboarding state, default to
      // showing onboarding instead of blocking app startup forever.
      _shouldShowOnboarding = true;
      Log.error(
        'Failed to read onboarding state. Defaulting to show onboarding.',
        e,
        st,
        true,
        'AppStartupController',
      );
    }

    _status = AppStartupStatus.ready;
    StartupMetrics.instance.mark(StartupMilestone.startupReady);
    notifyListeners();

    unawaited(_maybeHydrateUserAfterCachedUserRestore(restoreCachedUserFuture));
  }

  Future<void> _maybeHydrateUserAfterCachedUserRestore(
    Future<void> restoreCachedUserFuture,
  ) async {
    if (!_sessionManager.isAuthPending) return;

    try {
      await restoreCachedUserFuture.timeout(const Duration(milliseconds: 250));
    } catch (_) {
      // Best-effort: continue with hydration if restoring cached user is slow or fails.
    }

    _maybeHydrateUser(force: true);
  }

  Future<void> completeOnboarding() async {
    await _appLaunch.markOnboardingSeen();
    _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();
    notifyListeners();

    _maybeHydrateUser(force: true);
  }

  void _maybeHydrateUser({bool force = false}) {
    if (_shouldShowOnboarding ?? true) return;
    if (!needsUserHydration) return;
    if (_isHydratingUser) return;

    final now = DateTime.now();
    if (!force && _lastHydrationAttemptAt != null) {
      final diff = now.difference(_lastHydrationAttemptAt!);
      if (diff < _hydrationCooldown) return;
    }

    _lastHydrationAttemptAt = now;
    _hydrateUser();
  }

  Future<void> _hydrateUser() async {
    if (_isHydratingUser) return;
    _isHydratingUser = true;
    final refreshTokenAtStart = _sessionManager.refreshToken;

    try {
      final result = await _currentUserFetcher.fetch();

      // Guard against races: if the session changed (logout, account switch,
      // token rotation) while the request was in-flight, ignore the result.
      if (refreshTokenAtStart == null ||
          _sessionManager.refreshToken != refreshTokenAtStart) {
        return;
      }

      await result.match(
        (SessionFailure failure) async {
          final shouldLogout = failure.isUnauthenticated;
          if (shouldLogout) {
            Log.info(
              'Hydrate user failed (unauthenticated). Clearing session.',
              name: 'AppStartupController',
            );
            await _sessionManager.logout(reason: 'hydrate_unauthenticated');
          } else {
            Log.warning(
              'Hydrate user failed (not logging out): ${failure.type}',
              name: 'AppStartupController',
            );
          }
        },
        (user) async {
          await _sessionManager.setUser(user);
        },
      );
    } catch (e, st) {
      Log.error(
        'Hydrate user unexpected error',
        e,
        st,
        true,
        'AppStartupController',
      );
    } finally {
      _isHydratingUser = false;
    }
  }

  @override
  void dispose() {
    unawaited(_connectivitySub?.cancel());
    _sessionManager.sessionNotifier.removeListener(_sessionListener);
    super.dispose();
  }
}
