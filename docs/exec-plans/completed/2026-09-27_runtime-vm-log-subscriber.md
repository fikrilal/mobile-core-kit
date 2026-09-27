# Subscribe Maestro evidence to the Dart VM Logging stream

**Plan version:** 2
**Task ID:** runtime-vm-log-subscriber
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** While Maestro evidence is attached, also subscribe to the Dart VM Logging stream and drop repeated FlutterJNI viewport-metrics lines from the local log. Do not launch `flutter run`. No commit, push, or draft PR.
**Allowed paths:** docs/exec-plans/active/2026-09-27_runtime-vm-log-subscriber.md, packages/mobile_core_kit_cli/lib/src/runtime/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/test/runtime_vm_log_test.dart, packages/mobile_core_kit_cli/pubspec.yaml, packages/mobile_core_kit_cli/pubspec.lock, pubspec.lock, docs/engineering/harness/mobile_runtime_harness.md, docs/engineering/harness/maestro_flows.md, docs/engineering/harness/mobilekit_cli_reference.md, maestro/README.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 90m
**Oracle IDs:** harness.full

Date: 2026-09-27
Related issue/PR: N/A

## Objective

`logs/logcat.log` from Maestro evidence currently records `flutter logs`
only. App lines from `dart:developer` `log()` (`[GoRouter]`,
`[SessionManager]`, `[network]`) never arrive, and repeated
`Sending viewport metrics to the engine` lines fill the file. The
attacher must write those developer logs into the same file and drop
that viewport line. Maestro remains the process that launches the app.

## Constraints

- Architecture constraints: keep the subscription inside
  `FlutterRuntimeLogcatAttacher`. Do not add a public command. Do not
  change `evidence.json`.
- Product/runtime constraints: discover the VM service URI from the
  logcat line the engine already prints, reconnect when a later
  `launchApp` prints a new URI, and keep attach best-effort.
- Out of scope: `flutter run` beside Maestro, commit, push, draft PR,
  and changing which process installs or launches the app.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given a logcat line with `The Dart VM service is listening on http://127.0.0.1:<port>/<token>/`, when the attacher is running, then it connects to that service and appends `[logger] message` lines from the Logging stream.
2. Given a new VM service URI after a relaunch, when that line arrives, then the attacher closes the previous subscription and follows the new URI.
3. Given `Sending viewport metrics to the engine`, when the attacher writes the log, then that line is omitted and other logcat lines remain.

## Acceptance Criteria

1. Unit tests cover URI parsing, websocket conversion, viewport filtering, developer-log formatting, reconnect, and a failed subscribe that does not print the VM token.
2. A debug app already installed on `emulator-5554` produces at least one `[GoRouter]` or `[SessionManager]` line in the attacher log without `flutter run`.
3. Docs that describe the evidence attach no longer say the file is only `flutter logs`.

## Implementation Checklist

- [x] Add the VM Logging subscriber and viewport filter to the attacher.
- [x] Depend on `vm_service` directly from the CLI package.
- [x] Update the runtime and Maestro docs.
- [x] Unit-test the attacher with a fake logs process and connector.
- [x] Capture a real log from `emulator-5554`.

## Decision Log

- 2026-09-27: Subscribe to the VM service URI already printed in logcat. `flutter run` stays forbidden because Maestro `launchApp` kills it.

## Verification

```bash
dart test test/runtime_vm_log_test.dart
dart run mobile_core_kit_cli:mobilekit task verify --task runtime-vm-log-subscriber --env dev
```

## Runtime Evidence

Harness-only change. The live check is a local attacher capture on
`emulator-5554` for the debug package `dev.fikril.mobile.corekit.dev`.
It is a diagnostic log, not handoff evidence. No Maestro oracle is
selected.

## Rollback

Revert the attacher to `flutter logs` byte forwarding and remove the
direct `vm_service` dependency.

## Risks And Mitigations

- Risk: a VM subscribe error could fail the Maestro run.
- Mitigation: subscribe failures are written as one redacted line and do not change the evidence exit code.
- Risk: the VM auth token appears in the local log.
- Mitigation: that URL is already present in today's logcat line. Failure text must not repeat it. The log stays a capped, gitignored, local diagnostic.

## Completion Notes

The attacher forwards the device VM service port with `adb forward`,
subscribes to Logging, and drops viewport-metrics lines. CLI unit tests
passed. A cold start of `dev.fikril.mobile.corekit.dev` on
`emulator-5554` wrote `[GoRouter]` and `[SessionManager]` into the log
without `flutter run`.

## Follow-ups

None.
