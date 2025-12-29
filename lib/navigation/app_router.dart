import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/di/service_locator.dart';
import '../core/services/navigation/navigation_service.dart';
import '../core/services/analytics/analytics_route_observer.dart';
import '../core/services/analytics/analytics_tracker.dart';
import '../core/services/app_startup/app_startup_controller.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'app_redirect.dart';
import 'app_routes.dart';
import 'auth/auth_routes_list.dart';
import 'shell/app_shell_page.dart';
import 'onboarding/onboarding_routes_list.dart';

/// Builds the global [GoRouter] used by the app.
///
/// The boilerplate starts with a minimal bottom-tab shell so navigation is not
/// empty. Feature modules can extend this by exposing their own `List<GoRoute>`
/// and combining them here.
GoRouter createRouter() {
  final navigation = locator<NavigationService>();
  final analyticsTracker = locator<AnalyticsTracker>();
  final startup = locator<AppStartupController>();
  return GoRouter(
    navigatorKey: navigation.rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.root,
    observers: [
      AnalyticsRouteObserver(analyticsTracker),
    ],
    refreshListenable: startup,
    redirect: (context, state) => appRedirect(state, startup),
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: 'root',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      ...authRoutes,
      ...onboardingRoutes,
    ],
  );
}
