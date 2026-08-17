# Execution Plans

This directory is the system of record for non-trivial implementation plans.

Use execution plans when work spans multiple steps, risks, or decisions that can drift across sessions.

## Lifecycle

1. Create a V2 plan from `docs/exec-plans/_template.md` in `queued/` when it
   awaits authority, or `active/` when work is authorized.
2. For non-trivial agent work, establish the immutable task baseline before
   editing: `mobilekit task begin --plan <active-plan-path>`.
3. Use `mobilekit task preflight --task <id> --action <action>` before a
   controlled action. Preflight reports; it does not perform the action.
4. Update narrative progress and verification evidence without changing the
   authority-bearing metadata. Authority changes require a new task baseline.
5. Set `Status` to `completed`, check every checklist item, and move the plan
   to `completed/` only after the acceptance evidence exists.
6. Add unresolved follow-ups to `docs/exec-plans/tech_debt_tracker.md`.

`active/`, `queued/`, and `completed/` are mechanically checked. Only one V2
plan may be active. Completed historical plans remain readable; plans created
from 2026-08-11 onward must use V2.

## File Naming

Use: `YYYY-MM-DD_short-topic.md`

Examples:
- `2026-02-23_agent-pr-loop.md`
- `2026-03-01_profile-upload-retry.md`

## What Belongs In A Plan

- task objective and constraints
- acceptance criteria
- risk class and impact area
- implementation checklist
- decision log
- verification evidence
- follow-up debt (if any)

The metadata block is executable authority, not descriptive prose. Paths must
be narrow, repository-relative, and include the plan itself. Actions are
explicit; permission to edit does not imply permission to commit, push, or
open a draft PR. Automated classification can raise the effective risk but
cannot lower the risk declared by the human-approved plan.

## What Does Not Belong Here

- tiny one-file edits with no risk/coordination overhead
- speculative ideas without an active task (put those in WIP docs first)

See `docs/engineering/task_authority.md` for the complete operating contract.
