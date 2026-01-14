import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/adaptive/adaptive_scope.dart';
import 'core/adaptive/policies/navigation_policy.dart';
import 'core/adaptive/policies/text_scale_policy.dart';
import 'core/services/app_startup/app_startup_controller.dart';
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
    return AppEventListener(
      child: MaterialApp.router(
        title: 'Mobile Core Kit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        routerConfig: _router,
        scaffoldMessengerKey: navigation.scaffoldMessengerKey,
        builder: (context, child) {
          return AdaptiveScope(
            navigationPolicy: const NavigationPolicy.standard(),
            textScalePolicy: const TextScalePolicy.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 2.0,
            ),
            child: AppStartupGate(
              listenable: startup,
              isReady: () => startup.isReady,
              overlayBuilder: (_) =>
                  const AppStartupOverlay(title: 'Mobile Core Kit'),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
