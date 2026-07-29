# Mobilekit Implementation Migration

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-cutover-cleanup.md`

## Objective

Move the public workflow implementations behind `mobilekit` so the CLI owns
their parsing, orchestration, process execution, output, and exit codes. Remove
the old public Dart entrypoints after behavior parity is proven.

## Constraints

- architectural constraints:
  - keep repository policy and configuration data repo-local: `.jscpd*.json`,
    `duplication/*.json`, `lint/`, and `.tmp/untranslated_messages.json`
  - keep implementation-detail helpers private to the repository unless they
    are part of a public workflow
  - reuse the existing CLI `CommandRunner` for pinned Dart/Flutter execution
  - keep the CLI package independent from the Flutter application package
- product/runtime constraints:
  - preserve existing command behavior, verification order, output meaning,
    and exit codes
  - no Flutter application runtime behavior should change
  - CI and local installed usage must continue to use the same public commands
- out of scope:
  - moving policy/config/allowlist data into the CLI package
  - adding new public commands or verification semantics
  - removing unrelated agent helpers or asset-generation utilities

## Acceptance Criteria

1. `mobilekit` no longer delegates public workflows to the old Dart entrypoint
   files.
2. `verify`, `fix`, `config generate`, `env verify`, `codegen verify`,
   `l10n verify`, `project-map verify`, and `scaffold feature` run from CLI-owned
   implementations with behavior parity.
3. Existing CLI duplication orchestration remains available and continues to
   use repo-local configs, allowlists, and the internal report filter.
4. Obsolete public Dart entrypoints are deleted from `tool/`.
5. Tests cover command parsing, workflow sequencing, and important file/report
   behavior without requiring a Flutter device.
6. The pinned and installed `mobilekit` verification paths pass.

## Implementation Checklist

- [x] Add shared CLI workflow context and migrate the common process/step logic.
- [x] Migrate environment validation and build-config generation.
- [x] Migrate codegen freshness, localization, and project-map checks.
- [x] Migrate safe fix and canonical verification workflows.
- [x] Migrate feature scaffolding.
- [x] Update CLI tests for direct workflow ownership and parity behavior.
- [x] Delete obsolete public `tool/*.dart` entrypoints and update references.
- [x] Confirm policy/config/internal helpers remain intentionally repo-local.
- [x] Run pinned, installed, package, and repository verification.

## Decision Log

- 2026-08-01: Public workflow implementations move into CLI-owned modules ->
  delegation to old Dart entrypoints did not satisfy the proposal's Phase 2
  ownership boundary.
- 2026-08-01: Policy/config and explicitly internal helpers remain under
  `tool/` -> they are repository-owned data or private implementation details,
  not public workflow entrypoints.
- 2026-08-01: Reuse the existing CLI process runner and pass repository roots
  explicitly -> remove duplicated FVM/platform resolution without changing
  command execution semantics.
- 2026-08-01: Keep the CLI's public surface package-owned while retaining
  repository-local policy/data -> allowlists, lint policy, untranslated-message
  data, and private guardrails remain editable with the repository.

## Verification

All listed commands passed. The package test suite passed with 23 tests, and
the full pinned verification passed with 553 Flutter tests. Installed-mode
verification also passed after refreshing a stale same-version global CLI
snapshot; the recovery command is documented in
`docs/engineering/guardrails.md`.

```bash
dart format packages/mobile_core_kit_cli
dart analyze packages/mobile_core_kit_cli
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit doctor
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit verify --env dev --check-codegen --skip-tests --skip-format
dart run mobile_core_kit_cli:mobilekit fix --dry-run
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit doctor
mobilekit verify --env dev --skip-tests
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Required repository checks:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: tooling behavior is covered by command and repository verification;
  no app runtime behavior changes are in scope.

## Risks And Mitigations

- Risk: direct workflow migration changes verification order or exit behavior.
- Mitigation: preserve the existing step sequence and add command-executor
  tests for each workflow.

- Risk: moving config/scaffolding logic introduces path or formatting drift.
- Mitigation: pass the discovered repository root explicitly and compare
  generated/scaffold output against the existing implementation before removal.

- Risk: deleting old entrypoints removes an undocumented local escape hatch.
- Mitigation: retain `mobilekit` help, pinned invocation, and installed usage as
  the supported replacement; keep internal policy/data helpers available.

## Completion Notes

- Moved the eight public workflow implementations into
  `packages/mobile_core_kit_cli/lib/src/workflows/`: verification, fix,
  config generation, environment validation, codegen, localization,
  project-map validation, and feature scaffolding.
- Added `WorkflowContext` so workflows receive an explicit repository root,
  shared command executor, and output sinks.
- Removed the old public Dart entrypoints from `tool/`. The remaining top-level
  files are repository-local policy/configuration data, private guardrail/report
  helpers, or the unrelated asset-generation utility.
- Updated CLI and workflow tests to exercise direct ownership, command
  sequencing, generated config behavior, and temp-repository scaffolding.
- Updated current-state documentation and documented recovery for stale global
  CLI snapshots.

## Follow-ups

- None.
