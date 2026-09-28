# Scaffold Incremental Slices, Pruned Directories, and State Message Panels

**Plan version:** 2
**Task ID:** scaffold-incremental-slices-and-state-panels
**Status:** completed
**Owner:** Antigravity
**Risk:** low
**Authority:** Extend mobilekit scaffold workflow to support incremental slice scaffolding for existing features, prune untracked empty directories, and integrate AppStateMessagePanel in page templates.
**Allowed paths:** docs/exec-plans/queued/2026-09-23_scaffold-incremental-slices-and-state-panels.md, docs/exec-plans/completed/2026-09-23_scaffold-incremental-slices-and-state-panels.md, packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart, packages/mobile_core_kit_cli/test/scaffold_duplication_test.dart, lib/features/scaffold_test/, lib/navigation/scaffold_test/, test/features/scaffold_test/
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 60m
**Oracle IDs:** harness.full

Date: 2026-09-23
Related issue/PR: N/A

## Objective

Enhance `mobilekit scaffold feature` with:
1. Support for incremental slice generation when scaffolding into an existing feature (`--slice <name>`).
2. Directory pruning so only directories required by generated files are created.
3. Adoption of `AppStateMessagePanel` in scaffolded pages for standard error and success state presentation.

## Constraints

- Architecture constraints:
  - Honor existing layer boundaries.
  - Do not overwrite existing feature files when adding a slice.
- Out of scope:
  - Modifying existing feature business logic in `auth`, `account`, or `merchant_onboarding`.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given a new feature, when running `mobilekit scaffold feature <feature>`, all feature and initial slice files are generated with no empty dead directories.
2. Given an existing feature, when running `mobilekit scaffold feature <feature> --slice <new_slice>`, only the new slice files (`<slice>_page.dart`, `<slice>_cubit.dart`, `<slice>_state.dart`, `<slice>_cubit_test.dart`) are generated without overwriting existing files, and next-steps instruct how to wire DI and routes.
3. Given an existing feature and existing slice, when running `mobilekit scaffold` with colliding names, execution safely refuses.
4. Given generated page code, it renders state transitions using `AppStateMessagePanel` from `core/design_system/widgets/state_message/state_message.dart`.

## Acceptance Criteria

1. Incremental slices succeed for existing features.
2. Collision detection prevents overwriting existing slice files.
3. Only directories containing output files are created.
4. `_pageStub` uses `AppStateMessagePanel`.
5. Automated tests in `scaffold_duplication_test.dart` verify incremental slicing, directory pruning, and `AppStateMessagePanel` presence.
6. `dart test packages/mobile_core_kit_cli` and `flutter analyze` pass.

## Implementation Checklist

- [x] Update `ScaffoldWorkflow` collision logic to differentiate between feature-level and slice-level collisions.
- [x] Filter `outputs` when scaffolding an existing feature to generate only slice files.
- [x] Derive created directories strictly from output files.
- [x] Update `_pageStub` to import and use `AppStateMessagePanel`.
- [x] Add unit tests in `packages/mobile_core_kit_cli/test/scaffold_duplication_test.dart`.
- [x] Verify with real scaffold test feature and `flutter analyze`.

## Decision Log

- 2026-09-23: Use `AppStateMessagePanel` from `state_message/state_message.dart` for structured error and success states in generated pages.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test/scaffold_duplication_test.dart
dart run mobile_core_kit_cli:mobilekit knowledge verify
```

## Runtime Evidence

Unnecessary: CLI tooling and code generation templates only.

## Rollback

Revert changes to `scaffold_workflow.dart` and `scaffold_duplication_test.dart`.

## Risks And Mitigations

- Risk: Existing files overwritten during incremental scaffolding.
- Mitigation: Strict preflight check refusing execution if any target file already exists.

## Completion Notes

All acceptance criteria satisfied:
1. Incremental slices: `ScaffoldWorkflow` detects when a feature exists and outputs only slice-specific files (`<slice>_page.dart`, `<slice>_cubit.dart`, `<slice>_state.dart`, `<slice>_cubit_test.dart`), giving targeted next-steps for DI and router extension.
2. Directory pruning: Directories are derived strictly via `outputs.keys.map(p.dirname)`, ensuring zero empty/untracked directories.
3. Standard state widgets: `_pageStub` adopts `AppStateMessagePanel` from `core/design_system/widgets/state_message/state_message.dart` for success and error views with retry callbacks.
4. Verified via end-to-end multi-slice test feature, `flutter analyze`, `flutter test`, and automated CLI test suite.

## Follow-ups

- None.
