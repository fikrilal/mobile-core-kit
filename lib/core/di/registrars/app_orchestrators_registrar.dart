import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/session/session_push_token_revoker.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/push/push_token_sync_store.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/push/fcm_token_provider.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_sync_service.dart';
import 'package:mobile_core_kit/core/runtime/push/session_push_token_revoker_impl.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_launch_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';

void registerAppOrchestrators(GetIt locator) {
  if (!locator.isRegistered<SessionPushTokenRevoker>()) {
    locator.registerLazySingleton<SessionPushTokenRevoker>(
      () => SessionPushTokenRevokerImpl(locator<PushTokenRegistrar>()),
    );
  }

  if (!locator.isRegistered<PushTokenSyncService>()) {
    locator.registerLazySingleton<PushTokenSyncService>(
      () => PushTokenSyncService(
        sessionManager: locator<SessionManager>(),
        tokenProvider: locator<FcmTokenProvider>(),
        registrar: locator<PushTokenRegistrar>(),
        store: locator<PushTokenSyncStore>(),
      ),
      dispose: (service) => service.dispose(),
    );
  }

  if (!locator.isRegistered<UserContextService>()) {
    locator.registerLazySingleton<UserContextService>(
      () => UserContextService(
        sessionManager: locator<SessionManager>(),
        currentUserFetcher: locator<CurrentUserFetcher>(),
        events: locator<AppEventBus>(),
      ),
      dispose: (service) => service.dispose(),
    );
  }

  if (!locator.isRegistered<AppStartupController>()) {
    locator.registerLazySingleton<AppStartupController>(
      () => AppStartupController(
        appLaunch: locator<AppLaunchService>(),
        connectivity: locator<ConnectivityService>(),
        sessionManager: locator<SessionManager>(),
        currentUserFetcher: locator<CurrentUserFetcher>(),
      ),
      dispose: (controller) => controller.dispose(),
    );
  }
}
