# Maestro Journey — Logout

**Plan version:** 2
**Task ID:** maestro-logout
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Run the local Maestro journey for `maestro/logout.yaml` on a local Android emulator against the real dev backend. Bind kit-CLI evidence with `runtime evidence --task maestro-logout`. No commit, push, or draft-PR. No CI, Maestro Cloud, or MCP-as-proof.
**Allowed paths:** docs/exec-plans/queued/2026-09-11_maestro-logout.md, docs/exec-plans/active/2026-09-11_maestro-logout.md, docs/exec-plans/completed/2026-09-11_maestro-logout.md, maestro/, harness/oracles.yaml, docs/engineering/mobile_runtime_harness.md, lib/features/account/presentation/pages/account_page.dart, lib/navigation/shell/app_shell_page.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h
**Oracle IDs:** auth.logout-journey, runtime.mobile-evidence

Date: 2026-09-11
Related issue/PR: `_WIP/2026-09-06_maestro-device-proof-proposal.md`;
`maestro/README.md`

## Objective

Prove register-to-Home → Profile → Log out (confirm dialog) → Sign In.

## Constraints

- Architecture constraints: do not add a `mobilekit maestro` command.
  Reuse `maestro/README.md` selectors. Iterate with
  `runtime evidence --device … --target maestro/logout.yaml` (no `--task`). Prove
  with `--task maestro-logout`.
- Product/runtime constraints: flavor `dev`, real `.env/dev.yaml`,
  package already installed. Unique `MAESTRO_TEST_EMAIL` /
  `MAESTRO_TEST_PASSWORD` (minLength 10). Fail closed if backend or
  emulator is down.
- Out of scope: beginning while `runtime-evidence-iterate` is the
  active V2; Maestro Cloud; CI Runtime; Google sign-in; email-token
  confirm; account deletion; commit/push/draft-PR.
- Two "Log out" texts (tile then dialog confirm). YAML uses index 1 for the dialog confirm.

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

1. Given a unique unused identity, when the YAML finishes, then the
   flow asserts its success screen on the emulator.
2. Given `task verify` at fingerprint F, when
   `runtime evidence --task maestro-logout --target maestro/logout.yaml` passes, then
   `handoff check` has no outstanding `auth.logout-journey`.
3. Given the backend or package is missing, when evidence runs, then
   it fails closed.

## Acceptance Criteria

1. `maestro/logout.yaml` is a real `auth.logout-journey` target, not a dummy.
2. Bound `evidence.json` records `boundary: runtime.maestro`,
   `target: maestro/logout.yaml`, outcome passed, `durable-summary` on summary.md.
3. `handoff check --task maestro-logout` is empty of outstanding `auth.logout-journey`.
4. YAML and logs contain no committed secrets.

## Implementation Checklist

- [x] Blocked: do not `task begin` while `runtime-evidence-iterate`
      is the active V2.
- [x] Register `auth.logout-journey` and add `maestro/logout.yaml` so `oracle verify` accepts
      this queued plan.
- [x] Activate this plan (one active V2).
- [x] `task begin --plan docs/exec-plans/active/2026-09-11_maestro-logout.md`.
- [x] Iterate YAML on the real screens (`runtime evidence` without
      `--task`).
- [x] `task verify --task maestro-logout --env dev`.
- [x] `runtime evidence --task maestro-logout --device emulator-5554
      --flavor dev --target maestro/logout.yaml`.
- [x] `handoff check` with `auth.logout-journey` satisfied.

## Decision Log

- 2026-09-11: One flow = one plan. Oracle pre-registered so queued
  verify stays green.

## Verification

Do not run until after `task begin`.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-logout --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-logout --env dev
dart run mobile_core_kit_cli:mobilekit runtime evidence --task maestro-logout --device emulator-5554 --flavor dev --target maestro/logout.yaml
dart run mobile_core_kit_cli:mobilekit handoff check --task maestro-logout
```

## Runtime Evidence

Required. Local Android emulator, flavor `dev`, target `maestro/logout.yaml`.

## Rollback

Revert `maestro/logout.yaml` and this plan. Leave other journey YAMLs.

## Risks And Mitigations

- Risk: selector regex / IME / ANR. Mitigation: `maestro/README.md`;
  iterate without `--task`; headless emulator ANR is a device issue.
- Risk: reused identity skips profile. Mitigation: unique email per run.

## Completion Notes

Bound evidence `_artifacts/mobile/20260912_104413/evidence.json` passed. `handoff check` has no outstanding `auth.logout-journey`.

## Follow-ups

`runtime.mobile-evidence` still needs a human procedure receipt.
Do not forge it.
