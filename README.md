# mobile-core-kit
Reusable, opinionated boilerplate for Flutter mobile apps with core services, networking, theming, and shared UI components.

## Overview

This repo is meant to be cloned and customized as a **starting point** for production apps. It hosts the shared “mobile core” (networking, auth, theming, analytics, config, etc.) that you can reuse across multiple Flutter projects instead of re‑building the same foundations every time.

> Firebase note: this repo includes **demo Firebase configuration** so the template runs out of the box. Replace it with your own Firebase project before shipping a real app (see `docs/engineering/firebase_setup.md`).

> Status: **work in progress**. A lot of boilerplate (additional features, widgets, and docs) is still being ported from other projects. The current target for a “baseline complete” template is **end of December**.

- Flavor-aware configuration (`dev`, `staging`, `prod`) via `.env/*.yaml` + `BuildConfig`.
- Network layer (Dio, interceptors, API helpers, connectivity checks, logging).
- Auth feature slice (email/password) wired end-to-end.
- DI with GetIt (`core/di/service_locator.dart` + feature modules).
- Theming, typography, spacing, and responsive utilities.
- Firebase (Core + Crashlytics + Analytics) wired to flavors.
- Analytics abstraction (`IAnalyticsService` + `AnalyticsTracker`) with GoRouter integration.

## Prerequisites

- Flutter (managed via FVM) – see `.fvmrc` for the pinned SDK version (`3.38.4`).
- Dart SDK bundled with Flutter.
- Firebase CLI if you want to reconfigure Firebase (`flutterfire configure`).

If you work in WSL, run Flutter/Dart using the Windows toolchain (see `AGENTS.md` for example commands).

## Getting Started

1. **Install dependencies**
   ```bash
   fvm flutter pub get
   ```

2. **Generate build config from `.env`**
   ```bash
   dart run tool/gen_config.dart --env dev
   ```
   or `staging` / `prod` as needed. This writes `lib/core/configs/build_config.g.dart`.

3. **Run code generation (Freezed + JSON)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app (dev flavor)**
   ```bash
   fvm flutter run -t lib/main_dev.dart --dart-define=ENV=dev
   ```

5. **Analyze & format**
   ```bash
   fvm flutter analyze
   fvm dart format .
   ```

6. **Tests**
   ```bash
   fvm flutter test
   ```

## Project Structure

- `lib/core/`
  - `configs/` – `BuildConfig` + `AppConfig` (env & runtime config).
  - `di/` – global service locator (`service_locator.dart`).
  - `network/` – `ApiClient`, `ApiHelper`, interceptors, endpoints.
  - `services/` – cross-cutting services (analytics, connectivity, navigation).
  - `theme/` – color, typography, spacing, responsive utilities.
  - `events/` – app-level event bus + event types.
- `lib/features/`
  - `auth/` – core auth slice (data/domain/presentation, value objects).
  - Each future feature follows the same vertical slice layout.
- `lib/navigation/` – GoRouter setup and route lists per feature.
- `.env/` – YAML per environment (`dev.yaml`, `staging.yaml`, `prod.yaml`).
- `tool/` – scripts like `gen_config.dart` for generating `BuildConfig`.
- `docs/engineering/` – core architecture and implementation guides.
- `docs/template/` – template customization guides (what to change when cloning).

## Configuration & Flavors

- `.env/<env>.yaml` holds environment-specific values like API hosts, logging, analytics flags, and OAuth client IDs.
- `tool/gen_config.dart` reads these files and generates `build_config.g.dart` used by `BuildConfig`.
- Entry points:
  - `lib/main_dev.dart`
  - `lib/main_staging.dart`
  - `lib/main_prod.dart`

Each main file:

- Initializes Firebase using `firebase_options.dart`.
- Initializes `AppConfig`, registers DI via `registerLocator()`, and bootstraps async services after the first frame via `bootstrapLocator()`.
- Configures Crashlytics to collect only in production.

See `docs/engineering/firebase_setup.md` for full details, including how to point the template at a different Firebase project.

## Analytics

- Core abstraction:
  - `IAnalyticsService` (`lib/core/services/analytics/analytics_service.dart`)
  - `AnalyticsServiceImpl` (`analytics_service_impl.dart`) backed by `FirebaseAnalytics`.
  - `AnalyticsTracker` (`analytics_tracker.dart`) – feature-facing facade (screen views, logins, button clicks, searches).
  - `AnalyticsRouteObserver` – GoRouter observer that auto-tracks screen views.
- Configured via `BuildConfig.analyticsEnabledDefault` and `BuildConfig.analyticsDebugLoggingEnabled` (derived from `.env`).
- Feature-level IDs live next to their feature, e.g.:
  - `lib/features/auth/analytics/auth_analytics_screens.dart`
  - `lib/features/auth/analytics/auth_analytics_targets.dart`

See `docs/engineering/analytics_documentation.md` for patterns and examples.

## Documentation

For deeper details on the architecture and patterns used in this template:

- `docs/engineering/project_architecture.md`
- `docs/engineering/model_entity_guide.md`
- `docs/engineering/ui_state_architecture.md`
- `docs/engineering/validation_architecture.md`
- `docs/engineering/validation_cookbook.md`
- `docs/engineering/value_objects_validation.md`
- `docs/engineering/firebase_setup.md`

Template customization guides:

- `docs/template/deep_linking.md`

`AGENTS.md` contains some repo-specific tooling notes (e.g., WSL + FVM commands).
