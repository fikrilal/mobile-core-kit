# Architecture Linting (IDE + CI)

This repo enforces **architecture import boundaries** in two places:

- **In the IDE** (VS Code / Android Studio) via `custom_lint` (an analyzer plugin).
- **In CI and `tool/verify.dart`** via `dart run custom_lint` (because `flutter analyze` does not run custom lints).

The goal is to make boundary violations hard to introduce accidentally and easy to catch during reviews.

## What Is Enforced

The main rule today is `architecture_imports`, configured by:

- `tool/lints/architecture_lints.yaml`

This file is the **single source of truth** for the architecture rules. It uses glob patterns relative to the repo root (always use `/` as the separator).

### Current Policy (Core → Features)

- Default: `lib/core/**` MUST NOT import `lib/features/**`.
- Exceptions are explicitly allowlisted in `tool/lints/architecture_lints.yaml` (e.g. feature DI composition).

Note: some exceptions are marked **TEMP** and have TODOs to refactor away.

### Current Policy (Feature Domain Purity)

Feature domain code (`lib/features/*/domain/**`) MUST remain framework- and infra-free:

- It MUST NOT import feature data/presentation or navigation.
- It MUST NOT import infrastructure concerns such as:
  - networking (`lib/core/infra/network/**`)
  - persistence (`lib/core/infra/database/**`, `lib/core/infra/storage/**`)
  - UI/theme (`lib/core/design_system/widgets/**`, `lib/core/design_system/theme/**`, `lib/core/design_system/adaptive/**`)
  - DI (`lib/core/di/**`)
  - generated localization (`lib/l10n/**`)

This keeps the domain layer testable and portable across apps that adopt this template.

### Current Policy (Features → Features)

Features MUST NOT import other feature code by default.

- Default: `lib/features/**` MUST NOT import `lib/features/**`.
- Exceptions are explicit and rare (see `features_no_cross_feature_imports`).

This is enforced so “shared contracts” do not accidentally live inside a random feature.
If something is genuinely shared across features, it belongs in `lib/core/**` (or a dedicated shared package).

### Current Policy (Service Locator)

Only **composition roots** may import `lib/core/di/service_locator.dart`.

Allowed scopes:
- `lib/core/di/**` (registrations / bootstrap)
- `lib/navigation/**` (route-time providers)
- `lib/features/*/di/**` (feature module registration)
- `lib/app.dart`, `lib/main_*.dart` (root composition)

Disallowed scopes (examples):
- `lib/features/*/presentation/**`
- `lib/core/infra/network/**`
- `lib/core/design_system/widgets/**`

Pattern to follow:
- Resolve dependencies in navigation/DI.
- Pass dependencies via constructors (widgets) or providers (`BlocProvider` at route build time).

### Restricted Imports (Low-Level Dependencies)

This repo also enforces “dependency boundaries” via a separate custom lint:

- `restricted_imports` (configured in `analysis_options.yaml`)

It prevents low-level packages from being imported directly in feature code (unless explicitly allowlisted),
so we keep migrations and refactors cheap.

Examples of restricted dependencies:
- `dio` → must live under `lib/core/infra/network/**`
- `firebase_analytics` → must live under `lib/core/runtime/analytics/**`
- `firebase_crashlytics` → must live under `lib/core/platform/crash_reporting/**` / logging utilities
- `shared_preferences` → only allowed in store/service implementations (plus explicit template allowlists)
- `flutter_secure_storage` → must live under `lib/core/infra/storage/secure/**`

### Content & Navigation Guardrails

These lints exist to reduce reviewer cognitive load and keep the UX consistent:

- `hardcoded_ui_strings`: blocks user-facing string literals in common widget contexts (use `context.l10n.*`).
  - Excludes dev tools and showcase screens by default.
- `route_string_literals`: blocks route path literals in `context.go/push` and `GoRoute(path: ...)` (use route constants).

### Design Token Guardrails

These lints enforce consistent UI sizing and reduce “random magic numbers”:

- `spacing_tokens`: blocks hardcoded spacing in `EdgeInsets`/`SizedBox` (use `AppSpacing.*`).
- `radius_tokens`: blocks hardcoded `Radius.circular(x)` / `BorderRadius.circular(x)` (use `AppRadii.*`).
- `icon_size_tokens`: blocks hardcoded icon sizes (`Icon(size: x)`, `PhosphorIcon(size: x)`, `IconButton(iconSize: x)`) (use `AppSizing.iconSize*`).
- `state_opacity_tokens`: blocks hardcoded alpha values for disabled/pressed/hovered states (use `StateOpacities.*`).
- `motion_durations`: blocks hardcoded durations for common motion (use `MotionDurations.*`).

### Networking Guardrails

- `api_helper_datasource_policy`: enforces explicit `ApiHelper` call defaults inside feature datasources:
  - explicit `host:`
  - `throwOnError: false`
  - explicit `requiresAuth: true|false`

## Running Locally (CLI)

Run custom lints:

```bash
dart run custom_lint
```

Run the full verify pipeline (includes custom lint):

```bash
dart run tool/verify.dart --env dev
```

Run the codegen freshness gate (ensures generated outputs are committed + up-to-date):

```bash
dart run tool/verify_codegen.dart
```

Or via the main verify script:

```bash
dart run tool/verify.dart --env dev --check-codegen
```

If you are in WSL, use the same direct Dart commands:

```bash
dart run custom_lint
dart run tool/verify.dart --env dev
dart run tool/verify_codegen.dart
```

In non-interactive runners (Codex CLI PTY sessions / scripts), use direct commands and ensure your shell environment is set up with `dart` on `PATH`.

## IDE Setup

Custom linting is enabled through `analysis_options.yaml`:

- `analyzer.plugins: [custom_lint]`
- `custom_lint.rules` is configured in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - architecture_imports:
      config: tool/lints/architecture_lints.yaml
```

After you run `flutter pub get`, you may need to restart the analyzer:

- **VS Code**: Command Palette → `Dart: Restart Analysis Server`
- **Android Studio / IntelliJ**: `Tools` → `Dart` → `Restart Dart Analysis Server`

## Extending the Rules

Add new rules in `tool/lints/architecture_lints.yaml`. Each rule has:

- `from`: files the rule applies to
- `deny`: forbidden import targets (project-relative)
- `exceptions`: allowlists scoped by `from` + `allow`

Examples of common “next rules” in mature apps:

- Domain purity: `features/*/domain/**` cannot import Flutter/UI, networking, or platform SDK packages.
- Feature layering: `features/*/presentation/**` cannot import `features/*/data/**`.
- Cross-feature boundaries: restrict direct imports between features (route through `core/` or a shared contract).

## Troubleshooting

- If you only run `flutter analyze`, you will **not** see `custom_lint` violations. Use `dart run custom_lint` or `dart run tool/verify.dart`.
- If lints don’t show in the IDE, confirm:
  - `custom_lint` is in `dev_dependencies` in `pubspec.yaml`
  - `analysis_options.yaml` has `analyzer.plugins: [custom_lint]`
  - You ran `flutter pub get`
  - You restarted the Dart analysis server
