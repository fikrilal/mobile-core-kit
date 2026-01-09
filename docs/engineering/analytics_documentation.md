# Firebase Analytics Guide (Template Stack)

This document describes how analytics is implemented in this template and how
feature code should interact with it.

> Note: Older documentation from previous projects mentioned GetX controllers,
> bindings, and middleware. This template **does not** use GetX for analytics.
> Instead, it uses GetIt for dependency injection plus a small analytics
> service/trackers stack described below.

## Architecture Overview

- **Provider**: `firebase_analytics` (`FirebaseAnalytics`).
- **Config**: `BuildConfig` flags generated from `.env/*.yaml`:
  - `analyticsEnabledDefault`
  - `analyticsDebugLoggingEnabled`
- **Service interface**: `IAnalyticsService`
  (`lib/core/services/analytics/analytics_service.dart`).
- **Service implementation**: `AnalyticsServiceImpl`
  (`lib/core/services/analytics/analytics_service_impl.dart`).
- **Event constants**: `AnalyticsEvents`, `AnalyticsParams`
  (`lib/core/services/analytics/analytics_events.dart`).
- **High-level facade**: `AnalyticsTracker`
  (`lib/core/services/analytics/analytics_tracker.dart`).
- **Navigation integration**: `AnalyticsRouteObserver`
  (`lib/core/services/analytics/analytics_route_observer.dart`) wired into
  `GoRouter` in `lib/navigation/app_router.dart`.
- **DI**: `GetIt` registrations in `lib/core/di/service_locator.dart`.

The intended flow:

1. `bootstrapLocator()` initializes Firebase with `firebase_options.dart` (best effort).
2. `registerLocator()` registers `IAnalyticsService` (and other dependencies) before `runApp()`.
3. `bootstrapLocator()` initializes `IAnalyticsService` after the first frame (best effort).
4. `createRouter()` attaches `AnalyticsRouteObserver`, which uses
   `AnalyticsTracker` to track screens.
5. Feature code calls `AnalyticsTracker` for business-level events
   (login, button clicks, searches, etc.).

## File Layout

```text
lib/
  core/
    configs/
      build_config.dart
    di/
      service_locator.dart
    services/
      analytics/
        analytics_service.dart          # IAnalyticsService contract
        analytics_service_impl.dart     # Firebase-backed implementation
        analytics_events.dart           # event/parameter constants
        analytics_tracker.dart          # feature-facing facade
        analytics_route_observer.dart   # GoRouter NavigatorObserver
  navigation/
    app_router.dart                     # wires AnalyticsRouteObserver
```

## Environment & Defaults

Each `.env/<env>.yaml` contains analytics flags:

```yaml
# Analytics
analyticsEnabledDefault: true        # default collection state
analyticsDebugLoggingEnabled: true   # verbose logging in dev/staging
```

`tool/gen_config.dart` bakes these into `build_config_values.dart`. At runtime,
`AnalyticsServiceImpl` reads them via `BuildConfig`:

- `analyticsEnabledDefault` → initial `_analyticsEnabled` state.
- `analyticsDebugLoggingEnabled` + `AppConfig.instance.enableLogging`
  → controls console debug logging of analytics events.

Projects can later override the runtime state using
`IAnalyticsService.setAnalyticsCollectionEnabled`.

## Service Layer (`IAnalyticsService` / `AnalyticsServiceImpl`)

`IAnalyticsService` exposes low-level operations:

- `initialize()`
- `logEvent(String eventName, {Map<String, Object?>? parameters})`
- `logScreenView(String screenName, {String? previousScreenName, Map<String, Object?>? parameters})`
- `setUserId(String userId)`
- `clearUser()`
- `setUserProperty(String name, String value)`
- `setAnalyticsCollectionEnabled(bool enabled)`
- `isAnalyticsCollectionEnabled()`

`AnalyticsServiceImpl`:

- Wraps `FirebaseAnalytics`.
- On `initialize()`:
  - Applies collection flag (`analyticsEnabledDefault`).
  - Sets `AnalyticsParams.appEnvironment` user property to the current
    `BuildConfig.env.name`.
- Respects `_analyticsEnabled` for all tracking calls:
  - When disabled, real events are skipped.
  - In dev/staging, still logs “would log” messages if debug logging is on.
- Uses `AnalyticsEvents.screenView` and `AnalyticsParams.screenName` /
  `previousScreenName` when formatting screen view events.

Features usually **do not** depend on `IAnalyticsService` directly; they use
`AnalyticsTracker` instead.

## Event & Parameter Constants

All event and parameter keys live in
`lib/core/services/analytics/analytics_events.dart`:

Core-level constants (`lib/core/services/analytics/analytics_events.dart`):

```dart
class AnalyticsEvents {
  static const String screenView = 'screen_view';
  static const String login = 'login';
  static const String buttonClick = 'button_click';
  static const String search = 'search';
}

class AnalyticsParams {
  static const String screenName = 'screen_name';
  static const String previousScreenName = 'previous_screen_name';
  static const String method = 'method';
  static const String buttonId = 'button_id';
  static const String searchQuery = 'search_query';
  static const String searchType = 'search_type';
  static const String appEnvironment = 'app_environment';
}
```

Feature-level identifiers (example: `lib/features/auth/analytics/auth_analytics_screens.dart` and `auth_analytics_targets.dart`):

```dart
// auth_analytics_screens.dart
class AuthAnalyticsScreens {
  static const String signIn = 'auth_sign_in';
}

// auth_analytics_targets.dart
class AuthAnalyticsTargets {
  static const String signInSubmit = 'auth_sign_in_submit';
}
```

Use the core constants for event/param names and the feature constants for
screen/element IDs. This keeps core generic while allowing each feature to own
its own analytics vocabulary.

## Feature-Facing Facade (`AnalyticsTracker`)

`AnalyticsTracker` is the only class that features should know about:

- `trackScreen(String name, {String? previous, Map<String, Object?>? parameters})`
- `trackLogin({required String method})`
- `trackButtonClick({required String id, String? screen, Map<String, Object?>? parameters})`
- `trackSearch({required String query, String? type, Map<String, Object?>? parameters})`

Internally it delegates to `IAnalyticsService.logEvent` / `logScreenView`
using `AnalyticsEvents` and `AnalyticsParams`.

### DI Usage

`service_locator.dart` registers:

```dart
locator.registerLazySingleton<IAnalyticsService>(() => AnalyticsServiceImpl());
locator.registerLazySingleton<AnalyticsTracker>(
  () => AnalyticsTracker(locator<IAnalyticsService>()),
);
```

From a feature (e.g., a BLoC, Cubit, or page), access it via `locator`:

```dart
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';

final analytics = locator<AnalyticsTracker>();

analytics.trackLogin(method: 'email_password');
analytics.trackButtonClick(id: 'sign_in_submit', screen: 'sign_in');
```

Avoid passing raw `FirebaseAnalytics` instances or the service directly into
features; keep usage behind `AnalyticsTracker`.

## Navigation Integration (`AnalyticsRouteObserver`)

`AnalyticsRouteObserver` is a `NavigatorObserver` that reports screen changes:

- Hooks into `didPush`, `didReplace`, and `didPop`.
- Extracts `RouteSettings.name` (or argument string) when the route is a
  `PageRoute`.
- Calls `AnalyticsTracker.trackScreen(name, previous: previousName)`.

`createRouter()` wires it into `GoRouter`:

```dart
GoRouter createRouter() {
  final navigation = locator<NavigationService>();
  final analyticsTracker = locator<AnalyticsTracker>();

  return GoRouter(
    navigatorKey: navigation.rootNavigatorKey,
    initialLocation: AuthRoutes.signIn,
    observers: [
      AnalyticsRouteObserver(analyticsTracker),
    ],
    routes: [...],
  );
}
```

Best practice is to set `name` on your `GoRoute`s so the observer can use
stable, analytics-friendly screen names. If `name` is omitted, the observer
falls back to the route arguments string.

## How to Use Analytics in a Feature

Typical pattern inside a BLoC/Cubit or page:

```dart
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._analytics);

  final AnalyticsTracker _analytics;

  Future<void> onLoginPressed(/* ... */) async {
    // Perform login...
    await _analytics.trackLogin(method: 'email_password');
  }
}
```

Or directly in a widget when appropriate:

```dart
class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final analytics = locator<AnalyticsTracker>();

    return ElevatedButton(
      onPressed: () {
        analytics.trackButtonClick(
          id: 'sign_in_submit',
          screen: 'sign_in',
        );
        // trigger login flow...
      },
      child: const Text('Sign in'),
    );
  }
}
```

## Privacy & Consent (Future Hook)

The template is wired for environment-based defaults, but real products often
need runtime consent:

- Add a preference such as `UserPreferences.analyticsEnabled` in your
  preferences layer.
- On app start, read that preference and call:

```dart
await locator<IAnalyticsService>()
    .setAnalyticsCollectionEnabled(userPref.analyticsEnabled);
```

- Expose a toggle in your settings UI that updates the preference and calls
  `setAnalyticsCollectionEnabled` again.

Until that layer exists, the template relies solely on
`BuildConfig.analyticsEnabledDefault` to decide whether analytics is on.

## Best Practices & Tips

- Never log PII (emails, names, tokens, etc.).
- Prefer stable IDs (e.g., `sign_in_submit`) over human labels (`"Sign in"`).
- Keep event payloads compact and meaningful.
- Use `analyticsDebugLoggingEnabled` in dev/staging to verify events via logs,
  and Firebase DebugView when connected to a real project.
