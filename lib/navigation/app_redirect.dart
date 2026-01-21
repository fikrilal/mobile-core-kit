import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';
import 'package:mobile_core_kit/navigation/onboarding/onboarding_routes.dart';

/// Central navigation gate for the app.
///
/// This keeps routing rules (startup readiness, onboarding, auth) in one place,
/// so feature pages do not need to implement their own guard logic.
String? appRedirect(
  GoRouterState state,
  AppStartupController startup,
  PendingDeepLinkController deepLinks,
  DeepLinkParser deepLinkParser,
) {
  return appRedirectUri(state.uri, startup, deepLinks, deepLinkParser);
}

@visibleForTesting
String? appRedirectUri(
  Uri uri,
  AppStartupController startup,
  PendingDeepLinkController deepLinks,
  DeepLinkParser deepLinkParser,
) {
  final isExternalHttps = uri.hasScheme && uri.scheme == 'https';
  final mappedExternal = isExternalHttps
      ? deepLinkParser.parseExternalUri(uri)
      : null;

  // Fail safe: reject non-allowlisted HTTPS links.
  if (isExternalHttps && mappedExternal == null) return AppRoutes.root;

  final location = mappedExternal ?? _locationFromUri(uri);
  final shouldCanonicalizeExternalHttps =
      isExternalHttps && mappedExternal != null && uri.toString() != location;
  final pendingSource = isExternalHttps ? 'https' : 'router';
  final zone = _routeZone(Uri.parse(location).path);

  // Do not force navigation during startup (use a UI gate/overlay instead).
  if (!startup.isReady) {
    if (zone == _RouteZone.root ||
        zone == _RouteZone.onboarding ||
        zone == _RouteZone.auth) {
      return null;
    }

    deepLinks.setPendingLocationForRedirect(
      location,
      source: pendingSource,
      reason: 'startup_not_ready',
    );
    return AppRoutes.root;
  }

  final shouldShowOnboarding = startup.shouldShowOnboarding ?? false;

  if (zone == _RouteZone.root) {
    if (shouldShowOnboarding) return OnboardingRoutes.onboarding;

    if (!startup.isAuthenticated) {
      return AuthRoutes.signIn;
    }

    final pending = deepLinks.consumePendingLocationForRedirect();
    if (pending != null) return pending;

    return AppRoutes.home;
  }

  if (shouldShowOnboarding) {
    if (zone == _RouteZone.onboarding) return null;

    deepLinks.setPendingLocationForRedirect(
      location,
      source: pendingSource,
      reason: 'needs_onboarding',
    );
    return OnboardingRoutes.onboarding;
  }

  if (!startup.isAuthenticated) {
    if (zone == _RouteZone.auth) return null;

    deepLinks.setPendingLocationForRedirect(
      location,
      source: pendingSource,
      reason: 'needs_auth',
    );
    return AuthRoutes.signIn;
  }

  if (zone == _RouteZone.auth || zone == _RouteZone.onboarding) {
    final pending = deepLinks.consumePendingLocationForRedirect();
    if (pending != null) return pending;

    return AppRoutes.home;
  }

  if (shouldCanonicalizeExternalHttps) return location;

  return null;
}

enum _RouteZone { root, onboarding, auth, other }

_RouteZone _routeZone(String path) {
  if (path == AppRoutes.root) return _RouteZone.root;
  if (path == OnboardingRoutes.onboarding) return _RouteZone.onboarding;
  if (path.startsWith('/auth')) return _RouteZone.auth;
  return _RouteZone.other;
}

String _locationFromUri(Uri uri) {
  final path = _normalizePath(uri.path);
  final query = uri.query;
  if (query.isEmpty) return path;
  return '$path?$query';
}

String _normalizePath(String path) {
  if (path.isEmpty) return AppRoutes.root;
  if (path == AppRoutes.root) return AppRoutes.root;
  if (path.endsWith('/')) return path.substring(0, path.length - 1);
  return path;
}
