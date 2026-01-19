# mobile-core-kit — Enterprise Readiness Audit

Date: 2026-01-19  
Scope: repo-level audit for “clone-and-customize” usage as a base Flutter app template.

## Executive Summary

Verdict: **Ready to be used as a foundation for enterprise apps, but not “ship-ready as-is”.**

This repo is unusually strong for a starter kit: it has enforced architecture boundaries, a coherent core/network/session story, deep-link safety, localization discipline, and a real (test-covered) auth slice. That said, there are a couple of **template-level correctness issues** and several **enterprise-adoption gaps** (privacy/consent, release hardening, CI completeness) that should be addressed before treating it as the company’s “golden starter”.

### What’s already in good shape

- Clean Architecture + vertical slices with **custom_lint import boundaries**.
- Network stack with sensible interceptor ordering + **token refresh + safe retry policy**.
- Early error buffering + Crashlytics wiring designed for fast startup.
- Localization system with pseudo-locales and environment gating.
- Core UI tokenization enforced (hardcoded color/spacing/font-size rules).
- Meaningful unit test coverage including golden tests and redirect/deep-link tests.

### Key blockers / high risks

- **Critical:** Environment naming mismatch (`BuildEnv.stage` vs `staging` everywhere else) will likely crash staging builds when using `--dart-define=ENV=staging`.
- **Medium:** Module registration can be called multiple times per process; DB onCreate tasks are appended without dedupe (safe today because queries are idempotent, but risky as the template grows).
- **High (policy-driven):** Analytics/Crash reporting consent is not implemented (only documented as a future hook).

## Evidence (What Was Run)

Environment:
- Flutter `3.38.4` (stable)
- Dart `3.10.3`

Commands executed:

- `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`
  - Flutter analyze: **No issues**
  - custom_lint: **No issues**
  - modal entrypoints verifier: **OK**
  - hardcoded UI colors verifier: **OK**
  - `flutter test`: **All tests passed** (234 tests)
  - `dart format --set-exit-if-changed .`: **OK** (note: emitted warnings about resolving `package:flutter_lints/flutter.yaml`)

- `tool/agent/flutterw --no-stdin pub outdated`
  - Minor dependency updates available (mostly Firebase packages + a few tooling deps); nothing obviously alarming, but upgrades should be scheduled.

## Template Maturity Review (By Area)

### 1) Architecture & Boundaries

Strong:
- `tool/lints/architecture_lints.yaml` enforces core/feature boundaries and Clean Architecture constraints. This is a major maturity marker and prevents “template entropy”.
- Feature slices follow consistent data/domain/presentation layout and DI modules.

Gaps:
- The lint rules explicitly acknowledge temporary exceptions:
  - `lib/core/di/**` and `lib/core/session/**` importing feature types.
  - `lib/core/services/app_startup/**` coordinating feature usecases.

Recommendation:
- Treat this as an explicit “app-layer” boundary problem: either introduce an `app/` layer (composition root) or move the orchestration types to a clearly-defined module (so `core/` can remain infrastructure-only).

### 2) Network, Auth, and Session Management

Strong:
- Interceptor order is correct: base URL → headers → auth token + refresh → logging → error.
- `AuthTokenInterceptor` implements an enterprise-safe retry policy:
  - GET/HEAD retry after refresh.
  - Writes require `Idempotency-Key` to be retried.
- Network logging supports modes + redaction and defaults to off in prod.
- Session persistence uses `flutter_secure_storage` with sane platform options; session hydration has guardrails for races.

Gaps / risks:
- Idempotency key generation is not provided as a standard helper; feature teams may forget to set it on non-idempotent writes that can 401.
- `ErrorInterceptor` is mostly logging; the real “policy” lives in `ApiFailure` + feature failure mapping. That’s fine, but document the intended responsibilities clearly to avoid future duplication.

Recommendation:
- Add a small `IdempotencyKey` helper (or interceptor that auto-adds for selected endpoints) as a template-level pattern.
- Tighten docs/contracts so backend + mobile share a single refresh/retry contract source of truth.

### 3) Startup, Deep Links, and Navigation

Strong:
- `AppStartupController` gates routing with timeouts and fail-safe defaults.
- Deep link system is allowlist-based and uses a pending-intent model to avoid unsafe early navigation.
- Redirect logic is tested (including allowlist rejection + resume semantics).
- Startup timing metrics exist and are structured.

Gaps:
- Deep link host allowlist defaults to a specific domain (`orymu.com`). This is fine for the template demo, but it’s an easy footgun when cloning for a new product.

Recommendation:
- Move deep link allowed hosts/paths to generated config (or a single place teams must edit when cloning).

### 4) Localization & UX Discipline

Strong:
- ARB workflow is configured with strict flags (`required-resource-attributes`, untranslated output file, preferred locales).
- Pseudo-locales are supported but gated to dev builds.
- There are unit tests around localization and pluralization.

Gaps:
- None obvious at template level.

### 5) Observability, Privacy, and Compliance

Strong:
- Crashlytics is gated to prod by default and errors are buffered until Crashlytics is ready.
- Analytics is abstracted (`IAnalyticsService` + `AnalyticsTracker`) and has environment-aware debug logging.

Gaps (enterprise policy-dependent):
- There is no implemented consent/preferences layer; analytics is enabled by default in prod via config.
- Deep link persistence uses SharedPreferences and stores the full location (query string included); if a product encodes PII/tokens in query params, this becomes sensitive storage.

Recommendations:
- Add a first-class “privacy & consent” module (even if minimal) and default analytics/crash reporting to opt-in/region-aware where required.
- Add a policy statement: “never put tokens/PII in deep link query params”; enforce via parsing allowlists and/or redaction.

### 6) CI/CD and Release Hardening

Strong:
- `.github/workflows/android.yml` runs a solid baseline: pub get, build config generation, gen-l10n, analyze, custom lint, unit tests, and prod builds on non-PR events.
- Lints package tests are included.

Gaps:
- Integration tests under `integration_test/` are not run by default (expected, since emulator setup is heavier).
- Android signing + applicationId are intentionally TODO for a template; teams must configure before real releases.

Recommendations:
- Add an optional (commented or manual) job that runs `integration_test/` on an Android emulator for product repos derived from this template.
- Provide a “clone checklist” doc section that makes release-critical substitutions unavoidable.

## Critical Findings (Fix in the Template Before Broad Adoption)

### C1 — Environment key mismatch (Critical)

Problem:
- `lib/core/configs/build_config.dart` defines `enum BuildEnv { dev, stage, prod }`
- Documentation, scripts, flavors, and env files use `staging` (not `stage`).
- If a developer runs with `--dart-define=ENV=staging`, `BuildEnv.values.firstWhere(...)` will throw and crash on startup.

Fix options (choose one, but do it once in the template):
1) Rename enum value `stage` → `staging` and update references.
2) Make parsing robust:
   - accept both `stage` and `staging`,
   - fail safe to `dev` (or throw with a clearer error).

### C2 — Duplicate DB create tasks via repeated DI/module registration (Medium, becomes High later)

Problem:
- `registerLocator()` is called in `main_*` and again inside `bootstrapLocator()`.
- `AuthModule.register()` calls `AppDatabase.registerOnCreate(...)` unconditionally.
- Today it’s safe because the create query uses `IF NOT EXISTS`, but future tasks/migrations may not be idempotent.

Fix options:
- Guard DB task registration (e.g., make it idempotent by key/name, or register only once).
- Alternatively, ensure `registerLocator()` is only called once per process and bootstrap only does async init.

## “Clone Checklist” (Per New Product Repo)

Mandatory before shipping:
- Replace demo Firebase config (`flutterfire configure`) and decide what platform configs are committed vs secret-provisioned.
- Update application identifiers:
  - Android: `android/app/build.gradle.kts` (`namespace`, `applicationId`, signing).
  - iOS: bundle IDs, entitlements, and any universal-link hosts.
- Replace `.env/*.yaml` hosts and regenerate `build_config_values.dart`.
- Confirm deep link allowlist hosts/paths and tests.
- Decide privacy policy + consent handling for analytics/crash reporting; set defaults accordingly.
- Remove or implement unused dependencies/features you don’t intend to ship (e.g., `firebase_messaging` if unused).

## Recommended Next Backlog (Template Hardening)

P0 (same day / next day):
- Fix environment mismatch (`stage` vs `staging`).
- Make DB onCreate/migrations registration idempotent.

P1 (this week):
- Add a minimal privacy/consent preference layer (even if only for analytics/crash toggles).
- Make deep link allowlist configurable and harder to miss when cloning.
- Decide and document policy for idempotency keys on write endpoints.

P2 (next 2–4 weeks, optional):
- Add lightweight security/dependency automation (Dependabot/renovate + scheduled `pub upgrade` PRs).
- Add optional emulator-driven integration test workflow (off-by-default for the template; on-by-default for product repos).
- Audit dependencies and remove unused ones to reduce maintenance surface.

## Bottom Line

If you treat this repo as a **template**, it is close to enterprise-grade already. Fix the environment mismatch and DI/DB registration idempotency, and add privacy/consent scaffolding, and it becomes a strong “golden starter” for multiple future apps.

