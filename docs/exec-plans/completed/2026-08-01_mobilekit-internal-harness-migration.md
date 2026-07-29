# Mobilekit Internal Harness Migration

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-implementation-migration.md`

## Objective

Move the remaining executable harness implementations behind the internal
`mobilekit` CLI. Keep repository-owned policy and configuration data under
`tool/`, while removing private Dart helper entrypoints from the public
workflow path.

## Scope

- migrate:
  - `tool/verify_hardcoded_ui_colors.dart`
  - `tool/verify_modal_entrypoints.dart`
  - `tool/filter_duplication_report.dart`
- keep repo-local:
  - `lint/`
  - duplication allowlists and `.jscpd*.json`
  - `.tmp/untranslated_messages.json`
- leave unrelated asset generation (`tool/gen_android12_splash_icon.dart`)
  outside the harness CLI unless a separate command is requested.

## Constraints

- preserve guardrail behavior, output, and exit codes;
- preserve duplication categorization, allowlist matching, grouping, and
  summary output;
- execute checks directly from CLI-owned classes, without spawning the removed
  `tool/*.dart` helpers;
- keep policy/configuration visible and editable in the repository;
- do not change Flutter application runtime behavior or add unrelated commands.

## Acceptance Criteria

1. `mobilekit verify` calls the two guardrail checks directly.
2. `mobilekit duplication check` filters reports directly and no longer runs
   `dart tool/filter_duplication_report.dart`.
3. The three migrated helper files are removed from `tool/`.
4. Existing policy/configuration data remains under `tool/`.
5. Focused tests cover guardrail violations and duplication report filtering.
6. Package analysis, package tests, and the repository `mobilekit` gate pass.

## Implementation Checklist

- [x] Add CLI-owned guardrail check classes.
- [x] Move duplication report filtering into a CLI-owned service.
- [x] Wire `VerifyWorkflow` and `DuplicationRunner` to direct execution.
- [x] Add focused tests for direct execution and behavior parity.
- [x] Remove obsolete helper entrypoints and update references.
- [x] Confirm policy/configuration data remains repo-local.
- [x] Run required verification.

## Decision Log

- 2026-08-01: The CLI owns internal harness mechanics because `mobilekit`
  is repository-internal tooling; policy and configuration data remain
  repo-local for reviewability.
- 2026-08-01: Asset generation remains outside this migration because it is not
  part of the verification/duplication harness or the proposed command surface.

## Verification

All verification passed:
- `dart format packages/mobile_core_kit_cli` (28 files checked).
- `dart analyze packages/mobile_core_kit_cli`.
- `dart run test packages/mobile_core_kit_cli` (27 tests).
- `dart run mobile_core_kit_cli:mobilekit doctor`.
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation`.
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` (553 Flutter tests).
- `git diff HEAD --check`.

The direct presentation profile produced 28 raw clones and 0 actionable
groups, matching the prior repository signal.

Commands used:

```bash
dart format packages/mobile_core_kit_cli
dart analyze packages/mobile_core_kit_cli
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit doctor
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Notes: this changes repository tooling only; no app runtime behavior is in
  scope.

## Risks And Mitigations

- Risk: direct calls alter working-directory or output behavior.
- Mitigation: pass the discovered repository root and output sinks through the
  existing workflow context and preserve existing summaries.

- Risk: moving policy scanners hides repository policy in the CLI package.
- Mitigation: keep allowlists, lint configuration, and profile data in
  `tool/`; move only executable mechanics.

## Completion Notes

- Moved hardcoded-color and modal-entrypoint guardrail implementations into
  `packages/mobile_core_kit_cli/lib/src/guardrails/`.
- Moved duplication report parsing, categorization, grouping, and allowlist
  matching into `DuplicationReportFilter` under the CLI package.
- `VerifyWorkflow` now invokes guardrails directly, and `DuplicationRunner`
  invokes the filter directly after `jscpd` completes.
- Removed the three executable helper files from `tool/`. The remaining
  top-level files are repository-local data/configuration plus the unrelated
  Android 12 asset-generation utility.
- Updated current engineering documentation and added focused behavior tests.

## Follow-ups

- None.
