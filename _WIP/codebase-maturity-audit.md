# mobile-core-kit — Enterprise Readiness & Template Maturity Audit

**Date:** 2026-01-19  
**Scope:** Flutter “base app” template meant to be cloned per-product  
**Repo commit:** `7d1bfcc90cd53c4d2d0ec70d6346792a40339e04`

## Executive summary (the honest answer)

This codebase is **mature as a foundation**, but it is **not “ship to production as-is”**.

**Go / No-Go:**
- **GO (as a base template for new projects)**: architecture, quality gates, and core services are solid.
- **NO-GO (to publish an enterprise production app without changes)**: there are mandatory per-project customizations (IDs, signing, Firebase, deep-link domains), plus a few template hygiene issues that will create real adoption friction.

## Evidence (what was actually validated)

I ran the repo’s full verification script on `dev` config:

`tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

Observed outcomes:
- `flutter analyze`: **no issues**
- `dart run custom_lint`: **no issues**
- `dart run tool/verify_modal_entrypoints.dart`: **OK**
- `dart run tool/verify_hardcoded_ui_colors.dart`: **OK**
- `flutter test`: **All tests passed** (reported **234** tests)
- `dart format --set-exit-if-changed .`: **0 changed**, but emits warnings about resolving `package:flutter_lints/flutter.yaml`

Notes:
- I did **not** execute `integration_test/*` (these typically require an emulator/simulator in CI).

## Strengths (what is already “enterprise-grade”)

### Architecture & guardrails
- Clean Architecture + vertical slices are consistently applied under `lib/features/*/`.
- Architecture boundaries are enforced via `custom_lint` + `packages/mobile_core_kit_lints/`, configured in `tool/lints/architecture_lints.yaml`.
- ADRs exist and are a real asset for multi-team reuse: `ADR/records/0001-0008-*.md`.
- One-command “CI parity” exists: `tool/verify.dart` (and it’s WSL-aware).

### Networking & auth/session posture
- `ApiHelper` enforces a single response contract surface (`{data, meta?}` + RFC7807-ish errors) and centralizes parsing.
- `AuthTokenInterceptor` includes:
  - single-flight refresh (`Completer`)
  - proactive refresh when expiring soon
  - **safe retry policy**: retries writes only when `Idempotency-Key` is present
- Network logging is configurable and includes redaction (`Redactor`), body truncation, and correlation IDs.
- Session persistence uses `flutter_secure_storage` with reasonable platform options (`TokenSecureStorage`).

### UI system & consistency tooling
- Tokenized theme system with semantic roles and high-contrast variants: `lib/core/theme/` + `lib/core/theme/theme-system-doc.md`.
- Strong “design drift prevention” via lints: hardcoded colors, font sizes, spacing tokens, motion durations, etc.
- Adaptive/responsive system has tests and a golden matrix (this is rare in templates and a big win).

### Operational readiness basics
- Early crash capture buffer exists (to cover pre-Crashlytics window): `lib/core/services/early_errors/early_error_buffer.dart`.
- Startup timing instrumentation exists and is reportable to analytics: `lib/core/services/startup_metrics/`.
- Dev tools routes are gated to dev builds: `lib/navigation/app_router.dart`.

## Findings: what blocks or risks enterprise adoption

### A) Mandatory per-project changes before *any* production shipment (expected, but must be explicit)

These are “you will ship the wrong thing” items if missed:

1) **Identifiers & signing**
- Android release signing is explicitly TODO and currently uses debug keys: `android/app/build.gradle.kts`.
- iOS code signing / bundle identifiers will need project-specific setup (`docs/template/rename_rebrand.md` covers this).

2) **Firebase demo project must be replaced**
- Demo Firebase config is committed (not secret, but it is the wrong destination for production data):
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - (iOS plist is intentionally not committed, but still must exist per project)

3) **Deep link domain is still product-specific**
- `orymu.com` is hardcoded in multiple places and must be replaced:
  - `lib/core/services/deep_link/deep_link_parser.dart`
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Runner.entitlements`
  - docs + tests (`docs/template/deep_linking.md`, `test/**`, `integration_test/**`)

### B) Template hygiene issues (these reduce trust and slow new teams down)

1) **Docs drift / inaccurate examples**
- `docs/engineering/project_architecture.md` doesn’t match current folder names in several places and references `ENV=staging` (see next item).
- `lib/core/events/README.md` is clearly copied from another project:
  - references `package:orymu_mobile/...`
  - references event types that don’t exist here
  - references `core_module.dart` (this repo uses `core/di/service_locator.dart`)

2) **Environment naming mismatch: `stage` vs `staging`**
- Build selector is `BuildEnv { dev, stage, prod }` (`lib/core/configs/build_config.dart`) and it parses `ENV` by enum name.
- Multiple docs/scripts refer to `staging` (and `.env/staging.yaml` exists), which is easy to misconfigure and can cause runtime failure if someone uses `--dart-define=ENV=staging`.

3) **CI reproducibility mismatch**
- GitHub Actions uses Flutter “stable” (`subosito/flutter-action@v2`) instead of pinning to `.fvmrc`.
  - This increases the chance a template update “randomly breaks” on a future stable release.

### C) Enterprise concerns that depend on your threat model (not “missing”, but decisions are required)

1) **Privacy/consent gating**
- Analytics enablement is driven by config defaults (`BuildConfig.analyticsEnabledDefault`).
- Many enterprises require explicit user consent flows (GDPR/CCPA/PDPA) before enabling analytics.

2) **Transport security hardening**
- No certificate pinning. This may be acceptable (and often preferred) unless your threat model demands it.

3) **Data at rest**
- `sqflite` is present (`lib/core/database/app_database.dart`) but there’s no encryption layer. If the template will store sensitive data, decide early whether you need SQLCipher or an alternative.

## Recommended backlog (if you truly have “no backlog”)

### P0 — Template trust & adoption (do before rolling this out to multiple teams)

- Fix stage/staging mismatch (support both `ENV=stage` and `ENV=staging`, or rename enum to `staging` and provide backwards-compat parsing).
- Fix doc drift in `docs/engineering/project_architecture.md` and update any outdated paths/examples.
- Replace or rewrite `lib/core/events/README.md` so it matches this repo and doesn’t reference other apps.
- Pin CI Flutter version to `.fvmrc` (or a single source of truth) to ensure deterministic builds.
- Add a “template customization checklist” gate:
  - fail CI if demo Firebase project is still referenced
  - fail CI if `orymu.com` is still present
  - fail CI if Android release signing is still debug

### P1 — Enterprise robustness (recommended defaults)

- Add a privacy/consent pattern (even a minimal “analytics disabled until user accepts” flow) and document it.
- Add Dependabot (or an equivalent) + a defined upgrade cadence; `flutter pub get` currently reports many newer versions available.
- Decide and document data-at-rest expectations (encrypted DB or not) and network security expectations (pinning or not).

## Practical adoption checklist for a new project clone

1) Rebrand + identifiers: follow `docs/template/rename_rebrand.md`.
2) Env config: copy examples → active env files, then generate:
   - `cp .env/dev.example.yaml .env/dev.yaml` (repeat for staging/prod)
   - `dart run tool/gen_config.dart --env dev`
3) Replace Firebase config: follow `docs/engineering/firebase_setup.md`.
4) Update deep link domain + allowlists: follow `docs/template/deep_linking.md`.
5) Configure release signing:
   - Android: replace debug signing in `android/app/build.gradle.kts`
   - iOS: set bundle IDs and signing/certs
6) Run verification: `dart run tool/verify.dart --env dev` (or `tool/agent/dartw --no-stdin ...` from WSL).

## Verdict

**As a base template:** ready and valuable today.  
**As an “enterprise production app” without modifications:** not ready (and it shouldn’t be).

The right framing is: this repo is already a strong “internal platform starter kit”, but it needs a small **Template Hardening** backlog to eliminate adoption footguns (stage/staging, doc drift, stale README examples, deterministic CI, and “don’t ship demo Firebase” gates).
