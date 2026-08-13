# CI Clean Environment Preparation

**Plan version:** 2
**Task ID:** ci-clean-env-preparation
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** fix PR 38 clean-runner environment preparation, verify the fix, commit it, and push it to the existing feature branch; do not merge, deploy, release, or change PR review state
**Allowed paths:** .github/workflows/required.yml, packages/mobile_core_kit_cli/test/ci_workflow_policy_test.dart, docs/exec-plans/active/2026-08-12_ci-clean-env-preparation.md, docs/exec-plans/completed/2026-08-12_ci-clean-env-preparation.md
**Allowed actions:** edit, verify, commit, push
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 2h
**Oracle IDs:** harness.full, external.human-review

Date: 2026-08-12
Related issue/PR: https://github.com/fikrilal/mobile-core-kit/pull/38

## Objective

Make the required CI full lane reproduce the environment inputs expected by
the canonical CI verification profile from a clean checkout.

## Constraints

- Architecture constraints: change only CI preparation and its policy test;
  do not weaken environment validation or application architecture checks.
- Product/runtime constraints: use tracked non-secret example files only.
- Out of scope: application behavior, secrets, deployment, merge, release,
  force push, and unrelated workflow refactors.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: yes

## Acceptance Scenarios

1. Given a clean GitHub checkout containing only tracked environment examples,
   when CI Full prepares its inputs and runs the CI profile, then dev, staging,
   and prod schema validation has a corresponding non-secret YAML file.
2. Given the required workflow changes later, when its policy tests run, then
   omitting any required environment copy fails the test.

## Acceptance Criteria

1. CI Full copies all three tracked example environments before bootstrap.
2. The workflow policy test requires each exact source-to-runtime copy.
3. Targeted tests and the canonical full profile pass locally.
4. The CI profile passes from a disposable clean checkout.

## Implementation Checklist

- [x] Prepare all required non-secret environment files in CI Full.
- [x] Add the workflow-policy regression assertion.
- [x] Run targeted, full, and clean-checkout verification.
- [x] Record completion evidence and prepare the focused publication.

## Decision Log

- 2026-08-12: Preserve all-environment validation and supply its declared
  inputs in CI -> weakening validation would hide configuration drift.

## Verification

- `dart test packages/mobile_core_kit_cli/test/ci_workflow_policy_test.dart`
  passed with 4 tests.
- Controller attempt 1 stopped at Dart formatting; the candidate was formatted
  and the repair was recorded within the 2-repair limit.
- `mobilekit task verify --task ci-clean-env-preparation --env dev` attempt 2
  passed the full profile with 206 CLI tests, 11 lint-package tests, 553 Flutter
  tests, and both duplication profiles.
- A disposable detached worktree containing only tracked files plus this patch
  copied all three tracked example environments and passed
  `mobilekit verify --profile ci --env dev`.

## Runtime Evidence

Mobile runtime evidence is unnecessary because this changes CI input
preparation only. The relevant high-risk oracle is the full harness plus a
clean-checkout CI-profile reproduction.

## Rollback

Revert the focused CI-fix commit to restore the prior workflow and test.

## Risks And Mitigations

- Risk: example production configuration could fail strict policy.
- Mitigation: the dev CI run validates schemas without strict production
  invariants, matching the existing CI profile contract.

## Completion Notes

CI Full now prepares every environment that the canonical CI profile validates.
The workflow-policy test binds those exact clean-checkout inputs so the mismatch
cannot recur silently.

## Follow-ups

- [x] No follow-up debt remains.
