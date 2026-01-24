# TODO — Realize AI Agent Guardrails (Lints + Verify + Scaffolding)

**Project:** `mobile-core-kit`  
**Date:** 2026-01-21  
**Status:** Done (Phases 0–9 complete)  
**Location:** `_WIP/2026-01-21_ai_agent_guardrails_todo.md`  

This TODO document is the implementation checklist to fully realize the guardrails proposed in:

- Guardrails report: `_WIP/2026-01-21_ai_agent_guardrails_high_roi.md`

> Important: there are ongoing local (uncommitted) changes in this repo (auth/user contract work). This plan is written to be **safe to execute in a separate branch/PR** and to avoid “mass refactors” that would conflict with in-progress work.

## Target outcomes (definition of done)

- [ ] **Architecture rules are strict + scalable**:
  - [ ] Domain purity is enforced (no infra/UI leakage into `features/*/domain/**`).
  - [ ] Cross-feature imports are blocked by default (explicit allowlists only).
  - [ ] `service_locator.dart` usage is restricted to composition roots (DI + nav + entrypoints).
- [ ] **Dependency usage is enforced by policy** (not “best effort”):
  - [ ] Low-level packages (`dio`, `firebase_*`, `shared_preferences`, `flutter_secure_storage`, etc.) cannot be imported outside approved directories.
- [ ] **UX consistency becomes boring to review**:
  - [ ] UI string literals are blocked in product UI (must use `context.l10n.*`), with clear allowlists for dev tools/showcases.
  - [ ] Route string literals are blocked (must use route constants).
  - [ ] Datasource API usage is consistent (explicit `host:`, `throwOnError: false`, optionally explicit `requiresAuth:`).
- [ ] **Workflow guardrails exist**:
  - [ ] Verify fails if `tool/untranslated_messages.json` has any entries.
  - [ ] (Optional) Verify fails if generated code is stale (build_runner freshness gate).
- [ ] **The “happy path” is the fastest path**:
  - [ ] A feature/slice scaffolder exists (`tool/scaffold_feature.dart` or similar) that generates the standard structure + tests skeletons and refuses invalid names.
- [ ] **CI parity**:
  - [ ] `tool/verify.dart` remains the canonical “one command” gate and CI runs the same checks.

## Non-goals

- [ ] Rewriting existing features to match the new guardrails (beyond the minimal changes needed to get green).
- [ ] Adding new runtime functionality to production code unless required by the guardrails (e.g., new tokens like `AppRadii` are OK; adding new features is not).

## Guardrail design principles (to keep noise low)

- Prefer **config-driven** lints over bespoke one-off lints.
- Prefer **high-signal, low-false-positive** rules first; expand later.
- Always provide:
  - a narrow allowlist mechanism (`include/exclude` globs, allow prefixes, allow URIs)
  - a suppression mechanism (`ignore:` / `ignore_for_file:`) for rare exceptions
  - a short “why” correction message that points to the canonical pattern in this repo.

---

## Phase 0 — Baseline & decisions (no behavior changes)

- [x] Re-run verification and paste summary here:
  - [x] Ran (skipping tests): `tool/agent/dartw --no-stdin run tool/verify.dart --env dev --skip-tests`
    - ✅ `flutter pub get`
    - ✅ `tool/gen_config.dart --env dev`
    - ✅ `flutter gen-l10n`
    - ✅ `flutter analyze`
    - ✅ `dart run custom_lint`
    - ✅ `tool/verify_modal_entrypoints.dart`
    - ✅ `tool/verify_hardcoded_ui_colors.dart`
    - ⚠️ `dart format (check)` reported 4 changed files but did not fail the verify run; we applied formatting to:
      - `lib/features/user/domain/entity/profile_draft_entity.dart`
      - `lib/features/user/domain/repository/profile_draft_repository.dart`
      - `lib/features/user/domain/usecase/clear_profile_draft_usecase.dart`
      - `lib/features/user/domain/usecase/get_profile_draft_usecase.dart`
    - ⚠️ `dart format` printed repeated warnings about resolving `package:flutter_lints/flutter.yaml` from `analysis_options.yaml` (non-blocking).
- [x] Inventory current “would break” areas before adding new rules:
  - [x] Find cross-feature imports (practical): `rg -n \"package:mobile_core_kit/features/\" lib/features -S --glob 'lib/features/**/*.dart'`
    - Notable cross-feature dependency today:
      - `lib/features/user/di/user_module.dart` imports `features/auth/domain/failure/auth_failure.dart`
  - [x] Find low-level deps imported outside core:
    - [x] `rg -n \"package:dio/dio.dart\" lib -S` → 10 matches (all under `lib/core/network/**` ✅)
    - [x] `rg -n \"package:firebase_\" lib -S` → 6 matches (core DI/services + `lib/firebase_options.dart` ✅)
    - [x] `rg -n \"shared_preferences\" lib -S` → 5 matches
      - Core stores/services ✅
      - Feature-local draft store ❗ `lib/features/user/data/datasource/local/profile_draft_local_datasource.dart`
        - This will influence Phase 2 (`restricted_imports`) allowlists or require introducing a core wrapper for prefs.
    - [x] `rg -n \"flutter_secure_storage\" lib -S` → 2 matches (core secure storage only ✅)
  - [x] Find `locator<` usage: `rg -n \"\\blocator<|\\bGetIt\\b|\\bgetIt\\b\" lib -S` → 159 matches
    - Expected at composition edges (`lib/app.dart`, `lib/main_*.dart`, `lib/navigation/**`)
    - Notable non-edge usages (potential targets for Phase 1 “DI boundary”):
      - `lib/features/profile/presentation/widgets/theme_mode_setting_tile.dart`
      - `lib/features/profile/presentation/widgets/locale_setting_tile.dart`
      - `lib/core/widgets/listener/app_event_listener.dart`
  - [x] Find route string literals:
    - `rg -n \"context\\.(go|push|pushReplacement)\\(\\s*['\\\"]\" lib -S` → 0 matches ✅
    - `rg -n \"GoRoute\\(\\s*path:\\s*['\\\"]\" lib -S` → 0 matches ✅
  - [x] Sample UI string literal scan:
    - `rg -n \"\\bText\\s*\\(\\s*['\\\"]\" lib -S` → 28 matches (mostly dev tools/showcases/docs ✅)
  - [x] Datasource API usage defaults audit:
    - `rg -n \"_apiHelper\\.(getOne|getList|getPaginated|post|put|delete|patch)\" lib/features -S --glob 'lib/features/**/*.dart'` → 7 matches
    - Current state:
      - `features/auth` datasources use explicit `host:`, `requiresAuth:`, `throwOnError: false` ✅
      - `features/user` datasource uses explicit `host:`, `throwOnError: false`, but omits `requiresAuth:` (defaults to `true`) ⚠️
- [ ] Decision locks (write down, then implement):
  - [ ] What is considered “domain-safe” core imports? (recommend: `core/validation/**`, `core/session/entity/**`, `core/user/entity/**` only)
  - [ ] Which rules are **ERROR now** vs “warn first”? (recommend: architecture + restricted imports + ApiHelper policy = ERROR; strings/routes maybe warn→error)
  - [ ] Allowlist locations:
    - [ ] Dev tools/showcases are allowed to use literal strings.
    - [ ] Deep link parsing may need literal strings (host allowlists) — scope those carefully.

---

## Phase 1 — Architecture lint config hardening (config-only)

File: `tool/lints/architecture_lints.yaml`

- [x] Add `feature_domain_no_infra`.
- [x] Add `features_no_cross_feature_imports` (default deny; explicit exceptions only).
  - [x] TEMP exceptions for current reality:
    - [x] `features/profile/**` importing `features/auth/**` for logout UI
    - [x] `features/user/**` importing `features/auth/**` for shared failures/VOs
- [x] Add `no_service_locator_imports_outside_edges`.
  - [x] Allowed scopes: `lib/core/di/**`, `lib/navigation/**`, `lib/app.dart`, `lib/main_*.dart`, `lib/features/*/di/**`
- [x] Run: `tool/agent/dartw --no-stdin run custom_lint` (green).
- [x] Fix violations by refactoring away `locator<...>()` imports in non-edge code:
  - [x] `OnboardingPage` now receives `AppStartupController` from route builder.
  - [x] `ProfilePage` now receives `UserContextService`, `ThemeModeController`, `LocaleController` from router builder.
  - [x] `ThemeModeSettingTile` / `LocaleSettingTile` now require controllers (no locator fallback).
  - [x] `AppEventListener` now receives `AppEventBus` from `app.dart`.
  - [x] `AuthTokenInterceptor` no longer imports the locator; it receives a `sessionManagerProvider` + Dio client.
    - Tests updated accordingly.
- [x] Update docs:
  - [x] `docs/engineering/architecture_linting.md`
  - [x] `docs/engineering/project_architecture.md`

---

## Phase 2 — Implement `restricted_imports` meta-lint (custom_lint)

Files:
- `packages/mobile_core_kit_lints/lib/src/restricted_imports.dart` (new)
- `packages/mobile_core_kit_lints/lib/mobile_core_kit_lints.dart` (register lint)
- `analysis_options.yaml` (enable + config)

- [x] Implement lint behavior:
  - [x] Trigger on `ImportDirective` + `ExportDirective`.
  - [x] Match by URI prefix:
    - [x] `package:dio/dio.dart`
    - [x] `package:firebase_analytics/firebase_analytics.dart`
    - [x] `package:firebase_crashlytics/firebase_crashlytics.dart`
    - [x] `package:shared_preferences/shared_preferences.dart`
    - [x] `package:flutter_secure_storage/flutter_secure_storage.dart`
    - [x] `dart:developer`
  - [x] Allow by file path allowlist globs (config-driven).
- [x] Add `analysis_options.yaml` config:
  - [x] `restricted_imports.include: [lib/**]`
  - [x] `restricted_imports.rules:` list of `{uri, allow, message?}`.
- [x] Add unit tests under `packages/mobile_core_kit_lints/test/`:
  - [x] `packages/mobile_core_kit_lints/test/restricted_imports_test.dart`
- [x] Add docs snippet:
  - [x] `docs/engineering/architecture_linting.md` (document `restricted_imports`).

---

## Phase 3 — UX/content guardrails (custom lints)

### 3.1 `hardcoded_ui_strings`

- [x] Add lint `hardcoded_ui_strings`:
  - [x] Include: UI layers (`lib/core/widgets/**`, `lib/features/**`, `lib/navigation/**`, `lib/presentation/**`)
  - [x] Exclude: dev tools/showcases (`lib/core/dev_tools/**`, `**/*showcase*`)
  - [x] Flag string literals in widget-ish contexts:
    - [x] `Text('...')`
    - [x] `AppText.*('...')`
    - [x] `AppButton.*(text: '...')`
  - [x] Suppression instructions are included in the lint correction message:
    - [x] `// ignore: hardcoded_ui_strings`
    - [x] `// ignore_for_file: hardcoded_ui_strings`

### 3.2 `route_string_literals`

- [x] Add lint `route_string_literals`:
  - [x] Flag `*.go('/...')`, `*.push('/...')`, `*.pushReplacement('/...')` with string literal args.
  - [x] Flag `GoRoute(path: '/...')` with string literal path.
  - [x] Require route constants (`AppRoutes.*`, `<feature>Routes.*`).
  - [x] (No exclusions needed yet; deep-link parsing is out of scope for the AST patterns we lint.)

---

## Phase 4 — Networking correctness guardrails (custom lint)

### 4.1 `api_helper_datasource_policy`

Goal: make datasource code deterministic + reviewable.

- [x] Add lint applied to: `lib/features/*/data/datasource/**`
- [x] For calls to `_apiHelper.*`:
  - [x] Require explicit `host:`
  - [x] Require `throwOnError: false`
  - [x] Require explicit `requiresAuth:` (true/false) (enabled in `analysis_options.yaml`)
- [x] Fix callsites:
  - [x] `lib/features/user/data/datasource/remote/user_remote_datasource.dart` now passes `requiresAuth: true`

---

## Phase 5 — Workflow guardrails (verify scripts)

### 5.1 Untranslated messages gate

- [x] Add: `tool/verify_untranslated_messages.dart`
  - [x] Fail if `tool/untranslated_messages.json` contains any entries.
  - [x] Provide actionable output (prints top missing keys when possible).
- [x] Call it from `tool/verify.dart` after `flutter gen-l10n`.
- [x] Add to CI (`.github/workflows/android.yml`) after `flutter gen-l10n`.

### 5.2 (Optional) Codegen freshness gate

- [x] Decide: do we want build_runner in every PR CI? **Yes.**
- [x] Add `tool/verify_codegen.dart`:
  - [x] Run `build_runner`.
  - [x] Fail if generated outputs differ (checks `*.g.dart` / `*.freezed.dart` / `*.gr.dart` diffs).
- [x] Add to CI (`.github/workflows/android.yml`) after `flutter pub get`.
- [x] Optional local usage:
  - [x] `dart run tool/verify.dart --env dev --check-codegen`

---

## Phase 6 — Tokens expansion (only if/when you want more UI strictness)

### 6.1 Radius tokens + lint

- [x] Add token file: `lib/core/theme/tokens/radii.dart` (`AppRadii.*`)
- [x] Add lint `radius_tokens` that flags numeric `Radius.circular` / `BorderRadius.circular` in UI code.

### 6.2 Icon size tokens + lint (high-signal)

- [x] Add lint `icon_size_tokens` that flags `Icon(size: <number>)`/`PhosphorIcon(size: <number>)` and `IconButton(iconSize: <number>)` in UI code and requires `AppSizing.iconSize*`.

---

## Phase 7 — “Make the right thing easy” (feature scaffolder)

- [x] Add script: `tool/scaffold_feature.dart`
- [x] CLI shape:
  - [x] `dart run tool/scaffold_feature.dart --feature review`
  - [x] optional: `--slice list`
- [x] Generates:
  - [x] Standard folder layout under `lib/features/<feature>/...`
  - [x] DI module stub in `lib/features/<feature>/di/<feature>_module.dart`
  - [x] Route stubs under `lib/navigation/<feature>/...`
  - [x] Presentation skeleton (Cubit-first), including status enum pattern
  - [x] Tests skeleton mirroring `lib/` under `test/`
  - [x] Prints l10n key checklist (manual add; avoids creating untranslated keys)
- [x] Guardrails:
  - [x] Refuse invalid feature name (must be `snake_case`)
  - [x] Refuse if feature already exists
  - [x] Prints wiring next steps (DI + routes + verify)

---

## Phase 8 — Documentation + onboarding

- [x] Add a single “Guardrails index” doc:
  - [x] `docs/engineering/guardrails.md`
- [x] Update `README.md` to link the guardrails index.
- [x] Add a short “AI agent workflow” doc:
  - [x] `docs/engineering/ai_agent_workflow.md`

---

## Phase 9 — CI alignment

- [x] CI calls `tool/verify.dart` as the single entrypoint:
  - [x] `.github/workflows/android.yml` runs `dart run tool/verify.dart --env prod --check-codegen`
- [x] Flutter version pinning is explicit:
  - [x] `.github/workflows/android.yml` reads the pinned version from `.fvmrc` and passes it to `subosito/flutter-action`.
