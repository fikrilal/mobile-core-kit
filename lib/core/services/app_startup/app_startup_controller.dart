import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app_launch/app_launch_service.dart';
import '../connectivity/connectivity_service.dart';
import '../connectivity/network_status.dart';
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
  }) : _appLaunch = appLaunch,
       _connectivity = connectivity,
       _sessionManager = sessionManager {
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

    try {
      _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();
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
    notifyListeners();

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
        (failure) async {
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
