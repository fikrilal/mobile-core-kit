# Current-Agent Workspaces

`mobilekit` can isolate an authorized task in a linked Git worktree. It does
not start Codex, Claude Code, or another process. The current conversational
agent prepares the workspace, changes its working directory, and continues the
same session there.

## Prepare

Run from the primary worktree after `task begin`:

```bash
dart run mobile_core_kit_cli:mobilekit task workspace prepare \
  --task <task-id>
```

Prepare runs task preflight, takes the repository mutation lock, and creates:

- branch: `agent/<task-id>`;
- path: `<primary>/.tmp/mobilekit/worktrees/<task-id>`;
- starting revision: the immutable task base revision.

Dirty primary-worktree files are not copied. Existing target paths or branches
are rejected rather than reused. After prepare, controlled preflight,
verification, and repair must run from the exact owned workspace. Run status
from either checkout:

```bash
mobilekit task workspace status --task <task-id>
mobilekit task status --task <task-id>
```

Task commands discover the canonical primary worktree through native Git and
read the same atomic state under its ignored `.tmp/mobilekit/tasks/` directory.
The stored control root, workspace path, branch, base revision, and lifecycle
are validated before controlled transitions.

## Cancel And Cleanup

Cancellation records intent only:

```bash
mobilekit task workspace cancel --task <task-id>
```

It never kills the host coding agent or deletes files. After cancellation,
controlled edit/verify actions are disabled. Inspect and make the worktree
clean, then run cleanup from the primary checkout:

```bash
mobilekit task workspace cleanup --task <task-id>
```

Cleanup requires the exact registered path and branch, cancelled lifecycle, a
clean Git status, and the repository mutation lock. Dirty, missing, duplicate,
or mismatched ownership fails closed and preserves the worktree. Successful
cleanup removes only the linked worktree. The `agent/<task-id>` branch remains
for recovery and inspection; branch deletion is not part of this workflow.

The lock is acquired atomically and fails immediately on contention. It is not
silently broken as “stale”; inspect the owner before manually resolving an
abandoned lock.

## Concurrency

Each concurrent agent needs a separate task, branch, and worktree. Authorized
paths must be disjoint, following `docs/engineering/parallel_agent_workflow.md`.
Device/runtime evidence remains single-flight per device. Phase 4 does not add
emulator pools, per-worktree application IDs, or nested-agent orchestration.
