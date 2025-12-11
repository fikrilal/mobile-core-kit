import 'package:go_router/go_router.dart';
import '../core/di/service_locator.dart';
import '../core/services/navigation/navigation_service.dart';
import '../core/services/analytics/analytics_route_observer.dart';
import '../core/services/analytics/analytics_tracker.dart';
import 'auth/auth_routes.dart';
import 'auth/auth_routes_list.dart';

/// Builds the global [GoRouter] used by the app.
///
/// The boilerplate starts with a minimal auth-only router so that navigation
/// is not empty. Feature modules can extend this by exposing their own
/// `List<GoRoute>` and combining them here.
GoRouter createRouter() {
  final navigation = locator<NavigationService>();
  final analyticsTracker = locator<AnalyticsTracker>();
  return GoRouter(
    navigatorKey: navigation.rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AuthRoutes.signIn,
    observers: [
      AnalyticsRouteObserver(analyticsTracker),
    ],
    routes: [
      ...authRoutes,
    ],
  );
}
