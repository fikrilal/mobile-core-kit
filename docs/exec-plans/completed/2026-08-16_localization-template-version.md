# Localization Template Version

**Plan version:** 2
**Task ID:** localization-template-version-v3
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Atomically identify the accepted localization enforcement contract by advancing both mobile-core-kit template version surfaces; preserve all verified localization implementation changes.
**Allowed paths:** docs/exec-plans/active/2026-08-16_localization-template-version.md, docs/exec-plans/completed/2026-08-16_localization-template-version.md, docs/exec-plans/completed/2026-08-16_localization-enforcement.md, .mobilekit/template.yaml, packages/mobile_core_kit_cli/lib/src/template/template_manifest.dart, packages/mobile_core_kit_cli/test/template_manifest_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 3h
**Oracle IDs:** harness.full

Date: 2026-08-16
Related issue/PR: N/A

## Objective

Advance the checked-in template marker and CLI version constant together so
new consumers identify the accepted localization enforcement baseline.

## Constraints

- Architecture constraints: the two version values remain identical.
- Product/runtime constraints: change no customization behavior or managed
  surface beyond the version identifier.
- Out of scope: consumer upgrades and general template-update tooling.

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

1. Given the accepted localization policy, when the template marker is parsed,
   then its version equals `currentTemplateVersion`.
2. Given the complete candidate, when full verification runs, then the marker,
   template tests, and prior localization changes all remain green.

## Acceptance Criteria

1. Both version surfaces are `2026-08-16`.
2. The targeted template manifest test passes.
3. Controlled full verification passes.

## Implementation Checklist

- [x] Advance both version surfaces atomically.
- [x] Run the targeted marker test.
- [x] Run controlled full verification and record evidence.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-16: Use a separate plan -> the marker was outside the immutable path
  authority of the verified localization implementation task.
- 2026-08-16: Change both values together -> the targeted marker test rejects
  a partial version bump.
- 2026-08-16: Supersede the initial task baseline with
  `localization-template-version-v2` -> the first targeted run proved its
  pinned marker fixture is a third coupled path; the two version edits were
  restored before establishing this expanded baseline.
- 2026-08-16: Supersede the second baseline with
  `localization-template-version-v3` -> repository knowledge requires the
  completed parent plan's now-satisfied follow-up checkbox to be updated; all
  version edits were restored before establishing this final baseline.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test/template_manifest_test.dart
dart run mobile_core_kit_cli:mobilekit task preflight --task localization-template-version-v3 --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task localization-template-version-v3
```

- The targeted template-marker suite passed eight tests.
- Preflight passed with five task-owned paths and effective risk `high`.
- Controlled verification selected `full` and passed on attempt 1.
- Repository knowledge, analyzer, custom lint, CLI tests, 19 lint-package
  tests, and all 553 application tests passed.
- The final controller outcome was `OK [verify.full]`.

## Runtime Evidence

Runtime evidence is unnecessary because this changes version metadata only.

## Rollback

Restore both version values to `2026-08-01` together.

## Risks And Mitigations

- Risk: marker and constant drift.
- Mitigation: change both in one task and run the parser contract test.

## Completion Notes

The checked-in template marker, CLI constant, and pinned marker fixture now
identify version `2026-08-16`. The completed localization plan records its
follow-up as satisfied.

## Follow-ups

- [x] No unresolved debt requires the tech debt tracker.
