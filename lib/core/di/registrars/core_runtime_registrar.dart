import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/navigation/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/platform/app_links/deep_link_source.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_service.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_service_impl.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_listener.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_telemetry.dart';
import 'package:mobile_core_kit/core/runtime/navigation/navigation_service.dart';
import 'package:mobile_core_kit/core/runtime/navigation/pending_deep_link_controller.dart';

void registerCoreRuntime(GetIt locator) {
  if (!locator.isRegistered<NavigationService>()) {
    locator.registerLazySingleton<NavigationService>(() => NavigationService());
  }

  if (!locator.isRegistered<AppEventBus>()) {
    locator.registerLazySingleton<AppEventBus>(
      () => AppEventBus(),
      dispose: (bus) => bus.dispose(),
    );
  }

  if (!locator.isRegistered<DeepLinkParser>()) {
    locator.registerLazySingleton<DeepLinkParser>(
      () => DeepLinkParser(allowedHosts: BuildConfig.deepLinkAllowedHosts),
    );
  }

  if (!locator.isRegistered<IAnalyticsService>()) {
    locator.registerLazySingleton<IAnalyticsService>(
      () => AnalyticsServiceImpl(),
    );
  }

  if (!locator.isRegistered<AnalyticsTracker>()) {
    locator.registerLazySingleton<AnalyticsTracker>(
      () => AnalyticsTracker(locator<IAnalyticsService>()),
    );
  }

  if (!locator.isRegistered<DeepLinkTelemetry>()) {
    locator.registerLazySingleton<DeepLinkTelemetry>(
      () => DeepLinkTelemetry(analytics: locator<AnalyticsTracker>()),
    );
  }

  if (!locator.isRegistered<PendingDeepLinkController>()) {
    locator.registerLazySingleton<PendingDeepLinkController>(
      () => PendingDeepLinkController(
        store: locator<PendingDeepLinkStore>(),
        parser: locator<DeepLinkParser>(),
        telemetry: locator<DeepLinkTelemetry>(),
      ),
      dispose: (controller) => controller.dispose(),
    );
  }

  if (!locator.isRegistered<DeepLinkListener>()) {
    locator.registerLazySingleton<DeepLinkListener>(
      () => DeepLinkListener(
        source: locator<DeepLinkSource>(),
        navigation: locator<NavigationService>(),
        deepLinks: locator<PendingDeepLinkController>(),
        parser: locator<DeepLinkParser>(),
        telemetry: locator<DeepLinkTelemetry>(),
      ),
      dispose: (listener) => listener.stop(),
    );
  }
}
