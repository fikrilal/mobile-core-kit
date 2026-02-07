import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/auth/di/auth_module.dart';
import 'package:mobile_core_kit/features/user/di/user_module.dart';

void registerFeatureModules(GetIt locator) {
  UserModule.register(locator);
  AuthModule.register(locator);
}
