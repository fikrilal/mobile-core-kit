import 'package:flutter/material.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';
import 'core/di/service_locator.dart';
import 'core/adaptive/adaptive_scope.dart';
import 'core/adaptive/policies/navigation_policy.dart';
import 'core/adaptive/policies/text_scale_policy.dart';
import 'core/localization/l10n.dart';
import 'core/services/app_startup/app_startup_controller.dart';
import 'core/services/appearance/theme_mode_controller.dart';
import 'core/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'core/services/navigation/navigation_service.dart';
import 'core/widgets/loading/loading.dart';
import 'core/widgets/listener/app_event_listener.dart';
import 'navigation/app_router.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final navigation = locator<NavigationService>();
    final startup = locator<AppStartupController>();
    final themeModeController = locator<ThemeModeController>()..load();

    return AppEventListener(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeController,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
                  isReady: () => startup.isReady,
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
      ),
    );
  }
}
