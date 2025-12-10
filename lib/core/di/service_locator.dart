import 'package:get_it/get_it.dart';
import '../services/navigation/navigation_service.dart';
import '../events/app_event_bus.dart';

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

  // TODO: Register additional core/feature modules here as your app grows.
  // e.g. CoreModule.register(locator); AuthModule.register(locator); etc.

  // Wait for async dependencies to be ready (if any were registered with signalsReady)
  if (locator.allReadySync() == false) {
    await locator.allReady();
  }
}

/// Resets the service locator (useful for testing).
Future<void> resetLocator() async {
  await locator.reset();
}
