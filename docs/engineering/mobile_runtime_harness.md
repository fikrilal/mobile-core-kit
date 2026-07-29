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

## Two Evidence Lanes

### Lane A: Deterministic CLI evidence

Use this as the default runtime-evidence path.

Primary command:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device <device-id> --flavor dev
```

Example with explicit platform config:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device <device-id> \
  --flavor dev \
  --google-services-json /secure/path/google-services.json
```

Optional single-target run:

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device <device-id> \
  --target integration_test/auth_happy_path_test.dart
```

Expected artifacts typically include:
- `_artifacts/mobile/<timestamp>/summary.md`
- `_artifacts/mobile/<timestamp>/logs/*.log`

### Lane B: Interactive validation

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

Use the CLI log bridge when continuous runtime logs help debug or prove
behavior.

Examples:

```bash
dart run mobile_core_kit_cli:mobilekit runtime logs start \
  --session emulator --mode logs --device emulator-5554
```

```bash
dart run mobile_core_kit_cli:mobilekit runtime logs start \
  --session dev-run \
  --mode run \
  --device emulator-5554 \
  --flavor dev \
  --target lib/main_dev.dart
```

```bash
dart run mobile_core_kit_cli:mobilekit runtime logs tail \
  --session emulator --lines 200
```

```bash
dart run mobile_core_kit_cli:mobilekit runtime logs status \
  --session emulator
dart run mobile_core_kit_cli:mobilekit runtime logs stop \
  --session emulator
```

Typical artifacts:
- `_artifacts/runtime_logs/<session>/stream.log`
- `_artifacts/runtime_logs/<session>/metadata.env`

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
- add better assertions to the CLI evidence workflow
- improve logging/metrics exposure
- update this document with the stable workflow

## Related Docs

- `docs/engineering/agent_pr_loop.md`
- `docs/engineering/guardrails.md`
- `docs/engineering/mobilekit_cli_reference.md`
