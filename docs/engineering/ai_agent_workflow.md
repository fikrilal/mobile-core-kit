# AI Agent Workflow (Recommended)

This template is intentionally strict so AI-assisted development stays scalable over time.

If you’re using an AI coding agent (or reviewing AI-authored code), follow this workflow to keep PRs “boring”:

PR delivery loop details: `docs/engineering/agent_pr_loop.md`

## 1) Orient first (avoid architecture drift)

- Read `AGENTS.md` (repo map + verification commands + guardrail expectations).
- If the change touches API/network/auth/users, open the backend contract:
  - `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
- Pick the correct layer before you write code:
  - Feature changes go under `lib/features/<feature>/...`
  - Cross-cutting infra belongs in `lib/core/**`
  - Navigation wiring belongs in `lib/navigation/**`

## 2) Use the guardrails as your default

- Run safe auto-fixes before review:
  - `dart run tool/fix.dart --apply`
- Run the canonical gate before you claim “done”:
  - `dart run tool/verify.dart --env dev`

Guardrails index: `docs/engineering/guardrails.md`

## 3) Follow architecture + UI state patterns

- Follow Clean Architecture boundaries (`docs/engineering/project_architecture.md`).
- UI state rules live here (`docs/engineering/ui_state_architecture.md`).
- Validation rules live here:
  - `docs/engineering/validation_architecture.md`
  - `docs/engineering/value_objects_validation.md`

## 4) Prefer scaffolding to reduce drift

When creating a new feature/slice, use:

- `dart run tool/scaffold_feature.dart --feature <snake_case> [--slice <snake_case>]`

This generates the standard structure + test skeletons and avoids common lint failures.

## 5) Don’t “fight” the lints (fix the root cause)

- If you hit a guardrail violation repeatedly, prefer improving the allowlists/configs instead of adding suppressions.
- If a suppression is truly needed, scope it tightly and leave a reason.
