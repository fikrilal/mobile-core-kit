# Mobilekit Core Workflows

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-cli-foundation.md`

## Objective

Expose the existing core Dart tool workflows through `mobilekit` while preserving current behavior.

This plan covers verification, fixing, config generation, environment validation, generated-code verification, localization hygiene, and project-map drift verification.

## Constraints

- architectural constraints:
  - preserve existing behavior before refactoring internals
  - shared process-running logic should live in the CLI package rather than being copied again
  - the CLI owns the public workflow surface; internal implementation remains package-local
- product/runtime constraints:
  - no app runtime behavior should change
  - generated config output must remain byte-for-byte compatible unless a difference is explicitly justified
  - canonical verification semantics must remain stable under `mobilekit verify`
- out of scope:
  - duplication harness conversion
  - feature scaffolding
  - CI/docs cutover
  - deleting old public script wrappers

## Acceptance Criteria

1. `mobilekit verify --env dev --skip-tests` works through pinned and installed modes.
2. `mobilekit fix --dry-run` and `mobilekit fix --apply` map to the existing safe fix workflow.
3. `mobilekit config generate --env dev` produces the expected build config behavior.
4. `mobilekit env verify` supports existing env-schema flags.
5. `mobilekit codegen verify`, `mobilekit l10n verify`, and `mobilekit project-map verify` work.
6. The pinned and installed `mobilekit` command forms covered by this plan work.
7. Tests or parity checks prove old and new command paths are equivalent for representative cases.

## Implementation Checklist

- [x] Implement `mobilekit verify`.
- [x] Implement `mobilekit fix`.
- [x] Implement `mobilekit config generate`.
- [x] Implement `mobilekit env verify`.
- [x] Implement `mobilekit codegen verify`.
- [x] Implement `mobilekit l10n verify`.
- [x] Implement `mobilekit project-map verify`.
- [x] Reuse or move shared runner logic from existing scripts without changing behavior.
- [x] Keep the pinned and installed `mobilekit` entry points working.
- [x] Add focused tests for command argument parsing and command-to-step mapping.
- [x] Add parity notes for behavior that cannot be unit-tested cheaply.

## Decision Log

- 2026-08-01: Port by delegation first where practical -> reduces risk of accidental verification behavior changes.
- 2026-08-01: The CLI becomes the supported public command surface after parity is verified.
- 2026-08-01: Keep workflow flags owned by the existing scripts -> the CLI forwards arguments unchanged and avoids duplicating repository policy.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests --skip-duplication
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests --skip-duplication
dart run mobile_core_kit_cli:mobilekit fix --dry-run
dart run mobile_core_kit_cli:mobilekit fix --dry-run
dart run mobile_core_kit_cli:mobilekit config generate --env dev
dart run mobile_core_kit_cli:mobilekit config generate --env dev
dart run mobile_core_kit_cli:mobilekit env verify --all
dart run mobile_core_kit_cli:mobilekit env verify --all
dart run mobile_core_kit_cli:mobilekit codegen verify
dart run mobile_core_kit_cli:mobilekit codegen verify
dart run mobile_core_kit_cli:mobilekit l10n verify
dart run mobile_core_kit_cli:mobilekit l10n verify
dart run mobile_core_kit_cli:mobilekit project-map verify
dart run mobile_core_kit_cli:mobilekit project-map verify
dart run test packages/mobile_core_kit_cli
```

Before marking complete, run at least one installed-mode smoke check:

```bash
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit verify --env dev --skip-tests --skip-duplication
```

Outcome: all listed pinned and legacy commands passed. The generated config
hash was identical after the new and legacy config commands:
`1a848f5f47609075320372a8954ccf9cece249375a58dc55e8cb07fa20299e20`.
Package analysis, the 14 focused tests, and installed-mode `mobilekit verify`
also passed. The installed executable required refreshing the prior
same-version Pub snapshot cache before the new command set was visible.

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static/tooling parity is sufficient. This change does not alter app runtime behavior.

## Risks And Mitigations

- Risk: `mobilekit verify` diverges from the established verification behavior.
- Mitigation: delegate first and run old/new parity commands before refactoring internals.

- Risk: config generation changes output formatting.
- Mitigation: compare generated file diffs after old and new command paths.

- Risk: fix command writes unexpected changes.
- Mitigation: verify `--dry-run`; only use `--apply` intentionally.

## Completion Notes

Added delegation routes for the core workflow surface:

- direct routes for `verify` and `fix`;
- grouped routes for `config generate`, `env verify`, `codegen verify`,
  `l10n verify`, and `project-map verify`;
- pass-through of existing tool arguments and exit codes;
- command help and repository-root errors at the CLI boundary;
- injectable command execution and focused command-to-script parity tests.

The CLI-owned workflows are now the behavior owners for the supported command
surface. No app runtime behavior changed.

## Follow-ups

- [ ] Start `docs/exec-plans/active/2026-08-01_mobilekit-scaffold-duplication.md` after core workflow parity is verified.
