import 'package:firebase_analytics/firebase_analytics.dart';
import '../../configs/app_config.dart';
import '../../configs/build_config.dart';
import '../../utilities/log_utils.dart';
import 'analytics_events.dart';
import 'analytics_service.dart';

/// Low-level analytics implementation backed by Firebase Analytics.
///
/// This class should not be used directly from features. Prefer injecting
/// [IAnalyticsService] or using a higher-level tracker facade.
class AnalyticsServiceImpl implements IAnalyticsService {
  AnalyticsServiceImpl({FirebaseAnalytics? analytics, bool? initialEnabled})
    : _analytics = analytics,
      _analyticsEnabled = initialEnabled ?? BuildConfig.analyticsEnabledDefault;

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;
  bool _analyticsEnabled;
  static const String _tag = 'AnalyticsServiceImpl';

  bool get _debugLoggingEnabled =>
      BuildConfig.analyticsDebugLoggingEnabled &&
      AppConfig.instance.enableLogging;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final analytics = _analytics ?? FirebaseAnalytics.instance;
      _analytics = analytics;

      await analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);

      await analytics.setUserProperty(
        name: AnalyticsParams.appEnvironment,
        value: BuildConfig.env.name,
      );
      _isInitialized = true;
      Log.info(
        'Analytics initialized; collection ${_analyticsEnabled ? 'enabled' : 'disabled'}',
        name: _tag,
      );
    } catch (e, st) {
      Log.error('Failed to initialize analytics service', e, st, false, _tag);
    }
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    if (!_isInitialized) {
      if (_debugLoggingEnabled) {
        Log.warning(
          'Analytics not initialized, skipping event: $name',
          name: _tag,
        );
      }
      return;
    }

    if (!_analyticsEnabled) {
      if (_debugLoggingEnabled) {
        Log.debug(
          'Analytics disabled; would log event: $name | $parameters',
          name: _tag,
        );
      }
      return;
    }

    try {
      final analytics = _analytics;
      if (analytics == null) return;

      if (_debugLoggingEnabled) {
        Log.debug('Analytics event: $name | $parameters', name: _tag);
      }

      await analytics.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (e, st) {
      Log.error('Failed to log event $name', e, st, false, _tag);
    }
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    String? previousScreenName,
    Map<String, Object?>? parameters,
  }) async {
    final mergedParams = <String, Object?>{
      if (parameters != null) ...parameters,
      AnalyticsParams.screenName: screenName,
      if (previousScreenName != null)
        AnalyticsParams.previousScreenName: previousScreenName,
    };

    await logEvent(AnalyticsEvents.screenView, parameters: mergedParams);
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) {
      if (_debugLoggingEnabled) {
        Log.warning(
          'Analytics not initialized, skipping setUserId',
          name: _tag,
        );
      }
      return;
    }

    if (!_analyticsEnabled) {
      if (_debugLoggingEnabled) {
        Log.debug('Analytics disabled; would set user ID: $userId', name: _tag);
      }
      return;
    }

    try {
      final analytics = _analytics;
      if (analytics == null) return;

      if (_debugLoggingEnabled) {
        Log.debug('Setting analytics user ID: $userId', name: _tag);
      }

      await analytics.setUserId(id: userId);
    } catch (e, st) {
      Log.error('Failed to set user ID', e, st, false, _tag);
    }
  }

  @override
  Future<void> clearUser() async {
    if (!_isInitialized) {
      return;
    }

    try {
      final analytics = _analytics;
      if (analytics == null) return;

      if (_debugLoggingEnabled) {
        Log.debug('Clearing analytics user id & properties', name: _tag);
      }
      await analytics.setUserId(id: null);
      // Note: we don't clear all user properties here; projects can decide
      // which properties to reset on logout.
    } catch (e, st) {
      Log.error('Failed to clear user', e, st, false, _tag);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (!_isInitialized) {
      if (_debugLoggingEnabled) {
        Log.warning(
          'Analytics not initialized, skipping setUserProperty',
          name: _tag,
        );
      }
      return;
    }

    if (!_analyticsEnabled) {
      if (_debugLoggingEnabled) {
        Log.debug(
          'Analytics disabled; would set user property: $name = $value',
          name: _tag,
        );
      }
      return;
    }

    try {
      final analytics = _analytics;
      if (analytics == null) return;

      if (_debugLoggingEnabled) {
        Log.debug(
          'Setting analytics user property: $name = $value',
          name: _tag,
        );
      }

      await analytics.setUserProperty(name: name, value: value);
    } catch (e, st) {
      Log.error('Failed to set user property $name', e, st, false, _tag);
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      _analyticsEnabled = enabled;
      final analytics = _analytics;
      if (analytics == null) {
        Log.info(
          'Analytics collection ${enabled ? 'enabled' : 'disabled'} (pending init)',
          name: _tag,
        );
        return;
      }

      await analytics.setAnalyticsCollectionEnabled(enabled);
      Log.info(
        'Analytics collection ${enabled ? 'enabled' : 'disabled'}',
        name: _tag,
      );
    } catch (e, st) {
      Log.error(
        'Failed to set analytics collection enabled',
        e,
        st,
        false,
        _tag,
      );
    }
  }

  @override
  bool isAnalyticsCollectionEnabled() {
    return _analyticsEnabled;
  }
}
