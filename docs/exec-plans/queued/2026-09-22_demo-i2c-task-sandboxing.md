# Refactor Authentication Presentation Header

**Plan version:** 2
**Task ID:** demo-i2c-task-sandboxing
**Status:** queued
**Owner:** Fikril (I2C Demo)
**Risk:** medium
**Authority:** Refactor the login presentation header to use the core Design System.
**Allowed paths:** lib/features/auth/presentation/
**Allowed actions:** edit, verify
**Maximum risk:** medium
**Repair limit:** 2
**Task timeout:** 45m
**Oracle IDs:** ui.human-review

Date: 2026-09-22
Related issue/PR: N/A

## Objective

Refactor the login presentation header component to align with the core design system tokens while strictly restricting file modifications to the presentation layer of the authentication feature.

## Constraints

- Architecture constraints:
  - Edits must remain strictly within `lib/features/auth/presentation/`.
  - No changes permitted in `lib/core/`, global configs, or data/domain layers.
- Out of scope:
  - Auth domain entity/repository modifications.
  - Backend API or OpenAPI contract changes.
  - Direct git commit or push actions.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given the active plan, when changes stay within `lib/features/auth/presentation/`, then preflight succeeds with effective medium risk.
2. Given changes touching unauthorized files outside `allowed paths`, when preflight runs, then it fails with `task.scope-violation`.
3. Given an unauthorized action such as `commit`, when preflight runs, then it fails with `plan.action-not-allowed`.

## Acceptance Criteria

1. Preflight verifies scoped boundaries and computes deterministic task fingerprint.
2. Scope violations are rejected mechanically.

## Implementation Checklist

- [ ] Inspect `lib/features/auth/presentation/`
- [ ] Run task preflight verification

## Decision Log

- 2026-09-22: Created demo execution plan for I2C IT 2026 presentation and live failure demonstration.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task begin --plan docs/exec-plans/active/2026-09-22_demo-i2c-task-sandboxing.md
dart run mobile_core_kit_cli:mobilekit task preflight --task demo-i2c-task-sandboxing --action verify
```

## Runtime Evidence

Requires registered `ui.human-review` manual review procedure for UI impact.

## Rollback

Revert any modified files in working directory using `git checkout`.

## Risks And Mitigations

- Risk: Demo file touches unintended production code.
- Mitigation: All paths are strictly sandboxed and can be reverted cleanly.

## Completion Notes

Pending live demonstration at I2C IT 2026.

## Follow-ups

- [ ] Archive plan to `completed/` after presentation.
