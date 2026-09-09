# Maestro Journey Proof — Plumbing

**Plan version:** 2
**Task ID:** maestro-journey-plumbing
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Implement and verify the local Maestro plumbing (oracle kind, login YAML, binding, `runtime evidence` shell-out, `handoff check`, doctor PATH check, CLI tests, docs). No commit, push, or draft-PR. No live-backend journey run as completion evidence. No CI job, Maestro Cloud, MCP wrapper, or `mobilekit maestro` command.
**Allowed paths:** docs/exec-plans/queued/2026-09-08_maestro-journey-plumbing.md, docs/exec-plans/active/2026-09-08_maestro-journey-plumbing.md, docs/exec-plans/completed/2026-09-08_maestro-journey-plumbing.md, packages/mobile_core_kit_cli/lib/src/oracle/, packages/mobile_core_kit_cli/lib/src/runtime/, packages/mobile_core_kit_cli/lib/src/handoff/, packages/mobile_core_kit_cli/lib/src/doctor/, packages/mobile_core_kit_cli/test/, harness/oracles.yaml, maestro/, docs/engineering/mobile_runtime_harness.md, docs/engineering/behavioral_oracles.md, docs/engineering/mobilekit_cli_reference.md, docs/engineering/testing_strategy.md, docs/engineering/agent_pr_loop.md, AGENTS.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 8h
**Oracle IDs:** harness.full

Date: 2026-09-08
Related issue/PR: `_WIP/2026-09-06_maestro-device-proof-proposal.md`

## Objective

Make `mobilekit runtime evidence` able to run a registered `maestro-flow`
target, bind the result to the task fingerprint, and have `handoff check`
treat that result like `integration-test`. Register `auth.journey` pointing
at `maestro/login.yaml` so the follow-up pilot plan can select it.

This task does not prove login on an emulator. That is
`maestro-login-pilot`.

## Constraints

- Architecture constraints: extend existing `RuntimeEvidenceWorkflow`,
  `TaskRuntimeEvidenceBindingResolver`, `CompletionEvidenceReader`, and
  `OracleRegistry`. Thin wrapper only: invoke the `maestro` binary, do not
  reimplement Maestro. Do not add a second evidence schema or artifact root.
- Product/runtime constraints: `maestro-flow` rejects `--flavor prod`.
  Missing binary or unregistered YAML fails closed. Do not fall back to
  example env or the CI Firebase fixture for `maestro-flow`. Credentials
  used by a flow must not appear in `evidence.json` / `summary.md`.
- Out of scope: live emulator proof, Maestro Cloud, MCP server, CI Runtime
  changes, `verify --profile full` executing Maestro, replacing
  `integration_test` wiring oracles, a second YAML flow, iOS-only work,
  commit/push/draft-PR.

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

1. Given `harness/oracles.yaml` after this task, when `oracle verify` runs,
   then kind `maestro-flow` is valid and target `maestro/login.yaml` exists.
2. Given a verified task that selected a `maestro-flow` oracle, when
   `runtime evidence --target maestro/login.yaml` runs, then the workflow
   invokes `maestro test` (not `flutter test`) and writes schema-v1
   `evidence.json` with `boundary: runtime.maestro`.
3. Given the same task, when `handoff check` runs, then `maestro-flow` is
   satisfied from that manifest like `integration-test` (exact target,
   latest-wins). It does not fall through to `manual-evidence.json`.
4. Given an unverified fingerprint, missing `maestro` binary, unregistered
   target, or `--flavor prod`, when runtime evidence runs, then it fails
   closed with a stable error code.
5. Given `mobilekit doctor`, when `maestro` is absent from `PATH`, then the
   report warns; doctor does not fail the whole check solely for that.
6. Given `verify --profile full`, when it runs, then it tests the wrapper
   with CLI tests and does not execute Maestro on a device.

## Acceptance Criteria

1. `OracleRegistry._oracleKinds` includes `maestro-flow`.
2. `harness/oracles.yaml` registers `auth.journey` (`maestro-flow`,
   `maestro/login.yaml`, covers `auth` and `ui`).
3. `maestro/login.yaml` is a real auth happy-path flow (sign-in CTA already
   has `authSemanticSignIn`). No committed credentials.
4. Binding collects `maestro-flow` as well as `integration-test`.
5. `CompletionEvidenceReader` treats `maestro-flow` like
   `integration-test`.
6. CLI tests cover kind, binding, missing binary, unregistered target,
   unverified fingerprint, prod rejection, and handoff latest-wins.
7. Docs listed in allowed paths describe: kit CLI is proof; raw
   `maestro test` and Maestro MCP are iteration only; not a CI lane.
8. `.github/workflows/required.yml` is not in scope and stays unchanged.

## Implementation Checklist

- [x] Add `maestro-flow` to the oracle registry parser and `oracle verify`.
- [x] Add `maestro/login.yaml` and register `auth.journey`.
- [x] Extend binding to collect `maestro-flow` targets.
- [x] Extend `RuntimeEvidenceWorkflow` to shell out to `maestro test` for
      those targets; keep `flutter test` for `integration-test`.
- [x] Reject `--flavor prod` for `maestro-flow`; fail closed on missing
      binary / unregistered path / stale fingerprint.
- [x] Extend `CompletionEvidenceReader` for `maestro-flow`.
- [x] Warn in `mobilekit doctor` when `maestro` is not on `PATH`.
- [x] Add CLI tests for the wrapper (no live device required).
- [x] Update the allowed engineering docs and `AGENTS.md` map pointer if
      needed.
- [x] Run `task verify` for this task (`harness.full`).

## Decision Log

- 2026-09-08: Two plans, not one, because `task begin` rejects unknown
  Oracle IDs. This plan creates `auth.journey`; the pilot selects it.
- 2026-09-08: Proof interface is `mobilekit runtime evidence`. Raw Maestro
  CLI and MCP are iteration only.
- 2026-09-08: Doctor warns if the binary is missing; runtime evidence
  errors. Installing Maestro is a human machine setup, not a pub
  dependency.
- 2026-09-08: No commit/push in this baseline. Publication is a later
  explicit action.
- 2026-09-08: Activated. `harness-evidence-push` parked to queued so this
  can be the single active V2. Push+draft-PR was not completed.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-journey-plumbing --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-journey-plumbing --env dev
dart run mobile_core_kit_cli:mobilekit oracle verify
dart test packages/mobile_core_kit_cli/test
```

2026-09-08: `task verify --task maestro-journey-plumbing --env dev` passed
(`verified`, profile=full, attempt=1). `oracle verify`: 11 registered.
No live Maestro emulator run (out of scope).

## Runtime Evidence

Not required. This task is harness plumbing. Device journey proof is
`maestro-login-pilot` after `auth.journey` exists.

## Rollback

Revert the task-owned files. Leave any user-installed Maestro CLI in
place. Delete `maestro/` if it contains only this task's YAML.

## Risks And Mitigations

- Risk: `maestro-flow` falls through to manual attestation if handoff is
  not extended. Mitigation: CLI test that a passing manifest satisfies
  `handoff check` and a missing one does not.
- Risk: wrapper calls `flutter test` for YAML paths. Mitigation: branch
  on oracle kind; test the process command list.
- Risk: live-backend flake blocks this task. Mitigation: no live device
  gate here.

## Completion Notes

Plumbing implemented, `task verify` passed, and source committed as
`13ba726`. Completed 2026-09-08 so `maestro-login-pilot` can be the
single active V2.

## Follow-ups

- [x] After this plan is completed, update
      `docs/exec-plans/queued/2026-09-08_maestro-login-pilot.md` Oracle IDs
      to `auth.journey` (new authority hash, then begin).
- [x] No tech-debt tracker row; wrapper has no known holes.
