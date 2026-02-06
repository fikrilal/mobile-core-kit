import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/app_launch/app_launch_service_impl.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/appearance/theme_mode_store.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/localization/locale_store.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/runtime/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_launch_service.dart';

void registerCoreFoundation(GetIt locator) {
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
}
