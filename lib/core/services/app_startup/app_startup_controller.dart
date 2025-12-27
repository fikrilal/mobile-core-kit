import 'package:flutter/foundation.dart';

import '../app_launch/app_launch_service.dart';
import '../../session/session_manager.dart';
import '../../../features/user/domain/usecase/get_me_usecase.dart';
import '../../../features/auth/domain/failure/auth_failure.dart';
import '../../utilities/log_utils.dart';

enum AppStartupStatus { idle, initializing, ready }

class AppStartupController extends ChangeNotifier {
  AppStartupController({
    required AppLaunchService appLaunch,
    required SessionManager sessionManager,
    required GetMeUseCase getMe,
  }) : _appLaunch = appLaunch,
       _sessionManager = sessionManager {
    _getMe = getMe;
    _sessionListener = () => notifyListeners();
    _sessionManager.sessionNotifier.addListener(_sessionListener);
  }

  final AppLaunchService _appLaunch;
  final SessionManager _sessionManager;
  late final GetMeUseCase _getMe;
  late final VoidCallback _sessionListener;

  AppStartupStatus _status = AppStartupStatus.idle;
  bool? _shouldShowOnboarding;
  bool _didAttemptHydration = false;
  bool _isHydratingUser = false;

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

    _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();

    _status = AppStartupStatus.ready;
    notifyListeners();

    _maybeHydrateUser();
  }

  Future<void> completeOnboarding() async {
    await _appLaunch.markOnboardingSeen();
    _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();
    notifyListeners();

    _maybeHydrateUser();
  }

  void _maybeHydrateUser() {
    if (_didAttemptHydration) return;
    if (_shouldShowOnboarding ?? true) return;
    if (!_sessionManager.isAuthPending) return;

    _didAttemptHydration = true;
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
    _sessionManager.sessionNotifier.removeListener(_sessionListener);
    super.dispose();
  }
}
