# Maestro Journey Proof — Register Pilot

**Plan version:** 2
**Task ID:** maestro-register-pilot
**Status:** completed
**Owner:** fikrilal
**Risk:** high
**Authority:** Run the local agent journey loop for email/password registration on a local Android emulator against the real dev backend. Bind Maestro evidence via `mobilekit runtime evidence` for `maestro/register.yaml`. No commit, push, or draft-PR. No CI, Maestro Cloud, or MCP-as-proof.
**Allowed paths:** docs/exec-plans/queued/2026-09-09_maestro-register-pilot.md, docs/exec-plans/active/2026-09-09_maestro-register-pilot.md, docs/exec-plans/completed/2026-09-09_maestro-register-pilot.md, maestro/, harness/oracles.yaml, lib/features/auth/subfeatures/registration/presentation/pages/register_page.dart, docs/engineering/mobile_runtime_harness.md
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 6h
**Oracle IDs:** harness.full, auth.register-journey, runtime.mobile-evidence

Date: 2026-09-09
Related issue/PR: `_WIP/2026-09-06_maestro-device-proof-proposal.md`;
depends on `maestro-login-pilot`

## Objective

Prove the implementing-agent loop for **create account**: static
`task verify`, then `runtime evidence --target maestro/register.yaml`
on a local emulator against the real dev backend, then `handoff check`
with `auth.register-journey` satisfied.

This is local agent journey proof. It is not hosted CI. It is not the
login-pilot curl-then-login seed.

## Constraints

- Architecture constraints: do not widen Dart fake `integration_test`
  stacks. Do not add a `mobilekit maestro` command. Reuse
  `maestro/README.md` selectors.
- Product/runtime constraints: real `.env/dev.yaml` and real
  `google-services.json`. Flavor `dev` only. Unique email typed in the
  register form (`MAESTRO_TEST_EMAIL` / `MAESTRO_TEST_PASSWORD`,
  password minLength 10). Do not curl-register first. Fail closed if
  the local backend or emulator is down. App package must already be
  installed.
- Out of scope: beginning while `maestro-login-pilot` is still the
  active V2; treating `auth.journey` (login.yaml) as this proof;
  Maestro Cloud; CI Runtime; MCP `run` as evidence; iOS; Google sign-in;
  password-reset; commit/push/draft-PR.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: yes
- UI/UX/accessibility: yes
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given this plan is active and `auth.register-journey` is registered,
   when `task verify` passes at fingerprint F, then
   `runtime evidence --target maestro/register.yaml` runs Maestro
   against the installed `dev` APK.
2. Given a unique unused email, when the flow finishes, then it asserts
   Home after complete-profile (fresh `givenName` is empty).
3. Given a passing Maestro run, when `handoff check` runs, then
   `auth.register-journey` is satisfied from
   `_artifacts/mobile/**/evidence.json` bound to F. Raw `maestro test`
   does not satisfy it.
4. Given the local backend is down or the package is missing, when
   evidence runs, then it fails closed.

## Acceptance Criteria

1. `harness/oracles.yaml` registers `auth.register-journey`
   (`maestro-flow`, `maestro/register.yaml`, covers auth, ui).
2. After begin, `harness.full` plus `auth.register-journey` plus
   `runtime.mobile-evidence` cover the declared impacts.
3. Local Android emulator + real dev backend + real
   `google-services.json` are used.
4. Bound `evidence.json` records `boundary: runtime.maestro`,
   `target: maestro/register.yaml`, hashed device id, outcome passed.
5. `handoff check --task maestro-register-pilot` is empty of outstanding
   `auth.register-journey` evidence.
6. YAML and logs contain no committed secrets.
7. `maestro/login.yaml` and `integration_test/auth_happy_path_test.dart`
   stay unchanged unless a shared selector comment requires it.

## Implementation Checklist

- [x] Blocked: do not `task begin` until `maestro-login-pilot` is
      completed (one active V2).
- [x] Register `auth.register-journey` and add `maestro/register.yaml`
      so `oracle verify` accepts this queued plan.
- [x] Activate this plan (status active, move to `active/`).
- [x] `task begin --plan docs/exec-plans/active/2026-09-09_maestro-register-pilot.md`.
- [x] Iterate YAML against the real register screen (`Create one`,
      `Create a new account`). Do not use `hideKeyboard`.
- [x] `task verify --task maestro-register-pilot --env dev`.
- [x] Unique env creds, then `runtime evidence --target maestro/register.yaml`.
- [x] `handoff check` with `auth.register-journey` satisfied.

## Decision Log

- 2026-09-09: Second flow is in-app register, not curl-then-login.
- 2026-09-09: New oracle ID (one oracle, one target). Do not overload
  `auth.journey`.
- 2026-09-09: Oracle + YAML stubbed as real flow before queue so
  `oracle verify` stays green. Login-pilot closed first.
- 2026-09-09: `harness.full` is selected because this plan owns
  `harness/oracles.yaml`. `runtime.mobile-evidence` remains a human
  procedure receipt.
- 2026-09-09: `tapOn: "Create one"` fails. Maestro `text` is a
  full-string regex. Use `.*Create one`. Raw `maestro test` reached
  Home.

## Verification

Do not run these until after `task begin`.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task maestro-register-pilot --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task maestro-register-pilot --env dev
dart run mobile_core_kit_cli:mobilekit runtime evidence --task maestro-register-pilot --device emulator-5554 --flavor dev --target maestro/register.yaml
dart run mobile_core_kit_cli:mobilekit handoff check --task maestro-register-pilot
```

## Runtime Evidence

Required. Local Android emulator, flavor `dev`, target
`maestro/register.yaml`, real backend. Unique in-form identity.
Hosted `CI Runtime` is not this evidence.

## Rollback

Revert `maestro/register.yaml`, the `auth.register-journey` oracle row,
and README/register-page edits. Leave login-pilot completed.

## Risks And Mitigations

- Risk: `Create one` misses the CTA (curly apostrophe in
  `Don’t have an account?`). Mitigation: match the unique substring
  `Create one`; allowed path includes register page for Semantics.
- Risk: reused email / AUTH_EMAIL_ALREADY_EXISTS. Mitigation: unique
  `MAESTRO_TEST_EMAIL` per run; do not curl-register first.
- Risk: same IME / regex traps as login. Mitigation: copy login.yaml
  selector rules; `maestro/README.md`.

## Completion Notes

Register journey proved 2026-09-09. Bound evidence
`_artifacts/mobile/20260909_204241/evidence.json`: `outcome: passed`,
`boundary: runtime.maestro`, `target: maestro/register.yaml`.
`handoff check` has no outstanding `auth.register-journey`.
`runtime.mobile-evidence` still needs a human procedure receipt.

## Follow-ups

Human procedure receipt for `runtime.mobile-evidence`.
CLI iterate-without-`--task` and dropping `runtime logs` is
`runtime-evidence-iterate`.
