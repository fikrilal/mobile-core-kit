# Mobilekit Lint Command And Policy Layout

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: low
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`

## Objective

Expose the repository's lint checks as `mobilekit lint` and move the lint
configuration out of `tool/lints/` into a root-level `lint/` directory. Keep
the custom lint implementation in `packages/mobile_core_kit_lints/` and keep
the analyzer/IDE wiring working through `analysis_options.yaml`.

## Constraints

- preserve the behavior of `flutter analyze` and `dart run custom_lint`;
- keep `mobilekit verify` as the full verification gate and reuse the lint
  workflow instead of duplicating its steps;
- keep repository policy/configuration separate from CLI implementation;
- move all four existing files under `tool/lints/` together:
  `architecture_lints.yaml`, `flutter_lints.yaml`, `lints_core.yaml`, and
  `lints_recommended.yaml`;
- update custom-lint fallback paths, diagnostics, docs, tests, and proposal
  references to the new `lint/` location;
- do not change individual lint rules or their allowlists.

## Acceptance Criteria

1. `mobilekit lint` runs Flutter analyzer followed by custom lint and returns
   the first non-zero exit code.
2. `mobilekit lint --help` works without locating a repository.
3. `mobilekit verify` reuses the same lint workflow and preserves its command
   sequence.
4. The analyzer resolves `lint/flutter_lints.yaml`, and the architecture lint
   resolves `lint/architecture_lints.yaml` by default.
5. No active source or documentation reference still points at `tool/lints/`.
6. Focused CLI/workflow tests and the full repository verification pass.

## Implementation Checklist

- [x] Add `LintWorkflow` and route `mobilekit lint`.
- [x] Reuse `LintWorkflow` from `VerifyWorkflow`.
- [x] Add command/workflow tests.
- [x] Move the four lint YAML files to `lint/`.
- [x] Update analyzer/custom-lint wiring and all active references.
- [x] Run focused/package/full verification.

## Decision Log

- 2026-08-01: Use root-level `lint/` for repository lint policy. `tool/` is
  reserved for executable harness implementation and data tightly coupled to
  those tools; lint policy is consumed directly by the analyzer and IDE.
- 2026-08-01: Keep `packages/mobile_core_kit_lints/` separate. It contains
  executable AST-based lint rules; `lint/` contains their configuration and
  the vendored standard Dart/Flutter rule sets.

## Verification

Planned commands:

```bash
dart format packages/mobile_core_kit_cli packages/mobile_core_kit_lints
dart analyze packages/mobile_core_kit_cli packages/mobile_core_kit_lints
dart run test packages/mobile_core_kit_cli
dart run custom_lint
dart run mobile_core_kit_cli:mobilekit lint --help
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

## Completion Notes

- Added `mobilekit lint` for Flutter analyzer plus custom lint checks.
- Reused the same workflow from `mobilekit verify` so the canonical gate keeps
  its existing command sequence.
- Moved repository lint policy from `tool/lints/` to root `lint/` and updated
  analyzer wiring, custom-lint fallback paths, docs, and proposal references.
- Kept executable harness implementation under `tool/` and executable custom
  lint rules under `packages/mobile_core_kit_lints/`.

Verification completed on 2026-08-01:

- `dart format packages/mobile_core_kit_cli packages/mobile_core_kit_lints`
- `dart analyze packages/mobile_core_kit_cli packages/mobile_core_kit_lints`
- `dart run custom_lint`
- `dart run mobile_core_kit_cli:mobilekit lint --help`
- `dart run mobile_core_kit_cli:mobilekit lint`
- `dart run test packages/mobile_core_kit_cli`
- `dart run mobile_core_kit_cli:mobilekit verify --env dev`
- `git diff --check`

All completed successfully.

## Follow-ups

- [ ] Consider a future dedicated `mobilekit lint --fix` only if the team
  needs a lint-specific fix mode; this plan intentionally adds no new flags.
