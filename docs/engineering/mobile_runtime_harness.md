# Mobile Runtime Harness

This document explains how to collect machine-checkable runtime evidence for mobile changes.

Use this document when the question is:
- how do I prove a mobile/runtime change on a device or emulator?
- what evidence is expected for medium/high-risk behavior?

Use `docs/engineering/agent_pr_loop.md` for the overall PR delivery loop.

## Purpose

The runtime harness closes the gap between:
- code that passes static checks
- behavior that is actually proven on device

It is most useful when static analysis and tests are not enough to prove correctness.

## When Runtime Evidence Is Expected

Collect runtime evidence for changes such as:
- medium/high-risk mobile UI behavior
- startup/navigation/deep-link flows
- auth/session/runtime orchestration
- push/permissions/device integrations
- bugs that require a real device or emulator to reproduce confidently

## Preconditions

1. A device or emulator is available.
2. The selected environment config exists or can be bootstrapped.
3. Required platform config exists for the selected flavor.

If Firebase or similar platform configuration is missing, fail early with an actionable message instead of continuing blindly.

## Runtime Evidence Entry Point

Use `--lane` to select the required proof:

- `flutter`: Flutter `integration_test` evidence. This remains the default.
- `maestro`: compiled-app Maestro journeys without Flutter integration tests.
- `all`: both lanes, with one aggregate summary and exit status.

Default Flutter behavior:

```bash
tool/agent/mobile_evidence_check.sh --device <device-id> --flavor dev
```

Maestro only:

```bash
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device <device-id> \
  --flavor dev \
  --include-tags smoke
```

Both deterministic lanes:

```bash
tool/agent/mobile_evidence_check.sh \
  --lane all \
  --device <device-id> \
  --flavor dev \
  --include-tags smoke
```

For `--lane all`, both lanes run even when the first fails. The command returns
non-zero if either lane fails and writes lane-specific summaries plus an
aggregate `summary.md` and `status.env`. An explicit `--app-file` is copied into
the evidence directory before Flutter integration tests run so their build
cannot overwrite the APK later inspected by Maestro.

Example with explicit platform config:

```bash
tool/agent/mobile_evidence_check.sh \
  --device <device-id> \
  --flavor dev \
  --google-services-json /secure/path/google-services.json
```

Optional single-target run:

```bash
tool/agent/mobile_evidence_check.sh \
  --device <device-id> \
  --target integration_test/auth_happy_path_test.dart
```

Flutter-only artifacts typically include:
- `_artifacts/mobile/<timestamp>/summary.md`
- `_artifacts/mobile/<timestamp>/logs/*.log`

## Interactive Validation

Use this when deterministic tests are not enough and the agent needs to inspect or drive the UI interactively.

Typical loop:
1. enumerate devices
2. launch app
3. inspect UI state
4. interact with controls
5. capture after-state evidence
6. attach evidence paths to the PR

Use this lane for:
- layout regressions
- interaction bugs not covered by integration tests
- flaky/context-sensitive runtime behavior

## Live Log Capture

Use the log bridge when continuous runtime logs help debug or prove behavior.

Examples:

```bash
tool/agent/flutter_log_stream.sh start --session emulator --mode logs --device emulator-5554
```

```bash
tool/agent/flutter_log_stream.sh start \
  --session dev-run \
  --mode run \
  --device emulator-5554 \
  --flavor dev \
  --target lib/main_dev.dart
```

```bash
tool/agent/flutter_log_stream.sh tail --session emulator --lines 200
```

```bash
tool/agent/flutter_log_stream.sh status --session emulator
tool/agent/flutter_log_stream.sh stop --session emulator
```

Session refresh/replay evidence uses a run-scoped local fault proxy:

```bash
./mobtrace verify session-refresh --device emulator-5554 --flavor dev
```

The proxy rejects one `GET /v1/me/sessions`, forwards the real refresh request,
and requires a successful replay with a different access token. It is available
only to the dev APK built for that evidence run and does not modify secure
storage or backend auth behavior.

Typical artifacts:
- `_artifacts/runtime_logs/<session>/stream.log`
- `_artifacts/runtime_logs/<session>/metadata.env`

## Compiled-App Maestro Evidence

Use Maestro for critical cross-screen journeys that lower test layers do not
prove against the compiled application:

```bash
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device emulator-5554 \
  --flavor dev \
  --include-tags smoke
```

The Maestro lane builds or accepts an APK, inspects its application ID,
installs and verifies the package, captures device logs, and retains JUnit plus
Maestro diagnostic artifacts under `_artifacts/mobile/`.

See `docs/engineering/maestro_testing.md` for flow authoring and evidence rules.

## Minimum Evidence To Attach

For runtime-sensitive PRs, attach at least:
1. device/emulator ID
2. flavor
3. executed target(s)
4. artifact path(s)
5. relevant log lines or screenshots when they help prove behavior

## Failure -> Harness Upgrade Rule

If runtime evidence repeatedly fails for the same reason, improve the harness instead of relying on repeated manual work.

Typical upgrades:
- add or strengthen integration tests
- add better assertions to the evidence script
- improve logging/metrics exposure
- update this document with the stable workflow

## Related Docs

- `docs/engineering/agent_pr_loop.md`
- `docs/engineering/guardrails.md`
- `docs/engineering/maestro_testing.md`
