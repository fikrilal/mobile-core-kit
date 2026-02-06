import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
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

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await resetLocator();
  });

  tearDown(() async {
    await resetLocator();
  });

  test('registerLocator registers cross-layer dependencies', () {
    registerLocator();

    expect(locator.isRegistered<NavigationService>(), isTrue);
    expect(locator.isRegistered<AppLaunchService>(), isTrue);
    expect(locator.isRegistered<ConnectivityService>(), isTrue);
    expect(locator.isRegistered<ApiHelper>(), isTrue);
    expect(locator.isRegistered<SessionManager>(), isTrue);
    expect(locator.isRegistered<CurrentUserFetcher>(), isTrue);
    expect(locator.isRegistered<AppStartupController>(), isTrue);
  });

  test('registerLocator is idempotent', () {
    registerLocator();
    expect(registerLocator, returnsNormally);
  });
}
