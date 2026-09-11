# Optional `--task` on Maestro evidence; drop `runtime logs`

**Plan version:** 2
**Task ID:** runtime-evidence-iterate
**Status:** active
**Owner:** fikrilal
**Risk:** high
**Authority:** Implement `_WIP/2026-09-09_runtime-journey-cli.md`: optional `--task` on `runtime evidence` for Maestro YAML, auto-attach `flutter logs` for the Maestro process, delete the public `runtime logs` command. No new kit verb. No commit, push, or draft-PR. No CI, Maestro Cloud, or MCP-as-proof.
**Allowed paths:** docs/exec-plans/queued/2026-09-09_runtime-evidence-iterate.md, docs/exec-plans/active/2026-09-09_runtime-evidence-iterate.md, docs/exec-plans/completed/2026-09-09_runtime-evidence-iterate.md, packages/mobile_core_kit_cli/lib/src/runtime/, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/test/runtime_evidence_workflow_test.dart, packages/mobile_core_kit_cli/test/runtime_log_workflow_test.dart, packages/mobile_core_kit_cli/test/mobilekit_cli_test.dart, docs/engineering/mobile_runtime_harness.md, docs/engineering/mobilekit_cli_reference.md, docs/engineering/agent_pr_loop.md, maestro/README.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h
**Oracle IDs:** harness.full

Date: 2026-09-09
Related issue/PR: `_WIP/2026-09-09_runtime-journey-cli.md`;
`_WIP/2026-09-06_maestro-device-proof-proposal.md`

## Objective

One kit runtime command. `runtime evidence` iterates a Maestro YAML
without `--task` (no `evidence.json`). With `--task` it still binds
proof. YAML runs attach `flutter logs -d` for the Maestro lifetime,
then stop. Public `runtime logs` is removed. Humans use `fvm flutter
run` / `fvm flutter logs`.

## Constraints

- Architecture constraints: no `runtime journey`, no `mobilekit maestro`.
  Reuse `RuntimeEvidenceWorkflow` and, if useful, `RuntimeLogSession`
  internally. Do not change `evidence.json` schema, sanitizer, or
  `durable-summary` path tagging. Dart `integration-test` still requires
  `--task`.
- Product/runtime constraints: fail-closed gates stay (no prod, no
  example env, no CI google-services, missing `maestro` binary). Iterate
  may run any existing `maestro/*.yaml`. Prove still requires a selected
  `maestro-flow` oracle and a live verified fingerprint.
- Out of scope: beginning while `maestro-register-pilot` is the active
  V2; rebinding completed tasks; Nest log scrape; Maestro Cloud; CI
  device farm; optional `--task` for Dart tests; commit/push/draft-PR;
  `--no-logs` flag.

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

1. Given a `maestro/*.yaml` and no `--task`, when `runtime evidence
   --device … --flavor dev --target maestro/login.yaml` runs, then
   Maestro runs, logcat is attached then stopped, exit is Maestro’s
   code, and no `evidence.json` is written.
2. Given a verified task that selects that YAML, when the same command
   includes `--task`, then `evidence.json` is written and `handoff check`
   can accept the `maestro-flow` oracle (`durable-summary` on
   `summary.md`).
3. Given `mobilekit runtime logs …`, when the CLI parses it, then it is
   an unknown command (help does not list it).
4. Given `--flavor prod` or a missing `maestro` binary, when evidence
   runs with or without `--task`, then it fails closed.

## Acceptance Criteria

1. `--task` is optional for Maestro YAML targets and required for Dart
   `integration-test` targets (usage exit 2 if omitted).
2. YAML path starts `flutter logs -d` before Maestro and stops it after,
   including on Maestro failure. Attach failure warns; Maestro still
   runs. No `--no-logs`.
3. `RuntimeLogWorkflow` is not dispatched from `mobilekit_cli.dart`.
   `mobilekit_cli_test` no longer expects `Usage: mobilekit runtime logs`.
4. `task verify --task runtime-evidence-iterate --env dev` passes.
5. Docs no longer tell agents to `runtime logs --mode run` (or `--mode
   logs`) before Maestro. CLI reference drops the `runtime logs` row.

## Implementation Checklist

- [x] Blocked: do not `task begin` while `maestro-register-pilot` is
      the active V2.
- [x] Park or complete `maestro-register-pilot` (one active V2).
- [x] Activate this plan (status active, move to `active/`).
- [x] `task begin --plan docs/exec-plans/active/2026-09-09_runtime-evidence-iterate.md`.
- [x] Optional `--task` + YAML iterate/prove branch in
      `RuntimeEvidenceWorkflow`.
- [x] Auto-attach `flutter logs` for YAML; always stop.
- [x] Remove public `runtime logs` dispatch and update CLI tests.
- [x] Update harness, CLI reference, agent_pr_loop, `maestro/README.md`.
- [ ] `task verify --task runtime-evidence-iterate --env dev`.

## Decision Log

- 2026-09-09: User rejected a new `runtime journey` verb (more surface).
  Same `runtime evidence` command, `--task` optional for YAML.
- 2026-09-09: User asked to keep the CLI small. Public `runtime logs`
  is a wrap of `fvm flutter logs` / `flutter run` with no bind. Cut it.
  Evidence attaches logcat internally for YAML only.
- 2026-09-09: Gate is `harness.full` / CLI tests. Live Maestro smoke is
  optional, not an oracle. Platform impact stays no.

## Verification

Do not run these until after `task begin`.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task runtime-evidence-iterate --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task runtime-evidence-iterate --env dev
```

Optional smoke (not required for verify):

```bash
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --device emulator-5554 --flavor dev --target maestro/login.yaml
# expect Maestro exit, no evidence.json
```

## Runtime Evidence

Not required. Writer/reader contract and command dispatch are proven by
CLI tests. Device journey proof stays on `auth.journey` /
`auth.register-journey` under their own tasks.

## Rollback

Revert the task-owned CLI and doc files. Restore `runtime logs`
dispatch if this lands mid-way. Leave register-pilot as it was.

## Risks And Mitigations

- Risk: humans still type `runtime logs start --mode run`. Mitigation:
  unknown-command error; docs point at `fvm flutter run` / `fvm flutter logs`.
- Risk: leftover pid sessions from today’s `runtime logs`. Mitigation:
  no migration command; ignore or kill by hand.
- Risk: logcat attach dies. Mitigation: warn, still run Maestro.
- Risk: `--task` omitted on a Dart target. Mitigation: usage exit 2.

## Completion Notes

Pending.

## Follow-ups

None required. Optional later: mark the interface section of
`_WIP/2026-09-06_maestro-device-proof-proposal.md` superseded (that
file is out of this plan’s allowed paths).
