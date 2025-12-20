import 'package:flutter/foundation.dart';

import '../app_launch/app_launch_service.dart';
import '../../session/session_manager.dart';

enum AppStartupStatus { idle, initializing, ready }

class AppStartupController extends ChangeNotifier {
  AppStartupController({
    required AppLaunchService appLaunch,
    required SessionManager sessionManager,
  }) : _appLaunch = appLaunch,
       _sessionManager = sessionManager {
    _sessionListener = () => notifyListeners();
    _sessionManager.sessionNotifier.addListener(_sessionListener);
  }

  final AppLaunchService _appLaunch;
  final SessionManager _sessionManager;
  late final VoidCallback _sessionListener;

  AppStartupStatus _status = AppStartupStatus.idle;
  bool? _shouldShowOnboarding;

  AppStartupStatus get status => _status;
  bool get isReady => _status == AppStartupStatus.ready;

  /// Whether onboarding should be shown on app start.
  ///
  /// This is null until [initialize] completes.
  bool? get shouldShowOnboarding => _shouldShowOnboarding;

  bool get isAuthenticated => _sessionManager.isAuthenticated;

  Future<void> initialize() async {
    if (_status == AppStartupStatus.ready) return;
    if (_status == AppStartupStatus.initializing) return;

    _status = AppStartupStatus.initializing;
    notifyListeners();

    _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();

    _status = AppStartupStatus.ready;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _appLaunch.markOnboardingSeen();
    _shouldShowOnboarding = await _appLaunch.shouldShowOnboarding();
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionManager.sessionNotifier.removeListener(_sessionListener);
    super.dispose();
  }
}
