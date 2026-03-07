# Execution Plans

This directory is the system of record for non-trivial implementation plans.

Use execution plans when work spans multiple steps, risks, or decisions that can drift across sessions.

## Lifecycle

1. Create a plan file in `docs/exec-plans/active/` from `docs/exec-plans/_template.md`.
2. Update the same file as work progresses (status, decisions, verification evidence).
3. Move the file to `docs/exec-plans/completed/` when done.
4. Add unresolved follow-ups to `docs/exec-plans/tech_debt_tracker.md`.

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

## What Does Not Belong Here

- tiny one-file edits with no risk/coordination overhead
- speculative ideas without an active task (put those in WIP docs first)
