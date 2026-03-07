import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/session/session_repository.dart';
import 'package:mobile_core_kit/core/domain/session/token_refresher.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/session/session_repository_impl.dart';

void registerCoreSession(GetIt locator) {
  if (!locator.isRegistered<SessionRepository>()) {
    locator.registerLazySingleton<SessionRepository>(
      () => SessionRepositoryImpl(cachedUserStore: locator<CachedUserStore>()),
    );
  }

  if (!locator.isRegistered<SessionManager>()) {
    locator.registerLazySingleton<SessionManager>(
      () => SessionManager(
        locator<SessionRepository>(),
        tokenRefresher: locator<TokenRefresher>(),
        events: locator<AppEventBus>(),
      ),
      dispose: (manager) => manager.dispose(),
    );
  }
}
