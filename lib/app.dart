import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/text_scale_policy.dart';
import 'package:mobile_core_kit/core/design_system/localization/l10n.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/listener/app_event_listener.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/runtime/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/runtime/navigation/navigation_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'package:mobile_core_kit/navigation/app_router.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final navigation = locator<NavigationService>();
    final eventBus = locator<AppEventBus>();
    final startup = locator<AppStartupController>();
    final themeModeController = locator<ThemeModeController>()..load();
    final localeController = locator<LocaleController>()..load();

    return AppEventListener(
      eventBus: eventBus,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeController,
        builder: (context, themeMode, _) {
          return ValueListenableBuilder<Locale?>(
            valueListenable: localeController,
            builder: (context, localeOverride, _) {
              final supportedLocales = localeController.supportedLocales;

              return MaterialApp.router(
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context).appTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                locale: localeOverride,
                localeListResolutionCallback: (deviceLocales, supported) =>
                    _resolveLocale(deviceLocales, supported),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: supportedLocales,
                routerConfig: _router,
                scaffoldMessengerKey: navigation.scaffoldMessengerKey,
                builder: (context, child) {
                  final app = AdaptiveScope(
                    navigationPolicy: const NavigationPolicy.standard(),
                    textScalePolicy: const TextScalePolicy.clamp(
                      minScaleFactor: 1.0,
                      maxScaleFactor: 2.0,
                    ),
                    child: AppStartupGate(
                      listenable: startup,
                      isReady: () =>
                          startup.isReady &&
                          !startup.shouldBlockRoutingForUserHydration,
                      overlayBuilder: (context) =>
                          AppStartupOverlay(title: context.l10n.appTitle),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );

                  if (!MediaQuery.highContrastOf(context)) return app;

                  final brightness = Theme.of(context).brightness;
                  final theme = brightness == Brightness.dark
                      ? AppTheme.darkHighContrast()
                      : AppTheme.lightHighContrast();

                  return Theme(data: theme, child: app);
                },
              );
            },
          );
        },
      ),
    );
  }
}

Locale? _resolveLocale(
  List<Locale>? deviceLocales,
  Iterable<Locale> supported,
) {
  if (deviceLocales == null || deviceLocales.isEmpty) {
    return _fallbackLocale(supported);
  }

  // 1) Prefer exact matches (including pseudo-locales).
  for (final device in deviceLocales) {
    for (final candidate in supported) {
      if (_isSameLocale(device, candidate)) return candidate;
    }
  }

  // 2) Prefer language matches, but never auto-resolve into pseudo-locales.
  for (final device in deviceLocales) {
    for (final candidate in supported) {
      if (isPseudoLocale(candidate)) continue;
      if (candidate.languageCode == device.languageCode) return candidate;
    }
  }

  return _fallbackLocale(supported);
}

Locale? _fallbackLocale(Iterable<Locale> supported) {
  for (final candidate in supported) {
    if (isPseudoLocale(candidate)) continue;
    return candidate;
  }
  return supported.isEmpty ? null : supported.first;
}

bool _isSameLocale(Locale a, Locale b) =>
    a.languageCode == b.languageCode &&
    (a.countryCode ?? '') == (b.countryCode ?? '');
