import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/theme/theme.dart';
import 'package:go_router/go_router.dart';
import 'core/services/navigation/navigation_service.dart';
import 'core/widgets/listener/app_event_listener.dart';
import 'navigation/app_router.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final navigation = locator<NavigationService>();
    return AppEventListener(
      child: MaterialApp.router(
        title: 'Mobile Core Kit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        routerConfig: _router,
        scaffoldMessengerKey: navigation.scaffoldMessengerKey,
      ),
    );
  }
}
