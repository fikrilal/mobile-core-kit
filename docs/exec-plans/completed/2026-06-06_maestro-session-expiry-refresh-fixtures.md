# Maestro: Session Expiry And Refresh Through Fixtures

Date: 2026-06-06
Owner: unassigned agent
Status: completed
Risk class: high
Related issue/PR: N/A

## Objective

Add one compiled-app journey proving that an authenticated session whose access
token is rejected transparently refreshes through a run-scoped fault fixture
and remains authenticated while loading protected data.

## Dependencies

- `2026-06-06_maestro-login-logout-resettable-identity.md`.

## Constraints

- Do not use wall-clock waiting for token expiry.
- Do not alter production token lifetimes or add test behavior to production
  endpoints.
- Fixture control must remain outside the app and backend production processes
  and be scoped to one local evidence run.
- Refresh-token rejection and forced logout are a separate follow-up unless the
  backend contract supports both states without expanding this flow.

## Fixture Contract

- Proxy only the run-scoped dev build.
- Reject exactly one authenticated `GET /v1/me/sessions`.
- Keep the real backend refresh token and `/v1/auth/refresh` path untouched.
- Expose a protected request whose successful result is visible in the UI.
- Report the injected `401`, refresh count, replay, and JWT session ID without
  writing token values.
- Revoke the session during cleanup.

## Why Lower Layers Are Insufficient

Session manager and API tests prove refresh logic with controlled responses.
They do not prove persisted real tokens, an actual 401/refresh exchange,
request replay, user-context continuity, and rendered protected data together.

## Acceptance Criteria

1. The test logs in and identifies its JWT session safely.
2. The fixture rejects its access token once without invalidating refresh.
3. A protected UI action succeeds without returning to sign in.
4. Evidence confirms one refresh occurred without exposing token values.
5. Cleanup revokes all fixture sessions.

## Implementation Checklist

- [x] Keep fixture control in a run-scoped local proxy; no backend route or
      mobile storage backdoor.
- [x] Select active sessions as the protected UI request and assertion target.
- [x] Add deterministic proxy contract coverage.
- [x] Add `.maestro/flows/session/session_expiry_refresh.yaml` tagged
  `requires_backend`.
- [x] Run compiled-app evidence and confirm one refresh/replay cycle.
- [x] Scan all evidence for access/refresh token material.

## Verification

```bash
dart run tool/verify.dart --env dev
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device <api-34-device> \
  --flavor dev \
  --flow .maestro/flows/session/session_expiry_refresh.yaml
```

## Risks And Mitigations

- Risk: fixture controls become a security backdoor.
- Mitigation: backend-owned non-production control plane with authentication,
  environment guards, and auditability.
- Risk: hidden automatic retries mask refresh defects.
- Mitigation: no suite-level retries; assert one controlled transition.

## Handoff Notes

The original backend-control proposal would add production auth-path complexity
for a local harness requirement. The implemented fixture is a local reverse
proxy that returns one controlled `401`; it exercises the real refresh endpoint,
token rotation, request replay, session persistence, and protected UI result.
It does not claim to test backend JWT expiration validation itself.

Completed evidence:

- `_artifacts/mobile/mobtrace-session-refresh-20260610_080028`
- fixture state: one injected `401`, one refresh, one successful replay
- unrelated push-token `PUT` forwarded with `204`
- no JWT-like strings or token fields found in generated text artifacts
