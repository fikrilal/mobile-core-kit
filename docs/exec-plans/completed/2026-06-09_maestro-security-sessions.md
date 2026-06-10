# Maestro: Security And Active Sessions

Date: 2026-06-09
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A

## Objective

Add one fixture-backed compiled-app journey that logs in, navigates through
Security and privacy, proves the current backend session is rendered, and
returns without mutating account state.

## Constraints

- Use the Medium Phone authenticated evidence baseline.
- Use the existing run-scoped identity and session cleanup.
- Do not revoke sessions or change account settings.
- Keep selectors tied to visible accessibility text unless ambiguity requires
  a semantic identifier.

## Acceptance Criteria

1. The flow logs in with a generated identity.
2. Security and privacy opens from the normal Profile UI.
3. Active sessions loads from the backend and renders `This device`.
4. Back navigation returns to Security and privacy.
5. MobTrace runs the journey through `verify security-sessions`.

## Verification

```bash
./mobtrace verify security-sessions \
  --device emulator-5554 \
  --flavor dev
```

## Progress

- [x] Inspect the existing navigation and session UI.
- [x] Add flow metadata and the fixture-backed convenience runner.
- [x] Add the named MobTrace target and CLI contract coverage.
- [x] Prove the flow on Medium Phone and record the artifact path.

## Evidence

- Device: Medium Phone, Android API 35, `emulator-5554`
- Result: passed in 34 seconds
- Artifacts:
  `_artifacts/mobile/dogfood-security-sessions-20260609-run2`
