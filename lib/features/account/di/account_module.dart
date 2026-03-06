import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/account/di/account_kernel_adapter_module.dart';
import 'package:mobile_core_kit/features/user/di/user_module.dart';

class AccountModule {
  static void register(GetIt getIt) {
    // Transitional: account owns the new top-level boundary while workflow
    // registrations still live under the legacy user feature until later phases.
    UserModule.register(getIt);
    AccountKernelAdapterModule.register(getIt);
  }
}
