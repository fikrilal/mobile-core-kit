import 'package:go_router/go_router.dart';
import '../core/di/service_locator.dart';
import '../core/services/navigation/navigation_service.dart';
import 'auth/auth_routes.dart';
import 'auth/auth_routes_list.dart';

/// Builds the global [GoRouter] used by the app.
///
/// The boilerplate starts with a minimal auth-only router so that navigation
/// is not empty. Feature modules can extend this by exposing their own
/// `List<GoRoute>` and combining them here.
GoRouter createRouter() {
  final navigation = locator<NavigationService>();
  return GoRouter(
    navigatorKey: navigation.rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AuthRoutes.signIn,
    routes: [
      ...authRoutes,
    ],
  );
}
