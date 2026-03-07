import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/account/di/account_kernel_adapter_module.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/di/account_deletion_module.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/di/account_profile_module.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/di/account_security_module.dart';
import 'package:mobile_core_kit/features/user/di/user_module.dart';

class AccountModule {
  static void register(GetIt getIt) {
    AccountDeletionModule.register(getIt);
    AccountProfileModule.register(getIt);
    AccountSecurityModule.register(getIt);
    UserModule.register(getIt);
    AccountKernelAdapterModule.register(getIt);
  }
}
