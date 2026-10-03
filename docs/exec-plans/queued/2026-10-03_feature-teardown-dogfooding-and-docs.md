# Feature Teardown Dogfooding, Full Verification, and Documentation

**Plan version:** 2
**Task ID:** feature-teardown-dogfooding
**Status:** queued
**Owner:** Ahmad Fikril
**Risk:** medium
**Authority:** Dogfood the feature removal engine end-to-end against a scaffolded feature, update developer documentation, and prove full repository verification.
**Allowed paths:** docs/engineering/harness/mobilekit_cli_reference.md, docs/template/first_use_checklist.md, packages/mobile_core_kit_cli/test/cli/mobilekit_cli_test.dart, docs/exec-plans/active/2026-10-03_feature-teardown-dogfooding-and-docs.md
**Allowed actions:** edit, verify
**Maximum risk:** medium
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** harness.full

Date: 2026-10-03
Related issue/PR: [Feature Teardown Proposal](../../_WIP/feature_teardown_engine_proposal.md), [Core Engine Plan](../active/2026-10-03_feature-teardown-engine.md)

## Objective

Dogfood and validate the `mobilekit remove feature` command end-to-end in the live repository by:
1. Scaffolding a temporary test feature (`temp_demo`).
2. Wiring it into router, DI, lints, and ARB files.
3. Executing `mobilekit remove feature temp_demo --yes`.
4. Documenting the new command in reference guides.
5. Verifying that the repository passes full verification gates.

## Constraints

- Architecture constraints:
  - Do not permanently mutate or delete any existing production features in `mobile-core-kit`.
  - Maintain documentation conventions in `docs/engineering/harness/mobilekit_cli_reference.md`.
- Product/runtime constraints:
  - Fast and full verification gates must pass cleanly without regressions.
- Out of scope:
  - Deleting `merchant_onboarding` from the repository template (this remains an optional template decision for product cloners).

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

1. Given a fresh scaffold of `mobilekit scaffold feature temp_test`, when `mobilekit remove feature temp_test --yes` is run, all generated files and wiring references are cleanly removed, and `mobilekit verify --profile fast` succeeds with 0 errors.
2. Given a developer checking CLI documentation, `docs/engineering/harness/mobilekit_cli_reference.md` provides complete syntax, examples, flags, and safety guidelines for `remove feature`.
3. Given `docs/template/first_use_checklist.md`, the checklist instructs new project owners how to quickly remove unneeded demo slices like `merchant_onboarding`.

## Acceptance Criteria

1. CLI integration test for `remove feature` is added to `packages/mobile_core_kit_cli/test/cli/mobilekit_cli_test.dart`.
2. `docs/engineering/harness/mobilekit_cli_reference.md` documents `mobilekit remove feature`.
3. `docs/template/first_use_checklist.md` references the command for template customization.
4. `fvm dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev` passes 100%.

## Implementation Checklist

- [ ] Add CLI contract and routing tests in `packages/mobile_core_kit_cli/test/cli/mobilekit_cli_test.dart`.
- [ ] Perform live dogfooding roundtrip (`scaffold` -> `remove` -> `verify`).
- [ ] Update `docs/engineering/harness/mobilekit_cli_reference.md` with command details.
- [ ] Update `docs/template/first_use_checklist.md` with demo removal recommendations.
- [ ] Execute `mobilekit verify --profile full --env dev` to complete verification.

## Decision Log

- 2026-10-03: Retain `merchant_onboarding` in the template repo -> It serves as the canonical reference implementation for complex aggregates and Maestro flows; the new `remove` command empowers consumers to delete it on first clone.

## Verification

```bash
fvm dart test packages/mobile_core_kit_cli/test/cli/mobilekit_cli_test.dart
fvm dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

## Runtime Evidence

Not required for CLI command and documentation updates.

## Risks And Mitigations

- Risk: Dogfooding scaffold lingers in git working tree.
  Mitigation: Test dogfooding feature teardown completely and run git status verification to confirm zero untracked leftovers.

## Rollback

Revert documentation changes and remove added integration tests in `packages/mobile_core_kit_cli/test/cli/mobilekit_cli_test.dart`.

## Completion Notes

To be populated upon completion of Plan 2.

## Follow-ups

- None.



