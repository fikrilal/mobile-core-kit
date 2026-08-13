# PR 38 Review Harness Corrections

**Plan version:** 2
**Task ID:** pr38-review-harness-corrections
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** fix the two confirmed PR 38 review findings locally and verify them; do not reply to or resolve review threads, commit, push, merge, deploy, or release
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/events/event_intake.dart, packages/mobile_core_kit_cli/lib/src/task/task_service.dart, packages/mobile_core_kit_cli/lib/src/policy/risk_classifier.dart, packages/mobile_core_kit_cli/lib/src/ci/ci_classification.dart, packages/mobile_core_kit_cli/test/event_intake_test.dart, packages/mobile_core_kit_cli/test/task_service_test.dart, packages/mobile_core_kit_cli/test/risk_classifier_test.dart, packages/mobile_core_kit_cli/test/ci_classification_test.dart, docs/exec-plans/active/2026-08-13_pr38-review-harness-corrections.md, docs/exec-plans/completed/2026-08-13_pr38-review-harness-corrections.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 4h
**Oracle IDs:** harness.full

Date: 2026-08-13
Related issue/PR: https://github.com/fikrilal/mobile-core-kit/pull/38

## Objective

Preserve queued-to-active event promotion as task-owned work and ensure every
auth-sensitive path classified by the shared risk policy selects CI Runtime.

## Constraints

- Architecture constraints: keep task ownership in `TaskService` and reuse one
  auth-sensitive path predicate across risk and CI policy.
- Product/runtime constraints: event recovery and ordinary task begin behavior
  must remain unchanged.
- Out of scope: new agent tooling, changes to publication authority, unrelated
  harness refactors, GitHub thread mutation, commit, push, merge, and release.

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

1. Given event intake promotes an authorized queued plan, when task state is
   created, then the queued deletion and active addition are task-owned rather
   than pre-existing work.
2. Given a path under auth, session, or account deletion changes without a V2
   plan, when CI classifies the diff, then it selects the runtime lane.
3. Given an ordinary task begins in a dirty worktree, when no bootstrap paths
   are supplied, then all existing changes remain protected as pre-existing.

## Acceptance Criteria

1. Event-started tasks can pass freshness checks after successful verification.
2. The CI classifier and risk classifier share the same auth-sensitive path
   predicate.
3. Targeted regressions and the canonical full verification profile pass.

## Implementation Checklist

- [x] Add explicitly scoped task-owned bootstrap paths to task begin.
- [x] Bind event promotion paths to that bootstrap ownership.
- [x] Share auth-sensitive path classification with CI runtime selection.
- [x] Add regressions for ownership, scope protection, session, and account
  deletion paths.
- [x] Run targeted and canonical verification.

## Decision Log

- 2026-08-13: Treat both unresolved P1 comments as legitimate -> each exposes a
  fail-open or permanently blocked path in a controlling harness workflow.
- 2026-08-13: Keep bootstrap ownership explicit and scope-checked -> event
  promotion can be task-owned without weakening normal dirty-worktree safety.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task pr38-review-harness-corrections --action verify
dart test packages/mobile_core_kit_cli/test/task_service_test.dart packages/mobile_core_kit_cli/test/event_intake_test.dart packages/mobile_core_kit_cli/test/risk_classifier_test.dart packages/mobile_core_kit_cli/test/ci_classification_test.dart
dart run mobile_core_kit_cli:mobilekit task verify --task pr38-review-harness-corrections --env dev
```

- Verification preflight passed with eight task-owned implementation and test
  paths and one protected pre-existing plan path.
- The four targeted suites passed with 21 tests.
- Controller-managed full verification passed on attempt 1 with 211 CLI tests,
  11 custom-lint package tests, 553 Flutter tests, analyzer and custom lint,
  code generation, contracts, knowledge checks, and the core and small-helper
  duplication profiles.

## Runtime Evidence

Device runtime evidence is unnecessary because this changes only deterministic
harness policy and controller state; targeted tests plus the full registered
harness oracle exercise the behavior.

## Rollback

Revert the focused implementation and regression changes; no persistent product
or external state is migrated.

## Risks And Mitigations

- Risk: callers could mislabel unrelated dirty work as bootstrap ownership.
- Mitigation: keep the capability internal, require every bootstrap path to be
  present in the plan's allowed paths, and leave normal task begin unchanged.
- Risk: CI runtime policy drifts from risk classification again.
- Mitigation: expose and test one shared auth-sensitive predicate.

## Completion Notes

Event intake now declares only its queued deletion and active addition as
initially task-owned; `TaskService` rejects such paths outside the authorized
scope and continues protecting every other dirty path. CI runtime selection now
uses the same auth/session/account-deletion predicate as high-risk
classification.

## Follow-ups

- [x] No follow-up debt remains.
