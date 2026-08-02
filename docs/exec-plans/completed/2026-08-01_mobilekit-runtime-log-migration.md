# Mobilekit Runtime Log Session Migration

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`

## Objective

Move the legacy Flutter log helper into the internal `mobilekit` CLI as
`mobilekit runtime logs`, preserving its session lifecycle and runtime log
artifacts while removing the redundant shell entrypoint.

## Constraints

- preserve the existing `start`, `status`, `tail`, and `stop` operations;
- preserve `logs` and `run` modes, device/flavor/target options, forwarded
  Flutter arguments, and artifact paths;
- resolve Flutter through the repository's existing pinned-SDK behavior;
- keep runtime log session state under `_artifacts/runtime_logs/`;
- keep the implementation internal to `mobile_core_kit_cli` and do not add
  application runtime behavior;
- keep the separate device-evidence workflow out of scope;
- avoid changing unrelated existing working-tree changes.

## Acceptance Criteria

1. `mobilekit runtime logs start|status|tail|stop` is available with command
   help and validation for the existing options.
2. `start --mode logs` launches `flutter logs`, while `start --mode run`
   launches `flutter run` with the configured flavor, target, and environment
   define.
3. Sessions write the same log, PID, metadata, and command artifacts and can
   be inspected or stopped from a later CLI invocation.
4. The CLI uses the repository-pinned Flutter executable when available.
5. Focused tests cover parsing, command construction, session artifacts, stale
   sessions, tailing, and stopping through injected process behavior.
6. Runtime-harness documentation uses the CLI command and the shell helper is
   removed.

## Implementation Checklist

- [x] Add a Dart runtime-log session/process abstraction.
- [x] Add `mobilekit runtime logs` command routing and usage output.
- [x] Add focused CLI and session-manager tests.
- [x] Update runtime-harness documentation.
- [x] Remove the legacy Flutter log helper.
- [x] Run required verification and record evidence.

## Decision Log

- 2026-08-01: Use `mobilekit runtime logs` as a grouped command because the
  helper manages runtime sessions rather than repository verification.
- 2026-08-01: Use Dart detached-process APIs and injectable process operations;
  this keeps the CLI testable and removes the shell-only `setsid` dependency.
- 2026-08-01: Keep the existing runtime artifact layout so existing evidence
  references remain understandable.

## Verification

Planned commands:

```bash
dart format packages/mobile_core_kit_cli
dart analyze packages/mobile_core_kit_cli
dart run test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit runtime logs --help
dart run mobile_core_kit_cli:mobilekit runtime logs status --session migration-check
dart run mobile_core_kit_cli:mobilekit verify --env dev
git diff --check
```

All commands passed. Package tests completed with 33 passing tests. The full
repository gate completed with 553 passing Flutter tests, clean Flutter
analysis, custom lints, duplication profiles, guardrails, and format checks.

## Runtime Evidence

No device evidence was required for this tooling-only migration. A POSIX host
process smoke test started a detached `sh` process, captured output into the
session log, and stopped it successfully.

- Device/emulator: N/A for the initial migration
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: A real device smoke test remains optional because the Flutter process
  itself was not launched in the repository verification environment.

## Risks And Mitigations

- Risk: detached child processes outlive the CLI invocation and may leave
  stale PID files.
  Mitigation: preserve stale-session detection and remove stale PID files;
  cover the lifecycle with injected process tests.

- Risk: stopping a Flutter process may not stop every child it spawned.
  Mitigation: document the initial behavior and keep the process abstraction
  isolated so process-group handling can be strengthened without changing the
  CLI command surface.

- Risk: runtime logging is platform-sensitive.
  Mitigation: use Dart process APIs, preserve platform-aware executable
  resolution, and avoid claiming device execution in unit tests.

## Completion Notes

- Added `mobilekit runtime logs start|status|tail|stop` under the CLI package.
- Preserved `logs` and `run` modes, device/flavor/target options, forwarded
  Flutter arguments, pinned Flutter resolution, and runtime artifact paths.
- Added detached Dart process handling with injectable process controls for
  deterministic tests.
- Updated `docs/engineering/mobile_runtime_harness.md` to use the CLI and
  removed the legacy Flutter log helper.
- Kept device evidence as a separate runtime CLI workflow.

## Follow-ups

- [ ] Strengthen stop behavior to terminate a full Flutter child process tree
  if runtime use shows that direct-PID termination is insufficient.
