# Harness Phase 4 — Isolated Current-Agent Workspaces

**Plan version:** 2
**Task ID:** mobile-harness-phase-4-isolated-workspaces
**Status:** active
**Owner:** Codex
**Risk:** high
**Authority:** implement, verify, and commit Phase 4 locally; no agent launch or external mutation
**Allowed paths:** packages/mobile_core_kit_cli/lib/src/task/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/test/, AGENTS.md, docs/README.md, docs/engineering/, docs/exec-plans/
**Allowed actions:** edit, verify, commit
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h

Date: 2026-08-11
Related issue/PR: Approved `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`

## Objective

Let the current conversational agent prepare and rediscover a deterministic
task branch and linked Git worktree without copying or mutating dirty primary
worktree files, then cancel or clean it safely under explicit lifecycle rules.

## Constraints

- Architecture constraints: keep worktree control in `mobilekit`; use native
  Git; keep application Clean Architecture untouched; do not launch agents.
- Product/runtime constraints: controller state must be shared and discoverable
  from primary and linked worktrees; repository mutations require one lock;
  cleanup must fail closed on dirty, missing, or ambiguous ownership.
- Out of scope: device pools, parallel overlapping paths, host-agent process
  control, event intake, push/PR publication, and automatic merge.

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

1. Given an authorized task and dirty user files in the primary checkout, when
   workspace prepare runs, then a deterministic task branch/worktree starts
   from the recorded base revision and contains none of those dirty changes.
2. Given the agent changes directory into the linked worktree, when task status
   or verification runs, then it resolves the same shared task state and
   validates the expected workspace, branch, base, and authority.
3. Given concurrent prepare/cleanup requests, when the repository mutation lock
   is held, then the second command fails without waiting indefinitely.
4. Given a dirty or mismatched task worktree, when cleanup runs, then it refuses
   removal and preserves the branch/worktree for inspection.
5. Given a clean owned task worktree, when cancellation then cleanup runs, then
   lifecycle is recorded, the worktree is removed, and the branch remains
   available unless a separately authorized later policy removes it.

## Acceptance Criteria

1. State schema records canonical primary root, task branch, workspace path,
   workspace base, and workspace lifecycle with migration from Phase 3.
2. Prepare validates task preflight, branch/path ownership, primary checkout,
   clean target absence, and recorded base before native `git worktree add`.
3. Task commands locate shared state from either primary or linked worktree and
   controlled verification rejects the wrong workspace after preparation.
4. A bounded atomic lock protects every worktree mutation.
5. Cancel records state only and never kills the host coding agent.
6. Cleanup refuses dirty/ambiguous worktrees, removes only the exact owned path,
   prunes safely, and preserves the task branch.
7. Runtime/device policy remains single-flight and documented; no device pool
   or nested-agent orchestration is introduced.
8. Phase 3 controller fixtures and canonical verification remain green.

## Implementation Checklist

- [ ] Add shared controller-root and worktree discovery.
- [ ] Extend state with validated workspace ownership and lifecycle.
- [ ] Implement repository mutation lock and deterministic prepare.
- [ ] Make preflight/verify workspace-aware after preparation.
- [ ] Implement status rediscovery and state-only cancellation.
- [ ] Implement fail-closed clean-worktree cleanup with branch preservation.
- [ ] Add native Git integration/negative tests and operating docs.
- [ ] Exercise prepare/status/cancel/cleanup in an isolated fixture and verify.

## Decision Log

- 2026-08-11: Keep linked worktrees beneath primary ignored `.tmp/mobilekit/`
  -> ownership is deterministic and no global service or user directory is
  required.
- 2026-08-11: Preserve the task branch during cleanup -> removal stays
  recoverable and branch deletion remains a separate destructive decision.
- 2026-08-11: Share state through the primary worktree root -> commands remain
  rediscoverable after the agent changes into the linked checkout.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test
dart analyze packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit knowledge verify
dart run mobile_core_kit_cli:mobilekit task verify --task mobile-harness-phase-4-isolated-workspaces --env dev
```

## Runtime Evidence

No app/device behavior changes. Runtime evidence is a native temporary Git
fixture proving dirty-primary isolation, branch/base/path validation, shared
state rediscovery, lock contention, dirty cleanup refusal, cancellation, clean
cleanup, and branch preservation. Device evidence remains single-flight.

## Rollback

Remove workspace manager/root locator/lock additions and restore Phase 3 state
and task routing. Preserve any existing task branches/worktrees for manual
inspection; do not delete them as part of rollback.

## Risks And Mitigations

- Risk: cleanup removes the wrong checkout or user work.
- Mitigation: exact canonical path, branch, shared Git directory, clean status,
  state ownership, and lock checks must all pass before native removal.
- Risk: state diverges between primary and task checkout.
- Mitigation: discover one canonical primary root and keep one atomic state
  owner outside linked worktree contents.
- Risk: nested worktree paths or stale registrations become ambiguous.
- Mitigation: native porcelain discovery, deterministic paths, absence checks,
  fail-closed stale-state handling, and explicit safe prune only after removal.

## Completion Notes

Pending.

## Follow-ups

- [ ] Create Phase 5 only after Phase 4 evidence passes.
