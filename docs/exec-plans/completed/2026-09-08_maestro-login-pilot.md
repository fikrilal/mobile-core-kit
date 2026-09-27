# Maestro Journey Proof — Login Pilot

**Plan version:** 2
**Task ID:** maestro-login-pilot
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Run the local agent journey loop for email/password login on a local Android emulator against the real dev backend. Bind Maestro evidence via `mobilekit runtime evidence`. No commit, push, or draft-PR. No CI, Maestro Cloud, or MCP-as-proof.
**Allowed paths:** docs/exec-plans/queued/2026-09-08_maestro-login-pilot.md, docs/exec-plans/active/2026-09-08_maestro-login-pilot.md, docs/exec-plans/completed/2026-09-08_maestro-login-pilot.md, maestro/, lib/features/auth/subfeatures/sign_in/presentation/pages/sign_in_page.dart, docs/engineering/harness/mobile_runtime_harness.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h
**Oracle IDs:** auth.journey, runtime.mobile-evidence

Date: 2026-09-08
Related issue/PR: `_WIP/2026-09-06_maestro-device-proof-proposal.md`; depends on `maestro-journey-plumbing`

## Objective

Prove the implementing-agent loop for login: static `task verify`, then
`runtime logs start --mode run`, then `runtime evidence --target
maestro/login.yaml` on a local emulator against the real dev backend, then
`handoff check`.

This is local agent journey proof. It is not hosted CI.

## Constraints

- Architecture constraints: do not widen Dart fake `integration_test`
  stacks. Do not change the CLI wrapper except by failing this task and
  opening a follow-up; plumbing belongs to `maestro-journey-plumbing`.
- Product/runtime constraints: real `.env/dev.yaml` and real
  `google-services.json`. No example-env fallback. No committed
  credentials. Unique per-run identity (register-then-login). Fail closed
  if the local backend or emulator is down. Flavor `dev` only.
- Out of scope: beginning this plan before plumbing completes; treating
  the bootstrap Oracle IDs below as journey proof; Maestro Cloud; CI
  Runtime; MCP `run` as evidence; a second flow; iOS as the pilot
  device; commit/push/draft-PR.

Bootstrap Oracle IDs exist so `oracle verify` stays green *before*
`auth.journey` exists. They are **not** the login journey grader.
`auth.integration` is intentionally omitted so this task cannot be
"proven" by the fake WidgetTester stack.

Before `task begin`:

1. `maestro-journey-plumbing` is completed.
2. Human edits this plan's **Oracle IDs** to
   `auth.journey, runtime.mobile-evidence` (covers auth, ui, platform).
3. That edit is a new authority hash. Then begin.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: yes
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given plumbing is done and this plan selects `auth.journey`, when
   `task verify` passes at fingerprint F, then `runtime evidence --target
   maestro/login.yaml` runs Maestro against the already-started
   `runtime logs --mode run` app.
2. Given a real backend 4xx/5xx or a failed assertion, when the flow
   stops, then the agent can `runtime logs tail`, `task repair`,
   re-verify, and rerun evidence at F'.
3. Given a passing Maestro run, when `handoff check` runs, then
   `auth.journey` is satisfied from `_artifacts/mobile/**/evidence.json`
   bound to F. Raw `maestro test` and MCP runs do not satisfy it.
4. Given the local backend is down, when evidence runs, then it fails
   closed. It does not use `dev.example.yaml` or the CI Firebase fixture.

## Acceptance Criteria

1. This plan is not begun with the bootstrap Oracle IDs.
2. After re-baseline, `auth.journey` plus `runtime.mobile-evidence` cover
   the declared impacts.
3. Local Android emulator + real dev backend + real
   `google-services.json` are used.
4. Bound `evidence.json` records `boundary: runtime.maestro`,
   `target: maestro/login.yaml`, hashed device id, outcome passed.
5. `handoff check --task maestro-login-pilot` is empty of outstanding
   `auth.journey` evidence.
6. YAML and logs contain no committed secrets; durable artifacts stay
   sanitized.
7. `integration_test/auth_happy_path_test.dart` is unchanged.

## Implementation Checklist

- [x] Blocked: do not `task begin` until plumbing is completed.
- [x] Re-baseline Oracle IDs to `auth.journey, runtime.mobile-evidence`.
- [x] Confirm `maestro` on `PATH`, emulator up, `.env/dev.yaml` real,
      backend reachable.
- [x] Adjust `maestro/login.yaml` or sign-in Semantics only if the flow
      cannot see a widget.
- [x] `task verify` at F after harness / `maestro/README.md` edits
      (attempt 2, fingerprint
      `c7a4d58fcb66a800471fdee67a1080f5b630c64175ba81231dffabb057ff8c3b`).
- [x] Skip `runtime logs start --mode run`. Maestro `launchApp` kills
      that `flutter run` session; kit-CLI evidence is the driver.
- [x] `runtime evidence --target maestro/login.yaml` after the doc
      fingerprint (`_artifacts/mobile/20260909_201401`).
- [x] On fail: inspect Maestro debug + API, repair, re-verify, rerun
      evidence. Do not restart `flutter run`.
- [x] `handoff check` with `auth.journey` satisfied.
- [x] No `runtime logs stop` (log session never started).

## Decision Log

- 2026-09-08: Pilot is local emulator only. Not CI, not cloud.
- 2026-09-08: Proof command is `mobilekit runtime evidence`. MCP and raw
  Maestro CLI are iteration.
- 2026-09-08: Bootstrap oracles keep `oracle verify` green while
  `auth.journey` is unregistered. Re-baseline before begin.
- 2026-09-08: Seed default is unique register-then-login, fail closed if
  the backend is down.
- 2026-09-08: Re-baselined Oracle IDs to `auth.journey,
  runtime.mobile-evidence` after plumbing completed. Activated.
- 2026-09-09: Parked to queued. Bound Maestro evidence passed, but
  `handoff check` rejects `summary.md` tagged `transient-local-log`
  (`File ==` is identity). CLI fix is out of this plan's scope;
  follow-up `maestro-evidence-durability`.
- 2026-09-09: Resumed after durability writer fix. `auth.journey`
  handoff clears. `runtime.mobile-evidence` still needs a human
  procedure receipt.
- 2026-09-09: Promoted twice-seen Maestro gaps into
  `docs/engineering/harness/mobile_runtime_harness.md` and `maestro/README.md`.
  Do not pair evidence with `runtime logs --mode run`. App must already
  be installed. YAML: regex anchors, no `hideKeyboard`, profile gate,
  unique register-then-login. `mobilekit_cli_reference.md` and
  `agent_pr_loop.md` still mention the old logs pairing; those paths
  are out of this plan's scope.

## Verification

Do not run these until after the Oracle ID re-baseline and `task begin`.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-login-pilot --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-login-pilot --env dev
dart run mobile_core_kit_cli:mobilekit runtime evidence --task maestro-login-pilot --device <emulator-id> --flavor dev --target maestro/login.yaml
dart run mobile_core_kit_cli:mobilekit handoff check --task maestro-login-pilot
```

## Runtime Evidence

Required. Local Android emulator, flavor `dev`, target
`maestro/login.yaml`, real backend. Record artifact path, fingerprint,
hashed device id, and outcome in Completion Notes after the run.
Hosted `CI Runtime` is not this evidence.

## Rollback

Stop the log session. Leave the emulator and user-installed Maestro CLI.
Revert any sign-in Semantics or YAML edits. Do not delete plumbing from
the prior task.

## Risks And Mitigations

- Risk: event intake activates this plan before plumbing. Mitigation:
  first checklist item is a hard block; filenames sort plumbing first;
  current active V2 already blocks intake.
- Risk: backend/emulator flake. Mitigation: fail closed, unique emails,
  repair budget 2, do not fake-pass with `auth.integration`.
- Risk: YAML cannot see widgets. Mitigation: allowed path includes
  sign-in page for Semantics only.

## Completion Notes

Local login journey proved 2026-09-09. Bound evidence
`_artifacts/mobile/20260909_201401/evidence.json`: `outcome: passed`,
`boundary: runtime.maestro`, `target: maestro/login.yaml`,
fingerprint
`c7a4d58fcb66a800471fdee67a1080f5b630c64175ba81231dffabb057ff8c3b`.
`handoff check` has no outstanding `auth.journey`. Source landed in
`8086ff6` (durability) and `d2650c4` (YAML/docs).

`runtime.mobile-evidence` still needs a human procedure receipt. That
is not this task's Maestro proof.

## Follow-ups

Human procedure receipt for `runtime.mobile-evidence`.
iOS simulator stays out.
Register journey is a separate plan (`maestro-register-pilot`).
`mobilekit_cli_reference.md` and `agent_pr_loop.md` still mention
pairing evidence with `runtime logs --mode run`; out of this plan's
scope.
