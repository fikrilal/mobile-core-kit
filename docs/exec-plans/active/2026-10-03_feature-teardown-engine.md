# Build Feature Teardown Engine Core in Mobilekit CLI

**Plan version:** 2
**Task ID:** feature-teardown-engine
**Status:** active
**Owner:** Ahmad Fikril
**Risk:** high
**Authority:** Implement the core feature teardown and unwiring workflow inside packages/mobile_core_kit_cli along with comprehensive unit and mock-filesystem tests.
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/workflows/remove_feature_workflow.dart, packages/mobile_core_kit_cli/lib/src/workflows/feature_unwiring_engine.dart, packages/mobile_core_kit_cli/lib/src/workflows/arb_key_pruner.dart, packages/mobile_core_kit_cli/test/workflows/remove_feature_workflow_test.dart, packages/mobile_core_kit_cli/test/workflows/arb_key_pruner_test.dart, docs/exec-plans/active/2026-10-03_feature-teardown-engine.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** harness.full

Date: 2026-10-03
Related issue/PR: [Feature Teardown Proposal](../../_WIP/feature_teardown_engine_proposal.md)

## Objective

Introduce the core `mobilekit remove feature <feature_name>` capability into `packages/mobile_core_kit_cli`. The command cleanly unwires and deletes an existing decoupled feature slice (code, navigation, tests, DI, router, architecture lints, and localization keys), protected by `--dry-run` and core slice guards.

## Constraints

- Architecture constraints:
  - Keep all implementation inside `packages/mobile_core_kit_cli`.
  - Guard foundational core slices (`auth`, `account`, `home`, `onboarding`) from deletion unless `--force-core` is supplied.
  - Implement pattern matching and code rewrites idempotently to prevent corruption if run against already partially unlinked features.
- Product/runtime constraints:
  - Support `--dry-run` to preview all deletions and code rewrites without disk mutations.
  - Support `--keep-l10n` to opt-out of ARB key pruning.
  - Support `--yes` / `-y` for non-interactive automation.
- Out of scope:
  - Deleting live product features from `mobile-core-kit` repository itself during this unit phase.
  - Documentation and dogfooding (covered in Phase 2).

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given a mock project with a feature `review`, when `mobilekit remove feature review --dry-run` is called, it outputs the planned directory deletions, file deletions, unwiring points, and ARB keys to prune without modifying any files.
2. Given a protected feature name (e.g. `auth` or `account`), when `mobilekit remove feature auth` is called without `--force-core`, the command aborts with an actionable error and exit code 2.
3. Given an invalid name (e.g. `MyFeature` or `feature-name`), the command fails with exit code 2 and snake_case format guidance.
4. Given a valid feature `review` in a mock directory, when `remove feature review --yes` is executed, it:
   - Deletes `lib/features/review/`, `lib/navigation/review/`, `test/features/review/`, and `test/navigation/review/`.
   - Removes imports and route lists from `lib/navigation/app_router.dart`.
   - Removes imports and module registration from `lib/core/di/registrars/feature_modules_registrar.dart`.
   - Removes exception globs from `lint/architecture_lints.yaml`.
   - Removes matching oracle entries from `harness/oracles.yaml` and deletes `maestro/review.yaml`.
   - Prunes matching `review*` and `@review*` keys from `lib/l10n/*.arb`.

## Acceptance Criteria

1. `ArbKeyPruner` parses and correctly strips prefix-matched keys and metadata while preserving formatting in valid JSON.
2. `FeatureUnwiringEngine` accurately strips registrations across all 5 known wiring files without syntax damage.
3. `RemoveFeatureWorkflow` and CLI command routing are covered by comprehensive unit tests in `packages/mobile_core_kit_cli/test/`.
4. `fvm dart test packages/mobile_core_kit_cli/test` passes 100%.

## Implementation Checklist

- [x] Implement `ArbKeyPruner` in `packages/mobile_core_kit_cli/lib/src/workflows/arb_key_pruner.dart`.
- [x] Add unit tests for `ArbKeyPruner` in `packages/mobile_core_kit_cli/test/workflows/arb_key_pruner_test.dart`.
- [x] Implement `FeatureUnwiringEngine` in `packages/mobile_core_kit_cli/lib/src/workflows/feature_unwiring_engine.dart`.
- [x] Implement `RemoveFeatureWorkflow` in `packages/mobile_core_kit_cli/lib/src/workflows/remove_feature_workflow.dart`.
- [x] Route `remove feature <name>` in `packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart`.
- [x] Add full workflow unit tests in `packages/mobile_core_kit_cli/test/workflows/remove_feature_workflow_test.dart`.
- [x] Verify with CLI test suite and fast verification gate.

## Decision Log

- 2026-10-03: Use bounded regex and string rewrites instead of heavy Dart analyzer AST manipulation -> Faster, self-contained within CLI without adding analyzer dev-dependencies to mobilekit_cli.
- 2026-10-03: Require `--force-core` for `auth`, `account`, `home`, `onboarding` -> Protects developer against catastrophic accidental teardown.

## Verification

```bash
fvm dart test packages/mobile_core_kit_cli/test/workflows/arb_key_pruner_test.dart
fvm dart test packages/mobile_core_kit_cli/test/workflows/remove_feature_workflow_test.dart
fvm dart test packages/mobile_core_kit_cli/test
fvm dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
```

## Runtime Evidence

Not required for this pure CLI package capability.

## Risks And Mitigations

- Risk: Unwiring regex damages nearby code in registration files.
  Mitigation: Use exact line-based matching and bounded patterns; verify syntax via `fvm dart analyze` and unit tests.
- Risk: Accidental deletion of core application slices.
  Mitigation: Enforce hardcoded `ProtectedCore` barrier requiring explicit `--force-core`.

## Rollback

Revert the plan commit or discard edits to `packages/mobile_core_kit_cli`. The core codebase outside `packages/mobile_core_kit_cli` remains untouched.

## Completion Notes

Plan 1 implemented end-to-end:
1. Created `ArbKeyPruner` to strip matching keys and `@key` metadata across all locale files in valid JSON.
2. Created `FeatureUnwiringEngine` with clean, bounded regex patterns to unwire `app_router.dart`, `feature_modules_registrar.dart`, `home_page.dart`, `architecture_lints.yaml`, and `oracles.yaml`.
3. Created `RemoveFeatureWorkflow` with `--dry-run`, `--yes`, `--keep-l10n`, and `ProtectedCore` prevention for `auth`, `account`, `home`, `onboarding`.
4. Routed `remove feature` in `mobilekit_cli.dart`.
5. Added unit test suites `arb_key_pruner_test.dart` and `remove_feature_workflow_test.dart` (10 new tests, 100% passing).
6. Task verified via `mobilekit task verify --task feature-teardown-engine --env dev`, passing all 672 application tests and 279 CLI package tests.

## Follow-ups

- Execute Phase 2 (`feature-teardown-dogfooding`) for end-to-end repository dogfooding and documentation.



