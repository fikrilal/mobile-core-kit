# Mobilekit CLI Command Reference And Tool Reference Migration

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: low
Related issue/PR: N/A

## Objective

Create one repository-owned command reference for the internal `mobilekit` CLI
and replace stale public documentation references to the retired script command
surface with the corresponding CLI commands.

## Constraints

- document the commands implemented by the current CLI, not speculative future
  commands;
- keep `packages/mobile_core_kit_cli/` as the implementation source of truth;
- preserve internal implementation references only when no public CLI command
  replaces them;
- update the docs index and repository guidance so future agents find the
  command reference quickly;
- do not change CLI behavior as part of this documentation migration.

## Acceptance Criteria

1. A concise command reference documents usage, installation/pinned execution,
   command groups, important options, and exit-code expectations.
2. The command reference is linked from the documentation index and relevant
   agent/developer guidance.
3. No active or user-facing documentation instructs users to run retired script
   commands when a `mobilekit` equivalent exists.
4. Historical records are updated where their references describe current
   repository usage; source-of-truth implementation paths remain accurate.
5. Documentation/reference checks and the full repository verification pass.

## Implementation Checklist

- [x] Inventory the CLI command tree and all stale tool references.
- [x] Add the command-reference document and index entry.
- [x] Update AGENTS, README, engineering docs, CI/PR guidance, proposals, and
  execution-plan references as appropriate.
- [x] Verify the command list against CLI help and run repository checks.
- [x] Archive this plan with completion evidence.

## Decision Log

- 2026-08-01: Keep one command reference under `docs/engineering/` -> command
  behavior is cross-cutting and should not be duplicated across the CLI package
  and multiple workflow guides.
- 2026-08-01: Migrate public workflow instructions but retain implementation
  paths where they explain internals or historical source provenance -> the CLI
  is the stable user surface, while source paths remain useful for maintainers.

## Verification

Planned commands:

```bash
dart run mobile_core_kit_cli:mobilekit --help
dart run mobile_core_kit_cli:mobilekit doctor --help
dart run mobile_core_kit_cli:mobilekit verify --help
dart run mobile_core_kit_cli:mobilekit duplication --help
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

## Risks And Mitigations

- Risk: the reference drifts from the actual parser and routing.
  Mitigation: derive the command table from CLI source/help and test key help
  paths.
- Risk: a broad search-and-replace changes source provenance or intentional
  internal references.
  Mitigation: classify matches before editing and preserve implementation-only
  references.

## Completion Notes

- Added `docs/engineering/mobilekit_cli_reference.md` with pinned execution,
  local activation, command groups, options, runtime workflows, and exit-code
  semantics.
- Linked the reference from `README.md`, `docs/README.md`, `AGENTS.md`, and the
  relevant engineering workflow documents.
- Updated current guidance, templates, ADRs, proposals, and execution-plan
  records to use `dart run mobile_core_kit_cli:mobilekit` for supported
  workflows.
- Completed filename and command audits with no remaining invocations of the
  retired script entry points or standalone analyzer/custom-lint workflows.
- `dart run mobile_core_kit_cli:mobilekit --help` passed.
- `dart run mobile_core_kit_cli:mobilekit doctor --help` passed.
- `dart run mobile_core_kit_cli:mobilekit verify --help` passed.
- `dart run mobile_core_kit_cli:mobilekit duplication --help` passed.
- `dart test` in `packages/mobile_core_kit_cli` passed (41 tests).
- `dart analyze packages/mobile_core_kit_cli packages/mobile_core_kit_lints`
  passed.
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` passed, including
  analyzer, custom lint, duplication, guardrails, Flutter tests, and formatting.
- `git diff --check` passed.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
