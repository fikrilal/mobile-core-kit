import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_core_kit/core/di/composition/bootstrap_composer.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/crash_reporting/crashlytics_error_reporter.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_service.dart';
import 'package:mobile_core_kit/core/runtime/early_errors/early_error_buffer.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_listener.dart';
import 'package:mobile_core_kit/core/runtime/navigation/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_sync_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/runtime/startup/startup_metrics.dart';
import 'package:mobile_core_kit/firebase_options.dart';

class LocatorBootstrapPipeline {
  LocatorBootstrapPipeline({
    required GetIt locator,
    required void Function() registerLocator,
    Future<void> Function(GetIt locator)? runStartupCriticalStage,
    Future<void> Function()? runPlatformHeavyStage,
    Future<void> Function(GetIt locator)? runBackgroundBestEffortStage,
    Future<void> Function(GetIt locator)? reportStartupMetrics,
  }) : _locator = locator,
       _registerLocator = registerLocator,
       _runStartupCriticalStage =
           runStartupCriticalStage ?? _defaultRunStartupCriticalStage,
       _runPlatformHeavyStage =
           runPlatformHeavyStage ?? _defaultRunPlatformHeavyStage,
       _runBackgroundBestEffortStage =
           runBackgroundBestEffortStage ?? _defaultRunBackgroundBestEffortStage,
       _reportStartupMetrics =
           reportStartupMetrics ?? _defaultReportStartupMetrics;

  final GetIt _locator;
  final void Function() _registerLocator;
  final Future<void> Function(GetIt locator) _runStartupCriticalStage;
  final Future<void> Function() _runPlatformHeavyStage;
  final Future<void> Function(GetIt locator) _runBackgroundBestEffortStage;
  final Future<void> Function(GetIt locator) _reportStartupMetrics;

  Completer<void>? _bootstrapCompleter;

  Future<void> bootstrap() {
    final existing = _bootstrapCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<void>();
    _bootstrapCompleter = completer;
    StartupMetrics.instance.mark(StartupMilestone.bootstrapStart);

    () async {
      try {
        _registerLocator();

        final composer = BootstrapComposer(
          steps: [
            () => _runStageSafely(
              'Failed startup-critical bootstrap stage',
              () => _runStartupCriticalStage(_locator),
            ),
            () => _runStageSafely(
              'Failed platform-heavy bootstrap stage',
              _runPlatformHeavyStage,
            ),
            () => _runStageSafely(
              'Failed background bootstrap stage',
              () => _runBackgroundBestEffortStage(_locator),
            ),
          ],
        );
        await composer.compose();
      } catch (e, st) {
        Log.error('Failed to bootstrap dependencies', e, st, true, 'DI');
      } finally {
        StartupMetrics.instance.mark(StartupMilestone.bootstrapComplete);
        StartupMetrics.instance.logSummary();
        try {
          unawaited(_reportStartupMetrics(_locator));
        } catch (e, st) {
          Log.error('Failed to report startup metrics', e, st, false, 'DI');
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }();

    return completer.future;
  }

  void reset() {
    _bootstrapCompleter = null;
  }

  Future<void> _runStageSafely(
    String message,
    Future<void> Function() stage,
  ) async {
    try {
      await stage();
    } catch (e, st) {
      Log.error(message, e, st, false, 'DI');
    }
  }

  static Future<void> _defaultRunStartupCriticalStage(GetIt locator) async {
    // Run startup gate early so router can make correct initial decisions.
    try {
      // Best-effort: restore pending deep links while prerequisites settle.
      unawaited(locator<PendingDeepLinkController>().initialize());
      unawaited(locator<DeepLinkListener>().start());

      await locator<AppStartupController>().initialize();
    } catch (e, st) {
      Log.error('Failed to initialize startup controller', e, st, false, 'DI');
    }
  }

  static Future<void> _defaultRunPlatformHeavyStage() async {
    final metrics = StartupMetrics.instance;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      metrics.mark(StartupMilestone.firebaseInitialized);
    } catch (e, st) {
      Log.error('Failed to initialize Firebase', e, st, false, 'DI');
    }

    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        BuildConfig.env == BuildEnv.prod,
      );

      await EarlyErrorBuffer.instance.activate(
        CrashlyticsErrorReporter(FirebaseCrashlytics.instance),
      );

      metrics.mark(StartupMilestone.crashlyticsConfigured);
    } catch (e, st) {
      Log.error('Failed to configure Crashlytics', e, st, false, 'DI');
    }

    try {
      await initializeDateFormatting('en_US', '');
      metrics.mark(StartupMilestone.intlInitialized);
    } catch (e, st) {
      Log.error(
        'Failed to initialize Intl date formatting',
        e,
        st,
        false,
        'DI',
      );
    }
  }

  static Future<void> _defaultRunBackgroundBestEffortStage(
    GetIt locator,
  ) async {
    try {
      unawaited(locator<PushTokenSyncService>().init());
    } catch (e, st) {
      Log.error('Failed to initialize push token sync', e, st, false, 'DI');
    }

    try {
      await locator<IAnalyticsService>().initialize();
    } catch (e, st) {
      Log.error('Failed to initialize analytics', e, st, false, 'DI');
    }

    try {
      await locator<ConnectivityService>().initialize();
    } catch (e, st) {
      Log.error('Failed to initialize connectivity', e, st, false, 'DI');
    }
  }

  static Future<void> _defaultReportStartupMetrics(GetIt locator) {
    return StartupMetrics.instance.reportToAnalytics(
      locator<IAnalyticsService>(),
    );
  }
}
