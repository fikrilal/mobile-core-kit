# Mobilekit Runtime Evidence Migration

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`

## Objective

Move `tool/agent/mobile_evidence_check.sh` into the internal `mobilekit` CLI
as `mobilekit runtime evidence`, preserving device integration-test execution,
preflight behavior, artifact layout, and failure reporting while using the
CLI's repository and SDK resolution.

## Constraints

- preserve `--device`, `--flavor`, repeatable `--target`, `--artifacts-dir`,
  `--no-example-env-fallback`, and `--google-services-json` behavior;
- preserve sorted automatic discovery of `integration_test/*_test.dart`;
- preserve environment fallback, Google services copying, build-config
  generation, Google services candidate checks, and their observable errors;
- preserve `_artifacts/mobile/<timestamp>/` layout, metadata, summary, logs,
  signal extracts, and aggregate exit behavior;
- resolve Dart and Flutter through the repository's pinned SDK behavior;
- keep the workflow internal to `mobile_core_kit_cli` and do not change app or
  integration-test behavior;
- keep `mobilekit runtime logs` behavior unchanged;
- leave the unrelated pre-existing splash-generator deletion untouched.

## Acceptance Criteria

1. `mobilekit runtime evidence --device <id>` is available with help and
   validation for all existing options.
2. The command discovers or accepts integration targets and runs each target
   with the same device, flavor, and Flutter test arguments.
3. Preflight generates build configuration and validates environment and
   Google services inputs with the same fallback rules.
4. The command writes compatible metadata, summary, per-target logs, and
   startup/trace signal extracts under the requested artifact directory.
5. All targets run even when an earlier target fails, and the final exit code
   is non-zero if preflight or any target fails.
6. Focused tests cover parsing, target discovery, fallback/copy behavior,
   command construction, artifact contents, failure aggregation, and signal
   extraction through an injected process runner.
7. Runtime-harness documentation uses the CLI command and the shell helper is
   removed.

## Implementation Checklist

- [x] Add captured process execution for synchronous evidence commands.
- [x] Add `RuntimeEvidenceWorkflow` and artifact/summary generation.
- [x] Route `mobilekit runtime evidence` from the CLI.
- [x] Add focused workflow and CLI tests.
- [x] Update runtime-harness documentation and proposal command table.
- [x] Remove `tool/agent/mobile_evidence_check.sh`.
- [x] Run required verification and available device/runtime checks.

## Decision Log

- 2026-08-01: Use `mobilekit runtime evidence` as a sibling of
  `mobilekit runtime logs` because both are runtime-harness operations with
  different lifecycles.
- 2026-08-01: Invoke `BuildConfigWorkflow` directly for preflight while using
  captured subprocess execution for its formatter and the integration tests;
  this avoids spawning a nested mobilekit process and keeps the CLI ownership
  boundary explicit.
- 2026-08-01: Preserve the script's environment and Google services copying
  side effects for behavior parity; record their sources in metadata and the
  summary.

## Verification

Planned commands:

```bash
dart format packages/mobile_core_kit_cli
dart analyze packages/mobile_core_kit_cli
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit runtime evidence --help
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

If a configured emulator/device is available, run a targeted evidence command
and inspect the generated summary and logs.

Completed so far:

- `dart format packages/mobile_core_kit_cli`
- `dart analyze packages/mobile_core_kit_cli`
- `dart run test packages/mobile_core_kit_cli/test/runtime_evidence_workflow_test.dart`
- `dart run test packages/mobile_core_kit_cli`
- `dart run mobile_core_kit_cli:mobilekit runtime evidence --help`
- `fvm flutter devices` (no Android/iOS device or emulator available)

Final verification:

- `dart run mobile_core_kit_cli:mobilekit verify --env dev` passed, including
  Flutter analyze, custom lints, duplication profiles, modal/color checks, 553
  Flutter tests, and formatting checks.
- `git diff --check` passed.

## Runtime Evidence

Required for final confidence when a device or emulator is available.

- Device/emulator: unavailable in the current environment
- Flavor: not run
- Executed target(s): not run
- Artifact path(s): package-test temporary directories only
- Notes: Unit tests prove orchestration and artifact parity; they cannot
  prove the Flutter integration test itself on a real device.

## Risks And Mitigations

- Risk: the workflow mutates local environment and platform configuration
  files when fallback/copy options are used.
  Mitigation: preserve the existing explicit flags and record the source in
  metadata and the summary; document the side effects.

- Risk: captured subprocess output changes ordering or hides a failure.
  Mitigation: stream stdout/stderr to the terminal and per-run logs, preserve
  each process exit code, and continue/aggregate target failures explicitly.

- Risk: device-only behavior cannot be fully covered in package tests.
  Mitigation: inject process execution for deterministic tests and run a
  targeted device smoke test when the environment provides a device.

## Completion Notes

Implemented `mobilekit runtime evidence` with the legacy shell workflow's
options, preflight checks, artifact layout, captured logs, signal extracts,
and aggregate target failures. The old shell entry point is removed and the
runtime-harness documentation now points to the CLI.

## Follow-ups

- [ ] Add a CI/device-lab invocation if this workflow becomes part of an
  automated evidence lane.
