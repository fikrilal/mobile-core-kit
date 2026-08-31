import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/account/di/account_module.dart';
import 'package:mobile_core_kit/features/auth/di/auth_module.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/di/merchant_onboarding_module.dart';

void registerFeatureModules(GetIt locator) {
  AccountModule.register(locator);
  AuthModule.register(locator);
  MerchantOnboardingModule.register(locator);
}
