# TODO — Realize AI Agent Guardrails (Lints + Verify + Scaffolding)

**Project:** `mobile-core-kit`  
**Date:** 2026-01-21  
**Status:** In progress (Phase 0 started)  
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

- [ ] Add `feature_domain_no_infra`:
  - [ ] `from: lib/features/*/domain/**`
  - [ ] `deny:` add:
    - [ ] `lib/core/network/**`
    - [ ] `lib/core/services/**`
    - [ ] `lib/core/storage/**`
    - [ ] `lib/core/database/**`
    - [ ] `lib/core/theme/**`
    - [ ] `lib/core/widgets/**`
    - [ ] `lib/core/adaptive/**`
    - [ ] `lib/core/di/**`
    - [ ] `lib/core/dev_tools/**`
    - [ ] `lib/l10n/**`
- [ ] Add `features_no_cross_feature_imports` (default deny; explicit exceptions only):
  - [ ] `from: lib/features/*/**`
  - [ ] `deny: lib/features/**`
  - [ ] Exceptions (only if truly required; keep very short):
    - [ ] allow `lib/features/<X>/**` → `lib/features/<Y>/domain/**` only when there is a formal “shared contract”, otherwise move it to `lib/core/**` or a `packages/*` module.
- [ ] Add `no_service_locator_imports_outside_edges`:
  - [ ] `from: lib/**`
  - [ ] `deny: lib/core/di/service_locator.dart`
  - [ ] Exceptions allow importing it only from:
    - [ ] `lib/core/di/**`
    - [ ] `lib/navigation/**`
    - [ ] `lib/app.dart`
    - [ ] `lib/main_*.dart`
    - [ ] `lib/features/*/di/**`
- [ ] Run: `dart run custom_lint` (or `tool/agent/dartw --no-stdin run custom_lint`) and fix/allowlist as needed.
- [ ] Update docs:
  - [ ] `docs/engineering/architecture_linting.md` (document the new rules + rationale).
  - [ ] `docs/engineering/project_architecture.md` (if it references patterns that these rules now forbid).

---

## Phase 2 — Implement `restricted_imports` meta-lint (custom_lint)

Files:
- `packages/mobile_core_kit_lints/lib/src/restricted_imports.dart` (new)
- `packages/mobile_core_kit_lints/lib/mobile_core_kit_lints.dart` (register lint)
- `analysis_options.yaml` (enable + config)

- [ ] Implement lint behavior:
  - [ ] Trigger on `ImportDirective` + `ExportDirective`.
  - [ ] Match by URI prefix:
    - [ ] `package:dio/dio.dart`
    - [ ] `package:firebase_analytics/firebase_analytics.dart`
    - [ ] `package:firebase_crashlytics/firebase_crashlytics.dart`
    - [ ] `package:shared_preferences/shared_preferences.dart`
    - [ ] `package:flutter_secure_storage/flutter_secure_storage.dart`
    - [ ] optional: `dart:developer`
  - [ ] Allow by file path allowlist globs (config-driven).
- [ ] Add `analysis_options.yaml` config shape (example):
  - [ ] `restricted_imports.include: [lib/**]`
  - [ ] `restricted_imports.rules:` list of `{uri, allow, message?}`.
- [ ] Add unit tests for config parsing/matching (pure tests under `packages/mobile_core_kit_lints/test/`).
- [ ] Add docs snippet:
  - [ ] `docs/engineering/project_architecture.md` or a new `docs/engineering/guardrails.md` section.

---

## Phase 3 — UX/content guardrails (custom lints)

### 3.1 `hardcoded_ui_strings`

- [ ] Add lint `hardcoded_ui_strings`:
  - [ ] Include: UI layers (`lib/core/widgets/**`, `lib/features/**`, `lib/navigation/**`, `lib/presentation/**`)
  - [ ] Exclude: dev tools/showcases (`lib/core/dev_tools/**`, `**/*showcase*`)
  - [ ] Flag string literals in widget-ish contexts (start narrow; expand later):
    - [ ] `Text('...')`
    - [ ] `AppText.*('...')`
    - [ ] `AppButton(... text: '...')`
    - [ ] `AppBar(title: Text('...'))`
  - [ ] Allowlist:
    - [ ] semantics/analytics IDs if needed (by file scope or constant prefix)
    - [ ] dev tools/showcase already excluded
- [ ] Add suppression instructions (in lint correction message):
  - [ ] `// ignore: hardcoded_ui_strings`
  - [ ] `// ignore_for_file: hardcoded_ui_strings`

### 3.2 `route_string_literals`

- [ ] Add lint `route_string_literals`:
  - [ ] Flag `context.go('/...')`, `context.push('/...')`, `context.pushReplacement('/...')` with string literal args.
  - [ ] Flag `GoRoute(path: '/...')` with string literal path.
  - [ ] Require route constants (`AppRoutes.*`, `<feature>Routes.*`).
  - [ ] Exclude deep-link parsing / test-only routing helpers if needed (path-based excludes).

---

## Phase 4 — Networking correctness guardrails (custom lint)

### 4.1 `api_helper_datasource_policy`

Goal: make datasource code deterministic + reviewable.

- [ ] Add lint applied to: `lib/features/*/data/datasource/**`
- [ ] For calls to `_apiHelper.*`:
  - [ ] Require explicit `host:`
  - [ ] Require `throwOnError: false`
  - [ ] (Optional) require explicit `requiresAuth:` (true/false)
- [ ] Allowlist:
  - [ ] core networking layers (`lib/core/network/**`) excluded entirely

---

## Phase 5 — Workflow guardrails (verify scripts)

### 5.1 Untranslated messages gate

- [ ] Add: `tool/verify_untranslated_messages.dart`
  - [ ] Fail if `tool/untranslated_messages.json` contains any entries.
  - [ ] Provide actionable output (top N missing keys; suggest `flutter gen-l10n`).
- [ ] Call it from `tool/verify.dart` after `flutter gen-l10n`.
- [ ] Add to CI (`.github/workflows/android.yml`) if CI doesn’t run `tool/verify.dart` directly.

### 5.2 (Optional) Codegen freshness gate

- [ ] Decide: do we want build_runner in every PR CI?
  - If yes:
    - [ ] Add `tool/verify_codegen.dart`:
      - [ ] run build_runner
      - [ ] fail if generated outputs differ (via `git diff --exit-code`)
  - If no:
    - [ ] Provide a human+agent checklist and keep `tool/verify.dart` as-is.

---

## Phase 6 — Tokens expansion (only if/when you want more UI strictness)

### 6.1 Radius tokens + lint

- [ ] Add token file: `lib/core/theme/tokens/radii.dart` (`AppRadii.*`)
- [ ] Add lint `radius_tokens` that flags numeric `Radius.circular` / `BorderRadius.circular` in UI code (exclude core theme builder if needed).

### 6.2 Icon size tokens + lint (high-signal)

- [ ] Add lint `icon_size_tokens` that flags `Icon(size: <number>)` outside allowed scopes and requires `AppSizing.iconSize*`.

---

## Phase 7 — “Make the right thing easy” (feature scaffolder)

- [ ] Add script: `tool/scaffold_feature.dart` (or `tool/new_slice.dart`)
- [ ] CLI shape (example):
  - [ ] `dart run tool/scaffold_feature.dart --feature review`
  - [ ] optional: `--slice list`, `--with-form`, `--with-analytics`, `--with-skeleton`
- [ ] Generates:
  - [ ] Standard folder layout under `lib/features/<feature>/...`
  - [ ] DI module stub in `lib/features/<feature>/di/<feature>_module.dart`
  - [ ] Route list stubs under `lib/navigation/<feature>/...`
  - [ ] Presentation skeleton (Cubit-first by default), including status enum pattern
  - [ ] Tests skeleton mirroring `lib/` under `test/`
  - [ ] Checklist output for l10n keys (or optional automated insertion)
- [ ] Guardrails:
  - [ ] Refuse invalid feature name (must be `snake_case`)
  - [ ] Refuse if feature already exists
  - [ ] Print next steps (run verify, run build_runner if needed)

---

## Phase 8 — Documentation + onboarding

- [ ] Add a single “Guardrails index” doc:
  - [ ] `docs/engineering/guardrails.md` (or extend `docs/engineering/architecture_linting.md`)
  - [ ] List every guardrail with:
    - [ ] what it enforces
    - [ ] where it runs (IDE/CI)
    - [ ] how to fix
    - [ ] how to suppress (rare)
- [ ] Update `README.md` to link the guardrails index and reinforce `tool/verify.dart` as the gate.
- [ ] Optional: add a short “AI agent workflow” doc:
  - [ ] where new code should go
  - [ ] which script to run
  - [ ] how to interpret lint failures

---

## Phase 9 — CI alignment

- [ ] Decide whether CI should call `dart run tool/verify.dart --env prod` as the single entrypoint.
  - [ ] If yes: keep `.github/workflows/android.yml` thin and use verify as the contract.
  - [ ] If no: ensure each new verify step is duplicated in CI explicitly.
- [ ] Ensure Flutter version pinning policy is explicit (FVM vs stable channel) so “random CI breakage” doesn’t poison guardrails trust.
