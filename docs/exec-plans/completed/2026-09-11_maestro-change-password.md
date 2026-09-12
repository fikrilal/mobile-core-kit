# Maestro Journey — Change Password

**Plan version:** 2
**Task ID:** maestro-change-password
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Run the local Maestro journey for `maestro/change_password.yaml` on a local Android emulator against the real dev backend. Bind kit-CLI evidence with `runtime evidence --task maestro-change-password`. No commit, push, or draft-PR. No CI, Maestro Cloud, or MCP-as-proof.
**Allowed paths:** docs/exec-plans/queued/2026-09-11_maestro-change-password.md, docs/exec-plans/active/2026-09-11_maestro-change-password.md, docs/exec-plans/completed/2026-09-11_maestro-change-password.md, maestro/, harness/oracles.yaml, docs/engineering/mobile_runtime_harness.md, lib/features/auth/subfeatures/credential_management/presentation/pages/change_password_page.dart, lib/features/account/subfeatures/security/presentation/pages/security_privacy_page.dart, lib/features/account/presentation/pages/account_page.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h
**Oracle IDs:** auth.change-password-journey, runtime.mobile-evidence

Date: 2026-09-11
Related issue/PR: `_WIP/2026-09-06_maestro-device-proof-proposal.md`;
`maestro/README.md`

## Objective

Prove register-to-Home → Profile → Security and privacy → Change password → Password updated. Current password is `MAESTRO_TEST_PASSWORD`; new is `MAESTRO_TEST_NEW_PASSWORD` (min 10).

## Constraints

- Architecture constraints: do not add a `mobilekit maestro` command.
  Reuse `maestro/README.md` selectors. Iterate with
  `runtime evidence --device … --target maestro/change_password.yaml` (no `--task`). Prove
  with `--task maestro-change-password`.
- Product/runtime constraints: flavor `dev`, real `.env/dev.yaml`,
  package already installed. Unique `MAESTRO_TEST_EMAIL` /
  `MAESTRO_TEST_PASSWORD` (minLength 10). Fail closed if backend or
  emulator is down.
- Out of scope: beginning while `runtime-evidence-iterate` is the
  active V2; Maestro Cloud; CI Runtime; Google sign-in; email-token
  confirm; account deletion; commit/push/draft-PR.
- Multiple password fields; dismiss IME via the app-bar title. Never `hideKeyboard`.
- Export `MAESTRO_TEST_NEW_PASSWORD` in the evidence shell.

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
   `runtime evidence --task maestro-change-password --target maestro/change_password.yaml` passes, then
   `handoff check` has no outstanding `auth.change-password-journey`.
3. Given the backend or package is missing, when evidence runs, then
   it fails closed.

## Acceptance Criteria

1. `maestro/change_password.yaml` is a real `auth.change-password-journey` target, not a dummy.
2. Bound `evidence.json` records `boundary: runtime.maestro`,
   `target: maestro/change_password.yaml`, outcome passed, `durable-summary` on summary.md.
3. `handoff check --task maestro-change-password` is empty of outstanding `auth.change-password-journey`.
4. YAML and logs contain no committed secrets.

## Implementation Checklist

- [x] Blocked: do not `task begin` while `runtime-evidence-iterate`
      is the active V2.
- [x] Register `auth.change-password-journey` and add `maestro/change_password.yaml` so `oracle verify` accepts
      this queued plan.
- [x] Activate this plan (one active V2).
- [x] `task begin --plan docs/exec-plans/active/2026-09-11_maestro-change-password.md`.
- [x] Iterate YAML on the real screens (`runtime evidence` without
      `--task`).
- [x] `task verify --task maestro-change-password --env dev`.
- [x] `runtime evidence --task maestro-change-password --device emulator-5554
      --flavor dev --target maestro/change_password.yaml`.
- [x] `handoff check` with `auth.change-password-journey` satisfied.

## Decision Log

- 2026-09-11: One flow = one plan. Oracle pre-registered so queued
  verify stays green.

## Verification

Do not run until after `task begin`.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-change-password --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-change-password --env dev
dart run mobile_core_kit_cli:mobilekit runtime evidence --task maestro-change-password --device emulator-5554 --flavor dev --target maestro/change_password.yaml
dart run mobile_core_kit_cli:mobilekit handoff check --task maestro-change-password
```

## Runtime Evidence

Required. Local Android emulator, flavor `dev`, target `maestro/change_password.yaml`.

## Rollback

Revert `maestro/change_password.yaml` and this plan. Leave other journey YAMLs.

## Risks And Mitigations

- Risk: selector regex / IME / ANR. Mitigation: `maestro/README.md`;
  iterate without `--task`; headless emulator ANR is a device issue.
- Risk: reused identity skips profile. Mitigation: unique email per run.

## Completion Notes

Bound evidence `_artifacts/mobile/20260912_105036/evidence.json` passed. `handoff check` has no outstanding `auth.change-password-journey`.

## Follow-ups

`runtime.mobile-evidence` still needs a human procedure receipt.
Do not forge it.
