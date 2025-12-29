import 'dart:async';

import 'package:get_it/get_it.dart';
import '../services/navigation/navigation_service.dart';
import '../events/app_event_bus.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/connectivity/connectivity_service_impl.dart';
import '../services/analytics/analytics_service.dart';
import '../services/analytics/analytics_service_impl.dart';
import '../services/analytics/analytics_tracker.dart';
import '../services/app_launch/app_launch_service.dart';
import '../services/app_launch/app_launch_service_impl.dart';
import '../services/app_startup/app_startup_controller.dart';
import '../services/startup_metrics/startup_metrics.dart';
import '../network/api/api_client.dart';
import '../network/api/api_helper.dart';
import '../network/logging/network_log_config.dart';
import '../utilities/log_utils.dart';
import '../../features/auth/di/auth_module.dart';
import '../../features/user/di/user_module.dart';
import '../../features/user/domain/usecase/get_me_usecase.dart';
import '../session/session_manager.dart';

/// Global service locator – access via `locator<MyType>()` anywhere in the codebase.
final GetIt locator = GetIt.instance;

/// Shorthand getter for the service locator.
GetIt get getIt => locator;

Completer<void>? _bootstrapCompleter;

/// Registers all application-wide dependencies (sync, no IO).
///
/// Keep this function fast because it is expected to run **before** `runApp()`.
/// All heavy initialization work should go into [bootstrapLocator].
void registerLocator() {
  // Core services
  if (!locator.isRegistered<NavigationService>()) {
    locator.registerLazySingleton<NavigationService>(() => NavigationService());
  }

  if (!locator.isRegistered<AppEventBus>()) {
    locator.registerLazySingleton<AppEventBus>(() => AppEventBus());
  }

  if (!locator.isRegistered<ConnectivityService>()) {
    locator.registerLazySingleton<ConnectivityService>(
      () => ConnectivityServiceImpl(),
    );
  }

  if (!locator.isRegistered<AppLaunchService>()) {
    locator.registerLazySingleton<AppLaunchService>(() => AppLaunchServiceImpl());
  }

  if (!locator.isRegistered<AppStartupController>()) {
    locator.registerLazySingleton<AppStartupController>(
      () => AppStartupController(
        appLaunch: locator<AppLaunchService>(),
        connectivity: locator<ConnectivityService>(),
        sessionManager: locator<SessionManager>(),
        getMe: locator<GetMeUseCase>(),
      ),
    );
  }

  if (!locator.isRegistered<IAnalyticsService>()) {
    locator.registerLazySingleton<IAnalyticsService>(
      () => AnalyticsServiceImpl(),
    );
  }

  if (!locator.isRegistered<AnalyticsTracker>()) {
    locator.registerLazySingleton<AnalyticsTracker>(
      () => AnalyticsTracker(locator<IAnalyticsService>()),
    );
  }

  // Network logging config (must be initialized before ApiClient)
  NetworkLogConfig.initFromBuildConfig();

  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(() => ApiClient()..init());
  }

  if (!locator.isRegistered<ApiHelper>()) {
    locator.registerLazySingleton<ApiHelper>(
      () => ApiHelper(
        locator<ApiClient>().dio,
        connectivity: locator<ConnectivityService>(),
      ),
    );
  }

  // Feature modules
  AuthModule.register(locator);
  UserModule.register(locator);
}

/// Initializes dependencies that require async work (disk, platform channels).
///
/// This is safe to call multiple times; initialization runs once per process.
Future<void> bootstrapLocator() {
  final existing = _bootstrapCompleter;
  if (existing != null) return existing.future;

  final completer = Completer<void>();
  _bootstrapCompleter = completer;
  StartupMetrics.instance.mark(StartupMilestone.bootstrapStart);

  () async {
    try {
      registerLocator();

      // Run the startup gate first so the router can make correct initial
      // decisions as early as possible (session + onboarding).
      try {
        await locator<AppStartupController>().initialize();
      } catch (e, st) {
        Log.error('Failed to initialize startup controller', e, st, false, 'DI');
      }

      // Optional initializations: failures should not block the app from starting.
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
    } catch (e, st) {
      Log.error('Failed to bootstrap dependencies', e, st, true, 'DI');
    } finally {
      StartupMetrics.instance.mark(StartupMilestone.bootstrapComplete);
      StartupMetrics.instance.logSummary();
      // Report startup timings once analytics is available (best-effort).
      try {
        unawaited(
          StartupMetrics.instance.reportToAnalytics(locator<IAnalyticsService>()),
        );
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

/// Convenience wrapper for apps that still want a single entry point.
Future<void> setupLocator() async {
  registerLocator();
  await bootstrapLocator();
}

/// Resets the service locator (useful for testing).
Future<void> resetLocator() async {
  _bootstrapCompleter = null;
  await locator.reset();
}
