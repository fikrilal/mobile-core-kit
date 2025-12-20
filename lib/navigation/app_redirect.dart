import 'package:go_router/go_router.dart';

import '../core/services/app_startup/app_startup_controller.dart';
import 'app_routes.dart';
import 'auth/auth_routes.dart';
import 'onboarding/onboarding_routes.dart';

/// Central navigation gate for the app.
///
/// This keeps routing rules (startup readiness, onboarding, auth) in one place,
/// so feature pages do not need to implement their own guard logic.
String? appRedirect(
  GoRouterState state,
  AppStartupController startup,
) {
  final location = state.matchedLocation;
  final zone = _routeZone(location);

  if (!startup.isReady) {
    return zone == _RouteZone.splash ? null : AppRoutes.splash;
  }

  final shouldShowOnboarding = startup.shouldShowOnboarding ?? false;

  if (zone == _RouteZone.splash) {
    if (shouldShowOnboarding) return OnboardingRoutes.onboarding;
    return startup.isAuthenticated ? AppRoutes.home : AuthRoutes.signIn;
  }

  if (shouldShowOnboarding) {
    return zone == _RouteZone.onboarding ? null : OnboardingRoutes.onboarding;
  }

  if (!startup.isAuthenticated) {
    return zone == _RouteZone.auth ? null : AuthRoutes.signIn;
  }

  if (zone == _RouteZone.auth || zone == _RouteZone.onboarding) {
    return AppRoutes.home;
  }

  return null;
}

enum _RouteZone { splash, onboarding, auth, other }

_RouteZone _routeZone(String location) {
  if (location == AppRoutes.splash) return _RouteZone.splash;
  if (location == OnboardingRoutes.onboarding) return _RouteZone.onboarding;
  if (location.startsWith('/auth')) return _RouteZone.auth;
  return _RouteZone.other;
}

