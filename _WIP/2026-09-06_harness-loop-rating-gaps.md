# Harness & Loop Engineering Assessment — 2026-09-06

Rating: **8/10** — unusually strong on design, weaker on proven maturity.

Updated 2026-09-08: gap 4 + fix 4 corrected against
`_WIP/2026-09-06_maestro-device-proof-proposal.md`. Maestro is proposed,
not shipped. Rating unchanged.

## What this covers
- `harness/oracles.yaml`, `harness/evidence_calibration.json`
- `packages/mobile_core_kit_cli/lib/src/task|verification|oracle|runtime|handoff|events|maintenance|ci|evidence|improvement/`
- `docs/engineering/task_authority.md`, `controlled_verification_loop.md`, `mobile_runtime_harness.md`, `event_maintenance_handoff.md`, `behavioral_oracles.md`, `agent_pr_loop.md`, `harness_operating_evidence.md`
- Related proposal: `_WIP/2026-09-06_maestro-device-proof-proposal.md` (decision input, not authority)
- Active V2 plan: `docs/exec-plans/active/2026-09-08_harness-evidence-push.md`
- State root: `.tmp/mobilekit/` (ignored, local-only)

## Strengths
- Real outer-loop controls: V2 authority hash, fail-closed preflight, fingerprint-locked verify.
- Finite repair budget with explicit `failed -> authorized -> verified | escalated` transitions.
- Oracle registry covering impacts; medium/high must declare `Oracle IDs`.
- Sanitized evidence (hashed device IDs, capped episodes, redacted secrets).
- Handoff challenge (64-hex, 15-min expiry) + separate `MOBILEKIT_HANDOFF_APPROVAL` per action.
- Hosted CI (`required.yml`) never trusts `.tmp` — independent check.

## Gaps in detail

### 1. Learning loop is unproven
- `docs/engineering/harness_operating_evidence.json` is empty (`records: []`).
- Eligibility `0/5` → `improve analyze|shadow` is `disabled`.
- Trend → hypothesis → shadow-evaluate path has never run on real data.

### 2. Ephemeral local state
- All task state in ignored `.tmp/mobilekit/tasks/<id>/state.json + episode.json`.
- Lose dir, compact mid-task, or switch worktrees → `ambiguous verifying` → `escalated`.
- Local `verified` and hosted `CI Required` can diverge by design.

### 3. Single active V2 bottleneck
- Only one `docs/exec-plans/active/*.md` allowed.
- Serializes harness work; `event intake --once` fails closed if anything else active.
- No priority, preemption, or queueing.

### 4. Runtime evidence is thin (fake-stack, not independent)
- Single-flight device, `flutter test -d <device>` per target.
- Only 2 integration oracles registered (`auth.integration`, `startup.integration`).
- Those oracles prove widget wiring with fakes (`_FakeAuthRepository`, in-memory session, marker HOME), not a real backend journey.
- `CI Runtime` reproduces the same fakes: `.env/dev.example.yaml` + `harness/fixtures/google-services.ci.json`. `_artifacts/*` is gitignored, so local `evidence.json` never is hosted proof.
- Logs transient-ignored, 1MiB cap, hashed IDs — good hygiene, poor flaky-device debugging.
- Rest falls back to `human:<id>` manual receipts.
- Do **not** close this by adding more `integration_test` oracles. That grows Dart fake-stacks and still is not independent behavior proof.
- Maestro proposal (`_WIP/2026-09-06_maestro-device-proof-proposal.md`) is the intended close for **local agent journey proof**: unit/static `task verify`, then Maestro on a local emulator against the real dev backend, logs via existing `runtime logs`. Not CI. Not cloud.
- That closes fake vs real for the implementing agent. It does **not** close hosted independence (`CI Runtime` still runs fakes; `_artifacts/` still gitignored). That is an accepted non-goal. Remaining local conditions: oracle + flow in the V2 plan before `task begin`; kit CLI run is the only completion evidence; raw Maestro / MCP is iteration only.

### 5. Manual attestation is weak
- `.tmp/.../manual-evidence.json` is self-asserted `outcome: passed` + artifact hash.
- `reviewer: human:<id>` is attestation, not auth; no independent check procedure was followed.

### 6. Coarse risk + low bar
- `risk_classifier.dart` is path-prefix based: `lib/|test/` → medium, unknown → medium, `docs/` → low.
- Over-escalates refactors, under-catches logic bugs.
- Coverage floor 55%, observed 62.78% — low for auth/session/high-risk code.

### 7. Slow + high friction
- Calibrated `fast: 65s / full: 125s`, advisory 120s/240s.
- `preflight` before every `edit|verify|commit|push|draft-pr`, exact fingerprint match everywhere.
- 15-min handoff challenge, separate approval per action. Safe but heavy for low-risk iterations.

### 8. Sanitization vs debuggability
- Episode ≤100 events, diagnostics 40 lines / 4096 chars, strips tokens/emails/env/transcripts.
- Loses exact context needed on `verification.unknown` or `infrastructure.unavailable`.

### 9. Docs drift risk
- ~12 normative docs in `docs/engineering/` + `oracles.yaml` + `evidence_calibration.json` + `COVERAGE_MIN`.
- Behavior lives partly in prose; can drift from `task_controller | handoff_service | runtime_workflow` code.
- `project-map verify` and `knowledge verify` mitigate, not eliminate.

## Highest-leverage fixes
1. Seed 5+ real operating-evidence records to enable `improve analyze`.
2. Back up / recover `.tmp/mobilekit` state or make `verifying` resumable.
3. Allow queued priority or parallel low-risk tasks.
4. Ship Maestro as local agent journey proof (emulator + real backend + existing `runtime logs`). Do not add more fake `integration_test` oracles. Do not put Maestro in CI or cloud.
5. Require second reviewer or CI check for manual-evidence oracles.
6. Raise coverage floor for `auth|session|database` paths; refine classifier beyond prefixes.
