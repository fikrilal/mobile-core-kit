import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_client.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/download/dio_presigned_download_client.dart';
import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';
import 'package:mobile_core_kit/core/infra/network/logging/network_log_config.dart';
import 'package:mobile_core_kit/core/infra/network/upload/dio_presigned_upload_client.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/navigation/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/push/push_token_sync_store.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';

void registerCoreInfra(GetIt locator) {
  if (!locator.isRegistered<PendingDeepLinkStore>()) {
    locator.registerLazySingleton<PendingDeepLinkStore>(
      () => PendingDeepLinkStore(),
    );
  }

  if (!locator.isRegistered<PushTokenSyncStore>()) {
    locator.registerLazySingleton<PushTokenSyncStore>(
      () => PushTokenSyncStore(),
    );
  }

  // Network logging config (must be initialized before ApiClient).
  NetworkLogConfig.initFromBuildConfig();

  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(
      () =>
          ApiClient()
            ..init(sessionManagerProvider: () => locator<SessionManager>()),
    );
  }

  if (!locator.isRegistered<ApiHelper>()) {
    locator.registerLazySingleton<ApiHelper>(
      () => ApiHelper(
        locator<ApiClient>().dio,
        connectivity: locator<ConnectivityService>(),
      ),
    );
  }

  if (!locator.isRegistered<PresignedUploadClient>()) {
    locator.registerLazySingleton<PresignedUploadClient>(
      () => DioPresignedUploadClient(),
    );
  }

  if (!locator.isRegistered<PresignedDownloadClient>()) {
    locator.registerLazySingleton<PresignedDownloadClient>(
      () => DioPresignedDownloadClient(),
    );
  }
}
