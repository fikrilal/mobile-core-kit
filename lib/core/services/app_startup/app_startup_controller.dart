import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app_launch/app_launch_service.dart';
import '../connectivity/connectivity_service.dart';
import '../connectivity/network_status.dart';
import '../startup_metrics/startup_metrics.dart';
import '../../session/session_manager.dart';
import '../../../features/user/domain/usecase/get_me_usecase.dart';
import '../../../features/auth/domain/failure/auth_failure.dart';
import '../../utilities/log_utils.dart';

enum AppStartupStatus { idle, initializing, ready }

class AppStartupController extends ChangeNotifier {
  AppStartupController({
    required AppLaunchService appLaunch,
    required ConnectivityService connectivity,
    required SessionManager sessionManager,
    required GetMeUseCase getMe,
    Duration sessionInitTimeout = const Duration(seconds: 5),
    Duration onboardingReadTimeout = const Duration(seconds: 2),
  }) : _appLaunch = appLaunch,
       _connectivity = connectivity,
       _sessionManager = sessionManager,
       _sessionInitTimeout = sessionInitTimeout,
       _onboardingReadTimeout = onboardingReadTimeout {
    _getMe = getMe;
    _sessionListener = () {
      notifyListeners();
      _maybeHydrateUser();
    };
    _sessionManager.sessionNotifier.addListener(_sessionListener);

    _connectivitySub = _connectivity.networkStatusStream.listen((status) {
      if (status == NetworkStatus.online) {
        _maybeHydrateUser(force: true);
      }
    });
  }

  final AppLaunchService _appLaunch;
  final ConnectivityService _connectivity;
  final SessionManager _sessionManager;
  late final GetMeUseCase _getMe;
  final Duration _sessionInitTimeout;
  final Duration _onboardingReadTimeout;
  late final VoidCallback _sessionListener;
  StreamSubscription<NetworkStatus>? _connectivitySub;

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
    if (!_sessionManager.isAuthPending) return;
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

    try {
      final result = await _getMe();
      await result.match(
        (AuthFailure failure) async {
          final shouldLogout = failure.maybeWhen(
            unauthenticated: () => true,
            orElse: () => false,
          );
          if (shouldLogout) {
            Log.info(
              'Hydrate user failed (unauthenticated). Clearing session.',
              name: 'AppStartupController',
            );
            await _sessionManager.logout(reason: 'hydrate_unauthenticated');
          } else {
            Log.warning(
              'Hydrate user failed (not logging out): ${failure.runtimeType}',
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
