# Parallel Agent Workflow

This guide defines the safest way to run multiple AI agents in parallel on the
same repository.

Goal:
- avoid cross-agent staging mistakes
- avoid mixed commits
- keep verification noise isolated per task

## Recommendation Order

Use these options in this order:

1. `git worktree` + one branch per agent
2. one branch per agent in separate clones
3. same branch in one working tree only as a last resort

The first option is the default recommendation for this repo.

## Preferred Setup: `git worktree`

Use one worktree per task or agent so each agent gets:
- its own directory
- its own branch
- its own uncommitted working tree

Example:

```bash
git fetch origin

git worktree add ../mobile-core-kit-auth-copy -b agent/auth-copy
git worktree add ../mobile-core-kit-account-copy -b agent/account-copy
```

Then point each agent at a different directory:

- `../mobile-core-kit-auth-copy`
- `../mobile-core-kit-account-copy`

Benefits:
- no accidental `git add .` across another agent's files
- safer formatting, codegen, and verification
- easier review because each branch stays task-scoped

## Same Branch In One Working Tree: Risks

Running several agents against the same checked-out branch is possible, but it
is the highest-risk setup.

Main failure modes:
- one agent stages another agent's changes
- repo-wide formatting or codegen rewrites unrelated files
- two agents edit the same file and produce tangled diffs
- verification output becomes noisy because unrelated changes are mixed

Telling agents to avoid destructive git actions is necessary, but it is not
enough.

## Minimum Rules If You Still Share One Working Tree

If multiple agents must share one working tree, require all of the following:

- assign each agent explicit file or path ownership
- do not use `git add .`
- stage only explicit paths
- commit only explicit paths
- do not run repo-wide formatting unless requested
- do not run broad codegen unless the task requires it
- do not revert unrelated dirty files
- stop and report if another agent is editing the same file

Recommended pre-commit check:

```bash
git status --short
git diff --stat
```

## Branching Model

A practical coordination model is:

1. keep one local integration branch for review
2. create one branch per agent task
3. merge or cherry-pick reviewed agent branches into the integration branch

Example:

```bash
git switch development
git worktree add ../mobile-core-kit-auth-copy -b agent/auth-copy
git worktree add ../mobile-core-kit-account-copy -b agent/account-copy
```

After review:

```bash
git switch development
git merge --no-ff agent/auth-copy
git merge --no-ff agent/account-copy
```

Or use `git cherry-pick <sha>` when you want tighter commit selection.

## Verification Guidance

Each agent should verify only in its own worktree. This keeps failures
attributable to the task being worked on.

Recommended flow per agent:

```bash
git status --short
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Use lighter targeted checks only when the task is small enough to justify it.

## Decision Rule

Use `git worktree` when:
- more than one agent is active
- tasks may touch nearby feature boundaries
- verification, codegen, or formatting is likely

If you expect overlapping edits in the same file, do not share the same working
tree.
