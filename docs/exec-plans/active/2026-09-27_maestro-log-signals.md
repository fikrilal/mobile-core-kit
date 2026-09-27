# Require Maestro evidence logs to show the journey

**Plan version:** 2
**Task ID:** maestro-log-signals
**Status:** active
**Owner:** fikrilal
**Risk:** high
**Authority:** Fail a Maestro evidence run when the Dart VM log did not attach, or when the registered flow's success line is absent. Record only signal ids in evidence.json. No commit, push, or draft PR.
**Allowed paths:** docs/exec-plans/active/2026-09-27_maestro-log-signals.md, docs/exec-plans/active/2026-09-27_runtime-vm-log-subscriber.md, docs/exec-plans/completed/2026-09-27_runtime-vm-log-subscriber.md, packages/mobile_core_kit_cli/lib/src/runtime/, packages/mobile_core_kit_cli/lib/src/oracle/oracle_registry.dart, packages/mobile_core_kit_cli/test/runtime_log_signals_test.dart, packages/mobile_core_kit_cli/test/runtime_evidence_workflow_test.dart, packages/mobile_core_kit_cli/test/oracle_registry_test.dart, packages/mobile_core_kit_cli/test/runtime_evidence_binding_test.dart, packages/mobile_core_kit_cli/test/completion_evidence_test.dart, harness/oracles.yaml, docs/engineering/mobile_runtime_harness.md, docs/engineering/behavioral_oracles.md, docs/engineering/maestro_flows.md, maestro/README.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 90m
**Oracle IDs:** harness.full

Date: 2026-09-27
Related issue/PR: N/A

## Objective

Every Maestro evidence run must show that the VM Logging stream
attached, and each registered `maestro-flow` must name one success
substring. A missing signal fails the run. `evidence.json` and the
summary store signal ids only.

## Constraints

- Architecture constraints: keep the raw log `transient-local-log`.
  Do not copy log lines, tokens, or bodies into `evidence.json`.
- Product/runtime constraints: the check applies to iterate and prove.
  Integration-test runs are unchanged.
- Out of scope: Patrol, commit, push, draft PR, and hosted Maestro.

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

1. Given a Maestro log with no `[Name] ` developer line, when evidence finishes, then the run fails with missing id `vm-log-attached`.
2. Given a registered flow whose success substring is absent, when Maestro itself exits 0, then the run fails with that signal id and the manifest does not contain the log text.
3. Given the substring is present and a developer log line exists, when Maestro exits 0, then the run stays passed.

## Acceptance Criteria

1. All six `maestro-flow` oracles declare `logSignals`.
2. Unit tests cover the matcher, a missing VM log, and a missing journey signal.
3. `knowledge verify` accepts the registry.

## Implementation Checklist

- [x] Parse `logSignals` on `maestro-flow` oracles.
- [x] Fail iterate and prove when the VM log or a required signal is missing.
- [x] Store signal ids only in the manifest and summary.
- [x] Document the check.

## Decision Log

- 2026-09-27: One implicit `vm-log-attached` signal for every Maestro run. Each flow adds its own 2xx request line, matched by substring, so a UI-only pass cannot hide a 401.

## Verification

```bash
dart test test/runtime_log_signals_test.dart test/oracle_registry_test.dart test/runtime_evidence_workflow_test.dart
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-log-signals --env dev
```

## Runtime Evidence

No device run in this change. The check is unit-tested against log text. A later Maestro run is the live proof.

## Rollback

Remove `logSignals` from the registry and stop reading `logcat.log` after the Maestro process exits.

## Risks And Mitigations

- Risk: a 204 or 201 line uses a different status digit and the substring `→ 2` still matches every 2xx.
- Mitigation: `→ 2` is intentional so 200, 201, and 204 all count as success and 4xx does not.
- Risk: the route table printed at startup contains `/home` and would pass a weak substring.
- Mitigation: signals use the network success line, not a route that appears in the startup dump.

## Completion Notes

`maestro-flow` oracles declare one 2xx request substring. Iterate and
prove fail when `vm-log-attached` or that id is missing. The manifest
stores ids only. Unit tests passed. Device proof is a follow-up run.

## Follow-ups

None.
