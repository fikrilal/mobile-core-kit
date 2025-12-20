import 'package:shared_preferences/shared_preferences.dart';
import 'app_launch_service.dart';

class AppLaunchServiceImpl implements AppLaunchService {
  static const int _kOnboardingVersion = 1;
  static const String _kOnboardingSeenVersionKey = 'onboarding_seen_version';

  AppLaunchServiceImpl({
    Future<SharedPreferences>? prefs,
    bool forceShowOnboarding = false,
  }) : _prefsFuture = prefs ?? SharedPreferences.getInstance(),
       _forceShowOnboarding = forceShowOnboarding;

  final Future<SharedPreferences> _prefsFuture;
  final bool _forceShowOnboarding;
  int? _seenOnboardingVersionCache;

  @override
  Future<bool> shouldShowOnboarding() async {
    final cached = _seenOnboardingVersionCache;
    if (cached != null) return cached < _kOnboardingVersion;
    if (_forceShowOnboarding) {
      _seenOnboardingVersionCache = 0;
      return true;
    }
    final prefs = await _prefsFuture;
    final seenVersion = prefs.getInt(_kOnboardingSeenVersionKey) ?? 0;
    _seenOnboardingVersionCache = seenVersion;
    return seenVersion < _kOnboardingVersion;
  }

  @override
  Future<void> markOnboardingSeen() async {
    if (_forceShowOnboarding) {
      _seenOnboardingVersionCache = _kOnboardingVersion;
      return;
    }
    _seenOnboardingVersionCache = _kOnboardingVersion;
    final prefs = await _prefsFuture;
    await prefs.setInt(_kOnboardingSeenVersionKey, _kOnboardingVersion);
  }
}
