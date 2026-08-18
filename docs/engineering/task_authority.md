# Structured Task Authority

The execution plan is the human-to-agent authority boundary. `mobilekit` does
not replace Codex, Claude Code, or another coding agent; those agents invoke
the repository-local controls while working in the normal chat workflow.

## Contract

A non-trivial task starts from one active V2 plan. Its metadata declares:

- the stable task identity, owner, status, and human-readable authority;
- allowed repository paths and separately allowed actions;
- declared and maximum risk, repair budget, and wall-clock timeout;
- mobile-specific impact areas and observable acceptance scenarios;
- registered behavioral oracle IDs for medium/high-risk impacts.

Allowed paths are normalized and reject absolute paths, traversal, globs,
repository-root grants, `.git`, duplicates, and symlink escapes. The active
plan must include itself in scope. `edit`, `verify`, `commit`, `push`, and
`draft-pr` are distinct actions; no action implies another.

Oracle IDs resolve from `harness/oracles.yaml`, participate in the immutable
authority hash, and persist in versioned task state. Missing, unknown, or
impact-incompatible selections fail at `task begin` and preflight. Older
completed V2 plans remain readable, but new medium/high-risk tasks cannot omit
the field. See `docs/engineering/behavioral_oracles.md`.

## Local baseline

Before implementation:

```bash
dart run mobile_core_kit_cli:mobilekit task begin \
  --plan docs/exec-plans/active/<plan>.md
```

The command validates the plan, records the current Git revision, hashes the
authority metadata, and fingerprints every dirty path. State is written
atomically under ignored `.tmp/mobilekit/tasks/<task-id>/state.json`.
Pre-existing dirty files remain user-owned while their content fingerprint is
unchanged. If they change after begin, they become task-owned and must be in
the allowed path set.

Inspect state or classify current work with:

```bash
dart run mobile_core_kit_cli:mobilekit task status --task <task-id>
dart run mobile_core_kit_cli:mobilekit risk classify --plan <plan-path>
```

Risk classification is conservative and mobile-aware. Authentication,
navigation/startup, data contracts, dependencies, platform configuration,
harness, CI, and release paths raise risk to high. Unknown executable paths
are at least medium. Impact declarations can raise risk and never lower it.

## Preflight

Before a controlled action:

```bash
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task <task-id> --action verify
```

Preflight fails closed when the authority changed, the action was not granted,
task-owned files exceed scope, effective risk exceeds the ceiling, or local
state cannot be trusted. On success it prints the task-owned paths, protected
pre-existing paths, effective risk, and a stable task fingerprint. Preflight
remains report-only. `mobilekit task verify` is the separate controlled action
that invokes the canonical risk-selected profile; see
`docs/engineering/controlled_verification_loop.md`.

Do not edit authority metadata in place after `task begin`. If scope or action
authority must change, make the human decision explicit and establish a new
baseline. Never delete or rewrite unrelated dirty work to make preflight pass.

When a task workspace is prepared, its canonical path becomes part of the
authority evidence. Controlled actions from the primary or another worktree
fail; state/status remains shared and rediscoverable. See
`docs/engineering/current_agent_workspaces.md`.
