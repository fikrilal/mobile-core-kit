# Harness Evidence Integrity — Push + Draft PR

**Plan version:** 2
**Task ID:** harness-evidence-push
**Status:** completed
**Owner:** Muse Spark
**Risk:** high
**Authority:** User explicitly chose push + draft PR on 2026-09-08 and authorized this baseline, including the mechanical retirement of the already-committed v2 plan file (`active/2026-09-07_harness-evidence-commit-v2.md` -> `completed/`) required for single-active-plan knowledge. Scope: push the already-committed `84d10d3` (`feat(harness): evidence-bound completion, coverage CI, drift-safe verification`) from local `demo/merchant-onboarding-validation` to origin, then open a DRAFT PR against `main`; no code edits, no merge, no ready-for-review, no deploy. Retired unexecuted on 2026-09-27: do not push `84d10d3` and do not open that draft PR.
**Allowed paths:** docs/exec-plans/queued/2026-09-08_harness-evidence-push.md, docs/exec-plans/active/2026-09-08_harness-evidence-push.md, docs/exec-plans/completed/2026-09-08_harness-evidence-push.md, docs/exec-plans/active/2026-09-07_harness-evidence-commit-v2.md, docs/exec-plans/completed/2026-09-07_harness-evidence-commit-v2.md
**Allowed actions:** verify, push, draft-pr
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 2h
**Oracle IDs:** harness.full

Date: 2026-09-08
Related issue/PR: N/A

## Objective

Retired on 2026-09-27 without a push or a pull request. The original
objective was to push local commit `84d10d3` to
`origin/demo/merchant-onboarding-validation` (exact ref, no force) and
open a draft PR against `main`. That commit is no longer the branch
head, so `event intake` must not select this plan.

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
- 2026-09-27: do not resume this baseline. A new publication plan is required
  for any later push or draft PR.

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

1. Given this file is under `completed/` with status `completed`, when
   `event intake --once` sorts the queue, then it does not select
   `harness-evidence-push`.
2. Given the original push was not run, when a reader opens this plan,
   then the record says `84d10d3` was not pushed and no draft PR was opened.

## Acceptance Criteria

1. The plan is not in `docs/exec-plans/queued/`.
2. Status is `completed` and every checklist item is checked.
3. The note states that the pinned commit was not published.

## Implementation Checklist

- [x] Confirm the plan was still queued and the push was never run.
- [x] Record that `84d10d3` is not the branch head to publish.
- [x] Move the plan to `completed/` so event intake cannot select it.
- [x] Do not push and do not open a draft PR under this baseline.

## Decision Log

- 2026-09-08: Commit `84d10d3` verified (full lane green, `handoff check`
  passed, 27 exact paths). User chose push + draft PR. New minimal baseline
  with only plan paths in scope; zero task-owned content expected, so push
  requires the clean-checkout shape (`_assertClean`).
- 2026-09-08: Parked to queued so `maestro-journey-plumbing` can be the
  single active V2. Push + draft PR not completed. Resume this plan later.
- 2026-09-27: User retired the queued plan. Branch head had moved to
  `373e073`. Executing intake would have pushed the stale `84d10d3`.

## Verification

```bash
test ! -f docs/exec-plans/queued/2026-09-08_harness-evidence-push.md
test -f docs/exec-plans/completed/2026-09-08_harness-evidence-push.md
dart run mobile_core_kit_cli:mobilekit knowledge verify
```

## Runtime Evidence

No device run. This retirement publishes nothing. The 2026-09-08 local
verification of `84d10d3` is historical and is not evidence for the
current branch head.

## Rollback

Move the file back to `docs/exec-plans/queued/` and set `Status` to
`queued` only if a human again wants `event intake` to push `84d10d3`.
That commit is not the current branch head.

## Risks And Mitigations

- Risk: a later reader treats this completed plan as proof that `84d10d3` was pushed.
- Mitigation: objective, checklist, and decision log say the push and draft PR did not happen.

## Completion Notes

Retired unexecuted on 2026-09-27. `84d10d3` was not pushed. No draft PR
was opened. The plan left the queue so `event intake --once` cannot
select it.

## Follow-ups

- Any push or draft PR needs a new V2 plan aimed at the commit that should actually be published.
- Do not resume this baseline.
