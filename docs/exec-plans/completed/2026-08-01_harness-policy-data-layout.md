# Harness Policy Data Layout

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: low
Related issue/PR: N/A

## Objective

Separate repository-owned duplication policy from executable harness code and
keep generated localization output out of the source tree. Move the reviewed
duplication allowlists to a root-level `duplication/` directory and configure
Flutter plus `mobilekit l10n verify` to use ignored `.tmp/untranslated_messages.json`.

## Constraints

- keep duplication allowlists tracked because they record reviewed exceptions;
- keep the untranslated-message report ignored because Flutter regenerates it;
- preserve all duplication profile behavior and localization verification
  behavior;
- keep orchestration in `packages/mobile_core_kit_cli/`, not repository policy
  data;
- update all active source and user-facing documentation references;
- out of scope: changing duplication rules, allowlist semantics, or the
  localization source ARB files.

## Acceptance Criteria

1. The three duplication allowlists live under `duplication/` and remain
   version-controlled.
2. `l10n.yaml` and `mobilekit l10n verify` use `.tmp/untranslated_messages.json`,
   and the generated report is ignored.
3. Duplication profiles and localization verification resolve the new paths.
4. No active source or user-facing documentation points to the old `tool/`
   data paths.
5. Targeted tests and the full repository verification pass.

## Implementation Checklist

- [x] Create this execution plan and record ownership decisions.
- [x] Move the three tracked duplication allowlists to `duplication/`.
- [x] Move the generated localization report to `.tmp/` and update ignore/config
  paths.
- [x] Update CLI code, tests, docs, proposal, and active references.
- [x] Run targeted checks and the full verification gate.

## Decision Log

- 2026-08-01: Put duplication allowlists in root `duplication/` -> they are
  reviewed repository policy, not CLI implementation or transient tool output.
- 2026-08-01: Put untranslated-message output under `.tmp/` -> it is generated
  by Flutter and should not be committed or treated as policy.

## Verification

Planned commands:

```bash
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit l10n verify
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

## Risks And Mitigations

- Risk: a stale hardcoded path makes a harness profile fail after the move.
  Mitigation: search all references and run each affected profile directly.
- Risk: generated localization output becomes accidentally tracked.
  Mitigation: place it under the existing ignored `.tmp/` directory and verify
  with `git check-ignore`.

## Completion Notes

Implemented the repository data split:

- moved the reviewed duplication allowlists to `duplication/` and kept them
  tracked;
- moved the generated untranslated-message report to
  `.tmp/untranslated_messages.json`, which remains ignored by the existing
  `.tmp/` rule;
- updated the CLI runner, localization configuration, tests, documentation,
  proposal, and execution-plan references;
- updated the temporary CLI repository fixture to use a Git marker instead of
  creating a `tool/` directory solely for repository discovery.

Verification completed on 2026-08-01:

- `dart format packages/mobile_core_kit_cli`
- `dart analyze packages/mobile_core_kit_cli`
- `dart run test packages/mobile_core_kit_cli` — 41 tests passed
- `dart run mobile_core_kit_cli:mobilekit l10n verify`
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile core`
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers`
- `dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation`
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` — 553 tests passed
- `git diff --check`
- `git check-ignore -v .tmp/untranslated_messages.json`

All completed successfully.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
