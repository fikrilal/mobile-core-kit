# Harness Evidence Integrity — Commit Baseline

**Plan version:** 2
**Task ID:** harness-evidence-commit-v2
**Status:** completed
**Owner:** Muse Spark
**Risk:** high
**Authority:** User explicitly authorized commit of the verified harness-evidence candidate on 2026-09-07 ("yes I allowed"). v5 baseline verified green but its dry-run was correctly refused: a scratch begin-helper existed at v5 begin time, so the baseline was not clean. This v2 baseline re-records the identical candidate with an outside-repo begin helper, so pre-existing is empty. Scope: stage and commit ONLY the exact task-owned harness paths listed below; no code edits; no push, PR, merge, or deployment authority.
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/handoff/completion_evidence.dart, packages/mobile_core_kit_cli/lib/src/handoff/handoff_service.dart, packages/mobile_core_kit_cli/lib/src/handoff/handoff_workflow.dart, packages/mobile_core_kit_cli/lib/src/task/task_controller.dart, packages/mobile_core_kit_cli/lib/src/maintenance/maintenance_service.dart, packages/mobile_core_kit_cli/lib/src/evidence/operating_evidence.dart, .github/workflows/required.yml, .github/workflows/governance.yml, harness/oracles.yaml, docs/engineering/harness/agent_pr_loop.md, docs/engineering/harness/mobile_runtime_harness.md, docs/engineering/harness/event_maintenance_handoff.md, docs/engineering/harness/harness_operating_evidence.md, docs/engineering/harness/behavioral_oracles.md, docs/engineering/harness/controlled_verification_loop.md, docs/engineering/harness/mobilekit_cli_reference.md, docs/exec-plans/active/2026-09-07_harness-evidence-commit-v2.md, docs/exec-plans/completed/2026-09-07_harness-evidence-integrity-v4.md, packages/mobile_core_kit_cli/test/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, docs/engineering/harness/task_authority.md
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 2h
**Oracle IDs:** harness.full

Date: 2026-09-07
Related issue/PR: N/A

## Objective

Commit the exact verified harness-evidence candidate (v4 fingerprint
`ee8a208bd1ce048d941aebccb4980073c88a3711dcecc86780e33a20ee339b9a`,
full lane green three times, `handoff check` passed read-only) plus the
mechanical v4 plan retirement to `completed/`. Nothing else.

## Constraints

- No code changes. If preflight shows any drift from the expected 27 paths or
  any non-empty pre-existing set, stop and report instead of committing.
- Stage exact task-owned paths only; never `git add -A`.
- Verify staged equality before commit via the handoff adapter path check.
- Commit message: `feat(harness): evidence-bound completion, coverage CI, drift-safe verification`.
- Base for this baseline is current HEAD `9a58c3c`; your merchant-onboarding
  commit stays below the baseline and your onboarding files are untouched.
- `_WIP/` docs stay out in `~/wip_backup_20260907/`; do not restore or stage them.
- No push, draft-pr, merge, or deploy. Commit only.

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

1. Given the exact 27-path candidate with empty pre-existing set, when dry-run
   runs, then a 15-minute commit approval issues with evidence ready (or
   explicitly INCOMPLETE with reasons, in which case stop).
2. Given a fresh approval, when commit executes, then exactly those paths land
   in one local commit on `demo/merchant-onboarding-validation` and nothing else.

## Acceptance Criteria

1. Preflight commit shows 27 task-owned paths, 0 pre-existing.
2. `task verify` passes and `handoff check` passes read-only.
3. `handoff dry-run --action commit` succeeds and prints the challenge.
4. `handoff commit` with `MOBILEKIT_HANDOFF_APPROVAL` succeeds; `git log -1`
   and `git status` confirm exactly one new local commit, worktree clean of
   task paths.

## Implementation Checklist

- [x] Begin commit baseline via outside-repo helper, confirm empty pre-existing set.
- [x] Verify full lane, confirm handoff check passes.
- [x] Dry-run commit; capture challenge without echoing it.
- [x] Execute commit with fresh user approval token.
- [x] Confirm commit hash, clean status, episode trail.

## Decision Log

- 2026-09-07: v5 verified green (`verified`, full lane, `handoff check` passed)
  but dry-run was refused with `handoff.task-not-ready`: the v5 begin ran from
  a scratch helper file inside the repo, which was recorded as pre-existing and
  the handoff gate requires a clean original baseline. Correct fail-closed
  behavior, not a code bug. Re-baselined as v2 with the begin helper outside
  the repo (`dart --packages=<cli-package-config> /tmp/script.dart`), carrying
  the identical candidate. V5 plan/state archived under
  `.tmp/mobilekit/tasks/harness-evidence-commit/`.

- 2026-09-07: v4 verified three times at `ee8a208b…` with `handoff check` passed,
  then a post-window verify call escalated on `controller.timeout` (mechanical,
  no code failure). V4 plan retired to `completed/` as the implementation record.

## Verification

Carried from v4/v5: `OK [verify.full]` (664 app tests + CLI/lint/codegen/
oracles/contracts/duplication), `handoff check` passed read-only, focused
55-test suite green. This baseline re-verifies before dry-run.

```bash
dart run mobile_core_kit_cli:mobilekit task begin --plan docs/exec-plans/active/2026-09-07_harness-evidence-commit-v2.md
dart run mobile_core_kit_cli:mobilekit task preflight --task harness-evidence-commit-v2 --action commit
dart run mobile_core_kit_cli:mobilekit task verify --task harness-evidence-commit-v2 --env dev
dart run mobile_core_kit_cli:mobilekit handoff dry-run --task harness-evidence-commit-v2 --action commit
MOBILEKIT_HANDOFF_APPROVAL=<challenge> dart run mobile_core_kit_cli:mobilekit handoff commit --task harness-evidence-commit-v2 --message "feat(harness): evidence-bound completion, coverage CI, drift-safe verification"
```

## Runtime Evidence

Not applicable to a commit-only baseline; carried v4 device observations
(auth + startup/deep-link on Android 15 emulator) remain recorded in the
retired v4 plan.

## Rollback

`git reset --soft HEAD~1` if the commit is wrong and unpushed; then re-verify
scope. Never reset --hard shared history.

## Risks And Mitigations

- Risk: committing wrong paths or a drifted candidate.
- Mitigation: exact-path staging, staged-equality check, stop-on-drift rule.

## Completion Notes

Committed 2026-09-08 as `84d10d3` on `demo/merchant-onboarding-validation`:
`feat(harness): evidence-bound completion, coverage CI, drift-safe verification`
(27 files, +1400/−183). Verification: full lane green at attempt 1,
`handoff check` passed read-only, dry-run evidence passed, one-time approval
consumed exactly once. Worktree clean of task paths; no push/PR performed
(out of scope). Your `_WIP/` docs remain in `~/wip_backup_20260907/`.

## Follow-ups

- Hosted CI + human review remain prerequisites before any push/PR; push and
  draft-pr are explicitly out of scope for this baseline.
- Retire this plan to `completed/` (status flip + move) under fresh authority
  after the commit lands.
