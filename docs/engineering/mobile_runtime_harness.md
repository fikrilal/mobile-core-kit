# Mobile Runtime Harness (Agent Workflow)

This document defines how to collect machine-checkable runtime evidence for mobile changes.

It is designed to close the "agent can write code but cannot reliably verify behavior on device" gap.

## Objectives

1. Make runtime validation deterministic and repeatable.
2. Produce artifacts suitable for PR review.
3. Keep the workflow compatible with both local CLI and mobile MCP interaction.

## Preconditions

1. A device/emulator is online (`adb devices` or mobile MCP device list).
2. Environment config is available for selected flavor:
- for `dev` and `staging`, `tool/agent/mobile_evidence_check.sh` can bootstrap from `.env/<env>.example.yaml`
- for `prod`, `.env/prod.yaml` must exist and be non-empty
3. Firebase Android config is present for selected flavor:
- one of the `google-services.json` locations checked by the harness must exist (for example `android/app/google-services.json`)
- you can stage it automatically for local runs with `--google-services-json <path>`
- if missing, preflight fails with a short actionable summary and pointer to `docs/engineering/firebase_setup.md`

## Two-Lane Model

## Lane A: Deterministic CLI Evidence (required baseline)

Use this for every medium/high UI or runtime-impacting PR.

1. Ensure a device/emulator is running.
2. Run:

```bash
tool/agent/mobile_evidence_check.sh --device <device-id> --flavor dev
```

If your Firebase file is stored outside this repository:

```bash
tool/agent/mobile_evidence_check.sh --device <device-id> --flavor dev --google-services-json /secure/path/google-services.json
```

3. Attach artifacts from:
- `_artifacts/mobile/<timestamp>/summary.md`
- `_artifacts/mobile/<timestamp>/logs/*.log`

Notes:
- You can target a single test:

```bash
tool/agent/mobile_evidence_check.sh --device <device-id> --target integration_test/auth_happy_path_test.dart
```

## Lane B: Interactive MCP Validation (optional but recommended)

Use mobile MCP when the agent needs interactive verification/debugging beyond scripted integration tests.

Typical loop:
1. Enumerate devices.
2. Launch app.
3. Inspect UI state (screenshot / view hierarchy).
4. Interact with controls.
5. Capture after-state screenshots.
6. Include evidence links/paths in PR.

This lane is best for:
- layout regressions
- interaction-only issues not covered by current integration tests
- flaky or context-sensitive bug reproduction

## Live Flutter Log Bridge (agent-readable)

Use this when the agent needs continuous runtime logs during an interactive loop.

Start a session (attach to existing app logs):

```bash
tool/agent/flutter_log_stream.sh start --session emulator --mode logs --device emulator-5554
```

Start a session that launches the app and streams runtime output:

```bash
tool/agent/flutter_log_stream.sh start --session dev-run --mode run --device emulator-5554 --flavor dev --target lib/main_dev.dart
```

Read current logs:

```bash
tool/agent/flutter_log_stream.sh tail --session emulator --lines 200
```

Inspect status and stop:

```bash
tool/agent/flutter_log_stream.sh status --session emulator
tool/agent/flutter_log_stream.sh stop --session emulator
```

Artifacts are written under:
- `_artifacts/runtime_logs/<session>/stream.log`
- `_artifacts/runtime_logs/<session>/metadata.env`

This is intentionally file-backed so any agent with terminal + file access (or an MCP wrapper around shell commands) can poll logs without keeping a single interactive terminal session alive.

## PR Evidence Requirements (for UI/runtime changes)

At minimum, include:
1. device ID + flavor
2. test targets executed
3. summary artifact path
4. relevant log snippets (startup metric, traceId, or error lines)

## Failure Handling

If runtime evidence repeatedly fails for the same reason (2+ times), promote that class of failure into harness tooling:
- add or refine integration tests
- add stronger log/metric assertions
- add new script checks
- update this workflow doc

## Session Status (Current)

1. Mobile MCP connectivity is healthy (`emulator-5554` discoverable and queryable).
2. CLI lane preflight now auto-generates `build_config_values.dart` and validates Google Services config before running integration tests.
