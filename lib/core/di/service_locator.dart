import 'package:get_it/get_it.dart';
import '../services/navigation/navigation_service.dart';
import '../events/app_event_bus.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/connectivity/connectivity_service_impl.dart';
import '../services/analytics/analytics_service.dart';
import '../services/analytics/analytics_service_impl.dart';
import '../services/analytics/analytics_tracker.dart';
import '../network/api/api_client.dart';
import '../network/api/api_helper.dart';
import '../network/logging/network_log_config.dart';
import '../../features/auth/di/auth_module.dart';
import '../session/session_manager.dart';

/// Global service locator – access via `locator<MyType>()` anywhere in the codebase.
final GetIt locator = GetIt.instance;

/// Shorthand getter for the service locator.
GetIt get getIt => locator;

/// Registers all application-wide dependencies using a modular approach.
///
/// This function is intentionally minimal in the boilerplate. It wires
/// core-level services and is the place where feature modules should be
/// registered in real projects.
///
/// Call this **once** before `runApp()` in every entry point:
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await setupLocator();
///   runApp(const MyApp());
/// }
/// ```
Future<void> setupLocator() async {
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

  // Initialize analytics
  await locator<IAnalyticsService>().initialize();

  // Initialize connectivity listener
  await locator<ConnectivityService>().initialize();

  // Initialize session manager (load any existing session)
  await locator<SessionManager>().init();

  // Wait for async dependencies to be ready (if any were registered with signalsReady)
  if (locator.allReadySync() == false) {
    await locator.allReady();
  }
}

/// Resets the service locator (useful for testing).
Future<void> resetLocator() async {
  await locator.reset();
}
