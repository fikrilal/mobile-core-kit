import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/network/api/api_client.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/logging/network_log_config.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_service.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_service_impl.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service_impl.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_store.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service_impl.dart';
import 'package:mobile_core_kit/core/services/deep_link/app_links_deep_link_source.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_listener.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_source.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_telemetry.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_identity_service_impl.dart';
import 'package:mobile_core_kit/core/services/early_errors/crashlytics_error_reporter.dart';
import 'package:mobile_core_kit/core/services/early_errors/early_error_buffer.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service_impl.dart';
import 'package:mobile_core_kit/core/services/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/services/localization/locale_store.dart';
import 'package:mobile_core_kit/core/services/navigation/navigation_service.dart';
import 'package:mobile_core_kit/core/services/startup_metrics/startup_metrics.dart';
import 'package:mobile_core_kit/core/services/user_context/user_context_service.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/auth/di/auth_module.dart';
import 'package:mobile_core_kit/features/user/di/user_module.dart';
import 'package:mobile_core_kit/firebase_options.dart';

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
    locator.registerLazySingleton<AppEventBus>(
      () => AppEventBus(),
      dispose: (bus) => bus.dispose(),
    );
  }

  if (!locator.isRegistered<ConnectivityService>()) {
    locator.registerLazySingleton<ConnectivityService>(
      () => ConnectivityServiceImpl(),
      dispose: (service) => service.dispose(),
    );
  }

  if (!locator.isRegistered<AppLaunchService>()) {
    locator.registerLazySingleton<AppLaunchService>(
      () => AppLaunchServiceImpl(),
    );
  }

  if (!locator.isRegistered<ThemeModeStore>()) {
    locator.registerLazySingleton<ThemeModeStore>(() => ThemeModeStore());
  }

  if (!locator.isRegistered<ThemeModeController>()) {
    locator.registerLazySingleton<ThemeModeController>(
      () => ThemeModeController(store: locator<ThemeModeStore>()),
    );
  }

  if (!locator.isRegistered<LocaleStore>()) {
    locator.registerLazySingleton<LocaleStore>(() => LocaleStore());
  }

  if (!locator.isRegistered<LocaleController>()) {
    locator.registerLazySingleton<LocaleController>(
      () => LocaleController(store: locator<LocaleStore>()),
    );
  }

  if (!locator.isRegistered<DeepLinkParser>()) {
    locator.registerLazySingleton<DeepLinkParser>(() => DeepLinkParser());
  }

  if (!locator.isRegistered<DeepLinkSource>()) {
    locator.registerLazySingleton<DeepLinkSource>(
      () => AppLinksDeepLinkSource(),
    );
  }

  if (!locator.isRegistered<DeepLinkTelemetry>()) {
    locator.registerLazySingleton<DeepLinkTelemetry>(
      () => DeepLinkTelemetry(analytics: locator<AnalyticsTracker>()),
    );
  }

  if (!locator.isRegistered<PendingDeepLinkStore>()) {
    locator.registerLazySingleton<PendingDeepLinkStore>(
      () => PendingDeepLinkStore(),
    );
  }

  if (!locator.isRegistered<PendingDeepLinkController>()) {
    locator.registerLazySingleton<PendingDeepLinkController>(
      () => PendingDeepLinkController(
        store: locator<PendingDeepLinkStore>(),
        parser: locator<DeepLinkParser>(),
        telemetry: locator<DeepLinkTelemetry>(),
      ),
      dispose: (controller) => controller.dispose(),
    );
  }

  if (!locator.isRegistered<DeepLinkListener>()) {
    locator.registerLazySingleton<DeepLinkListener>(
      () => DeepLinkListener(
        source: locator<DeepLinkSource>(),
        navigation: locator<NavigationService>(),
        deepLinks: locator<PendingDeepLinkController>(),
        parser: locator<DeepLinkParser>(),
        telemetry: locator<DeepLinkTelemetry>(),
      ),
      dispose: (listener) => listener.stop(),
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

  if (!locator.isRegistered<GoogleFederatedAuthService>()) {
    locator.registerLazySingleton<GoogleFederatedAuthService>(
      () => GoogleFederatedAuthServiceImpl(),
    );
  }

  if (!locator.isRegistered<DeviceIdentityService>()) {
    locator.registerLazySingleton<DeviceIdentityService>(
      () => DeviceIdentityServiceImpl(),
    );
  }

  // Network logging config (must be initialized before ApiClient)
  NetworkLogConfig.initFromBuildConfig();

  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(
      () =>
          ApiClient()
            ..init(sessionManagerProvider: () => locator<SessionManager>()),
    );
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
  UserModule.register(locator);
  AuthModule.register(locator);

  // App orchestrators (depend on feature modules)
  if (!locator.isRegistered<UserContextService>()) {
    locator.registerLazySingleton<UserContextService>(
      () => UserContextService(
        sessionManager: locator<SessionManager>(),
        currentUserFetcher: locator<CurrentUserFetcher>(),
        events: locator<AppEventBus>(),
      ),
      dispose: (service) => service.dispose(),
    );
  }

  if (!locator.isRegistered<AppStartupController>()) {
    locator.registerLazySingleton<AppStartupController>(
      () => AppStartupController(
        appLaunch: locator<AppLaunchService>(),
        connectivity: locator<ConnectivityService>(),
        sessionManager: locator<SessionManager>(),
        currentUserFetcher: locator<CurrentUserFetcher>(),
      ),
      dispose: (controller) => controller.dispose(),
    );
  }
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
        // Best-effort: load any persisted pending deep link so it can resume
        // after prerequisites (onboarding/login). This must not block startup.
        unawaited(locator<PendingDeepLinkController>().initialize());
        unawaited(locator<DeepLinkListener>().start());

        await locator<AppStartupController>().initialize();
      } catch (e, st) {
        Log.error(
          'Failed to initialize startup controller',
          e,
          st,
          false,
          'DI',
        );
      }

      // Defer platform-heavy initialization until after first Flutter frame.
      // This reduces time spent on the native launch screen at the cost of
      // slightly delayed Firebase/Crashlytics availability.
      await _initializeFirebaseCrashlyticsAndIntl();

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
          StartupMetrics.instance.reportToAnalytics(
            locator<IAnalyticsService>(),
          ),
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

Future<void> _initializeFirebaseCrashlyticsAndIntl() async {
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

  // Crashlytics depends on Firebase being initialized.
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
    Log.error('Failed to initialize Intl date formatting', e, st, false, 'DI');
  }
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
