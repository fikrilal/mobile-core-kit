# Harness Evidence Integrity — Push + Draft PR

**Plan version:** 2
**Task ID:** harness-evidence-push
**Status:** queued
**Owner:** Muse Spark
**Risk:** high
**Authority:** User explicitly chose push + draft PR on 2026-09-08 and authorized this baseline, including the mechanical retirement of the already-committed v2 plan file (`active/2026-09-07_harness-evidence-commit-v2.md` -> `completed/`) required for single-active-plan knowledge. Scope: push the already-committed `84d10d3` (`feat(harness): evidence-bound completion, coverage CI, drift-safe verification`) from local `demo/merchant-onboarding-validation` to origin, then open a DRAFT PR against `main`; no code edits, no merge, no ready-for-review, no deploy.
**Allowed paths:** docs/exec-plans/queued/2026-09-08_harness-evidence-push.md, docs/exec-plans/active/2026-09-08_harness-evidence-push.md, docs/exec-plans/completed/2026-09-08_harness-evidence-push.md, docs/exec-plans/active/2026-09-07_harness-evidence-commit-v2.md, docs/exec-plans/completed/2026-09-07_harness-evidence-commit-v2.md
**Allowed actions:** verify, push, draft-pr
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 2h
**Oracle IDs:** harness.full

Date: 2026-09-08
Related issue/PR: N/A

## Objective

Push local commit `84d10d3` to `origin/demo/merchant-onboarding-validation`
(exact ref, no force) and open a draft PR against `main` with the repo PR
template filled (risk, checks, evidence, reviewer focus). Hosted CI then runs
independently; merge stays a separate human decision.

## Constraints

- No code edits under this baseline. If preflight/verify shows any task-owned
  content drift, stop and report.
- Push exactly `refs/heads/demo/merchant-onboarding-validation` to the same
  ref on origin (adapter-enforced, no force).
- Draft PR only (`gh pr create --draft --no-maintainer-edit`), base `main`,
  title `feat(harness): evidence-bound completion, coverage CI, drift-safe verification`.
- `_WIP/` docs stay untracked working notes; they are not part of any push
  payload (push moves commits, not worktree files) and must not be staged or
  committed here.
- Never mark ready, merge, or deploy.

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

1. Given local `84d10d3` ahead of origin with a clean checkout, when push runs
   with a fresh approval, then origin holds the same commit on the same branch.
2. Given the pushed branch, when draft-pr runs with a fresh approval, then a
   draft PR URL is returned and the body discloses verification + evidence
   state honestly (including outstanding hosted CI at creation time).

## Acceptance Criteria

1. `task verify` passes (no owned content changes expected) and `handoff check`
   passes read-only.
2. `handoff dry-run --action push` succeeds with a fresh challenge; push
   consumes it and reports the pushed revision.
3. `handoff dry-run --action draft-pr` succeeds with a fresh challenge; draft-pr
   consumes it and returns a valid PR URL.
4. `git status` shows push/PR added no local file changes; episode trail shows
   completed push + draft-pr.

## Implementation Checklist

- [ ] Begin push baseline; confirm clean pre-existing set and ahead-of-origin state.
- [ ] Verify + handoff check pass.
- [ ] Dry-run push, execute with fresh approval.
- [ ] Dry-run draft-pr, execute with fresh approval.
- [ ] Record PR URL + hosted CI expectations, retire plan.

## Decision Log

- 2026-09-08: Commit `84d10d3` verified (full lane green, `handoff check`
  passed, 27 exact paths). User chose push + draft PR. New minimal baseline
  with only plan paths in scope; zero task-owned content expected, so push
  requires the clean-checkout shape (`_assertClean`).
- 2026-09-08: Parked to queued so `maestro-journey-plumbing` can be the
  single active V2. Push + draft PR not completed. Resume this plan later.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task verify --task harness-evidence-push --env dev
dart run mobile_core_kit_cli:mobilekit handoff check --task harness-evidence-push
dart run mobile_core_kit_cli:mobilekit handoff dry-run --task harness-evidence-push --action push
MOBILEKIT_HANDOFF_APPROVAL=<push-challenge> dart run mobile_core_kit_cli:mobilekit handoff push --task harness-evidence-push
dart run mobile_core_kit_cli:mobilekit handoff dry-run --task harness-evidence-push --action draft-pr
MOBILEKIT_HANDOFF_APPROVAL=<pr-challenge> dart run mobile_core_kit_cli:mobilekit handoff draft-pr --task harness-evidence-push --base main --title "feat(harness): evidence-bound completion, coverage CI, drift-safe verification"
```

## Runtime Evidence

Carried: full lane green, `handoff check` passed read-only, auth + startup
integration commands passed on Android 15 emulator (local observations, plan
records). Hosted CI is the point of this push; record its outcome separately.

## Rollback

Push/PR cannot be "uncommitted" remotely by the harness. If wrong: do not force
push; open a follow-up revert PR through normal human review. Locally nothing
changes (push moves no worktree files).

## Risks And Mitigations

- Risk: pushing to the wrong branch or opening a ready PR.
- Mitigation: adapter pins exact ref + draft-only creation; dry-run prints
  branch/remote first; stop on any mismatch.

## Completion Notes

Parked to queued 2026-09-08. Not completed. Resume after Maestro plumbing.

## Follow-ups

- Human review + hosted `CI Required` before any merge; merge is out of scope.
- Retire this plan to `completed/` after PR opens.
