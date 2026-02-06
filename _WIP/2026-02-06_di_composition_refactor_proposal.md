# DI Composition Refactor Proposal

Date: 2026-02-06  
Owner: Core Platform  
Status: Completed (PR-1 through PR-4 executed in this change set)

## 1) Problem Statement

`lib/core/di/service_locator.dart` currently acts as:

1. Global dependency registration container
2. Registration order coordinator
3. Async bootstrap coordinator
4. Firebase/Crashlytics/Intl initializer
5. Startup/runtime orchestration entrypoint

This centralization increases merge-conflict frequency and raises ordering/regression risk as the number of cross-cutting subsystems grows.

## 2) Goals

1. Split DI registration into bounded registrars by area ownership.
2. Introduce explicit composition primitives for sync registration and async bootstrap ordering.
3. Keep `service_locator.dart` thin over time (orchestration facade only).
4. Preserve runtime behavior while migrating incrementally.

## 3) Non-Goals

1. Replacing GetIt.
2. Changing feature behavior or startup behavior in PR-1.
3. Rewriting feature module DI contracts.

## 4) Proposed Target Shape

### 4.1 Composition Layer

1. `lib/core/di/composition/register_composer.dart`  
Defines deterministic sync registration sequencing.

2. `lib/core/di/composition/bootstrap_composer.dart`  
Defines deterministic async bootstrap sequencing.

### 4.2 Registrar Layer

1. `lib/core/di/registrars/core_foundation_registrar.dart`
2. `lib/core/di/registrars/core_platform_registrar.dart`
3. `lib/core/di/registrars/core_infra_registrar.dart`
4. `lib/core/di/registrars/core_runtime_registrar.dart`
5. `lib/core/di/registrars/feature_modules_registrar.dart`
6. `lib/core/di/registrars/app_orchestrators_registrar.dart`

### 4.3 Facade Layer

1. `lib/core/di/service_locator.dart`  
Becomes a thin facade that delegates order to composition + registrars.

## 5) Ordering Contract

### 5.1 Sync Registration (future state)

1. Foundation
2. Platform
3. Infra
4. Runtime base
5. Feature modules
6. App orchestrators

### 5.2 Async Bootstrap (future state)

1. Startup-critical preconditions (`PendingDeepLinkController`, `DeepLinkListener`, `AppStartupController.initialize`)
2. Platform-heavy initialization (`Firebase`, `Crashlytics`, `Intl`)
3. Background best-effort initialization (`PushTokenSyncService`, analytics init, connectivity init)

## 6) Migration Strategy

### PR-1 (this execution)

1. Add composition primitives (`RegisterComposer`, `BootstrapComposer`).
2. Add registrar scaffolding files with stable function signatures and no runtime wiring changes yet.
3. Add focused tests to lock sequencing/error behavior at the composition layer.

### PR-2 (executed)

1. Move sync registration blocks into registrars.
2. Introduce a registration composition entrypoint while preserving behavior.

### PR-3 (executed)

1. Move async bootstrap flow into bootstrap composer.
2. Preserve best-effort/fail-open semantics and ordering.

### PR-4 (executed)

1. Reduce `service_locator.dart` to facade-only orchestration.
2. Add integration-level DI bootstrap regression tests.

## 7) Risk Analysis

1. Ordering regressions  
Mitigation: composition tests + explicit ordered steps.

2. Hidden dependencies between registrars  
Mitigation: keep explicit top-level order in a single composer.

3. Partial migration confusion  
Mitigation: scoped PRs and temporary comments in scaffolding indicating migration stage.

## 8) Acceptance Criteria

1. Composition primitives exist and are covered by unit tests.
2. Registrar boundaries exist as stable scaffolding contracts.
3. No runtime behavior change in PR-1.
4. Analyze, custom lint, and tests pass.

## 9) PR-1 Deliverables

1. `lib/core/di/composition/register_composer.dart`
2. `lib/core/di/composition/bootstrap_composer.dart`
3. `lib/core/di/registrars/*` scaffolding files
4. `test/core/di/composition/register_composer_test.dart`
5. `test/core/di/composition/bootstrap_composer_test.dart`
6. `test/core/di/registrars/registrars_smoke_test.dart`

## 10) PR-2 Deliverables

1. `lib/core/di/service_locator.dart` delegates sync registration to `RegisterComposer`
2. Real sync wiring moved into:
   - `lib/core/di/registrars/core_foundation_registrar.dart`
   - `lib/core/di/registrars/core_platform_registrar.dart`
   - `lib/core/di/registrars/core_infra_registrar.dart`
   - `lib/core/di/registrars/core_runtime_registrar.dart`
   - `lib/core/di/registrars/feature_modules_registrar.dart`
   - `lib/core/di/registrars/app_orchestrators_registrar.dart`
3. Added registration-level confidence test:
   - `test/core/di/service_locator_register_test.dart`

## 11) PR-2 Acceptance Criteria Check

1. Sync registration moved out of monolithic `service_locator.dart` into bounded registrars. ✅
2. `service_locator.dart` acts as order-oriented facade for sync registration. ✅
3. Runtime registration behavior preserved via idempotent registration guards and test coverage. ✅
4. Required verification commands pass (`analyze`, `custom_lint`, `test`). ✅

## 12) PR-3 Deliverables

1. Added async bootstrap pipeline abstraction:
   - `lib/core/di/bootstrap/locator_bootstrap_pipeline.dart`
2. `bootstrapLocator()` now delegates to pipeline single-flight orchestration and `BootstrapComposer`.
3. Async startup ordering remains explicit and deterministic:
   - startup-critical stage
   - platform-heavy stage
   - background best-effort stage

## 13) PR-4 Deliverables

1. `lib/core/di/service_locator.dart` reduced to DI facade behavior:
   - sync registration order
   - bootstrap delegation
   - test reset delegation
2. Added integration-level bootstrap regression coverage:
   - `test/core/di/bootstrap/locator_bootstrap_pipeline_test.dart`
3. Preserved fail-open bootstrap semantics and single-flight behavior in tests.

## 14) PR-3/PR-4 Acceptance Criteria Check

1. Async bootstrap flow extracted from monolithic `service_locator.dart`. ✅
2. `BootstrapComposer` used by the runtime bootstrap pipeline. ✅
3. Single-flight bootstrap behavior covered by regression test. ✅
4. Fail-open stage behavior covered by regression test. ✅
5. Required verification commands pass (`analyze`, `custom_lint`, `test`). ✅

## 15) Success Signal

The repository gains a clean DI migration lane with test-backed ordering primitives, while keeping current runtime fully stable during the first incremental step.
