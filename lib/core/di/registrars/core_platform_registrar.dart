import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/platform/app_links/app_links_deep_link_source.dart';
import 'package:mobile_core_kit/core/platform/app_links/deep_link_source.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service_impl.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service_impl.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service_impl.dart';
import 'package:mobile_core_kit/core/platform/media/image_picker_service.dart';
import 'package:mobile_core_kit/core/platform/media/image_picker_service_impl.dart';
import 'package:mobile_core_kit/core/platform/push/fcm_token_provider.dart';
import 'package:mobile_core_kit/core/platform/push/fcm_token_provider_impl.dart';

void registerCorePlatform(GetIt locator) {
  if (!locator.isRegistered<ConnectivityService>()) {
    locator.registerLazySingleton<ConnectivityService>(
      () => ConnectivityServiceImpl(),
      dispose: (service) => service.dispose(),
    );
  }

  if (!locator.isRegistered<DeepLinkSource>()) {
    locator.registerLazySingleton<DeepLinkSource>(
      () => AppLinksDeepLinkSource(),
    );
  }

  if (!locator.isRegistered<GoogleFederatedAuthService>()) {
    locator.registerLazySingleton<GoogleFederatedAuthService>(
      () => GoogleFederatedAuthServiceImpl(),
    );
  }

  if (!locator.isRegistered<DeviceIdentityService>()) {
    locator.registerLazySingleton<DeviceIdentityService>(
      () => DeviceIdentityServiceImpl(),
    );
  }

  if (!locator.isRegistered<ImagePickerService>()) {
    locator.registerLazySingleton<ImagePickerService>(
      () => ImagePickerServiceImpl(),
    );
  }

  if (!locator.isRegistered<FcmTokenProvider>()) {
    locator.registerLazySingleton<FcmTokenProvider>(
      () => FcmTokenProviderImpl(),
    );
  }
}
