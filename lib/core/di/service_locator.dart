import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/di/bootstrap/locator_bootstrap_pipeline.dart';
import 'package:mobile_core_kit/core/di/composition/register_composer.dart';
import 'package:mobile_core_kit/core/di/registrars/app_orchestrators_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_foundation_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_infra_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_platform_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_runtime_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/feature_modules_registrar.dart';

/// Global service locator – access via `locator<MyType>()` anywhere in the codebase.
final GetIt locator = GetIt.instance;

/// Shorthand getter for the service locator.
GetIt get getIt => locator;

final LocatorBootstrapPipeline _bootstrapPipeline = LocatorBootstrapPipeline(
  locator: locator,
  registerLocator: registerLocator,
);

/// Registers all application-wide dependencies (sync, no IO).
///
/// Keep this function fast because it is expected to run **before** `runApp()`.
/// All heavy initialization work should go into [bootstrapLocator].
void registerLocator() {
  final composer = RegisterComposer(
    steps: [
      registerCoreFoundation,
      registerCorePlatform,
      registerCoreInfra,
      registerCoreRuntime,
      registerFeatureModules,
      registerAppOrchestrators,
    ],
  );
  composer.compose(locator);
}

/// Initializes dependencies that require async work (disk, platform channels).
///
/// This is safe to call multiple times; initialization runs once per process.
Future<void> bootstrapLocator() => _bootstrapPipeline.bootstrap();

/// Convenience wrapper for apps that still want a single entry point.
Future<void> setupLocator() async {
  registerLocator();
  await bootstrapLocator();
}

/// Resets the service locator (useful for testing).
Future<void> resetLocator() async {
  _bootstrapPipeline.reset();
  await locator.reset();
}
