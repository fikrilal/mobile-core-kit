import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/di/registrars/app_orchestrators_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_foundation_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_infra_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_platform_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/core_runtime_registrar.dart';
import 'package:mobile_core_kit/core/di/registrars/feature_modules_registrar.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/runtime/navigation/navigation_service.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_launch_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('registrars wire expected contracts in migration order', () async {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);

    registerCoreFoundation(locator);
    expect(locator.isRegistered<AppLaunchService>(), isTrue);

    registerCorePlatform(locator);
    expect(locator.isRegistered<ConnectivityService>(), isTrue);

    registerCoreInfra(locator);
    expect(locator.isRegistered<ApiHelper>(), isTrue);

    registerCoreRuntime(locator);
    expect(locator.isRegistered<NavigationService>(), isTrue);

    registerFeatureModules(locator);
    expect(locator.isRegistered<SessionManager>(), isTrue);
    expect(locator.isRegistered<CurrentUserFetcher>(), isTrue);

    registerAppOrchestrators(locator);
    expect(locator.isRegistered<AppStartupController>(), isTrue);
  });
}
