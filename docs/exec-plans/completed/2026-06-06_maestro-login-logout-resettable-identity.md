# Maestro: Login And Logout With Resettable Identity

Date: 2026-06-06
Owner: unassigned agent
Status: completed
Risk class: high
Related issue/PR: N/A

## Objective

Add one compiled-app Maestro journey that signs in with a dedicated test
identity, proves authenticated UI, logs out, and proves the signed-out state.
Establish the resettable identity contract reused by later authenticated flows.

## Fixture Contract

Use a generated identity unique to each run. Provision it directly through the
backend password-registration endpoint, complete the required profile through
`PATCH /v1/me`, and pass the generated credentials through shell variables
prefixed with `MAESTRO_`. Maestro CLI reads that prefix without requiring `-e`,
so credentials do not appear in process arguments or `command.txt`.

Cleanup must run from a shell trap after success, assertion failure, or signal:

- authenticate a cleanup session for the run-scoped identity;
- list sessions with `GET /v1/me/sessions`;
- revoke every other session with `POST /v1/me/sessions/{sessionId}/revoke`;
- finish with `POST /v1/auth/logout` for the cleanup refresh token;
- fail the overall run if setup or cleanup postconditions cannot be proven.

The backend currently has no account-deletion fixture endpoint, so cleanup
leaves an inert synthetic account with no active session. That is acceptable
for this first flow only if each run uses a unique address and all sessions are
verified revoked. `launchApp.clearState` remains local cleanup only.

Use the Medium Phone emulator for this authenticated journey. Its API 35 image
is secondary runtime evidence; it does not replace the documented API 34
baseline used by baseline-sensitive flows.

## Review Outcome

The first implementation was rejected and removed because it:

- registered/logged in through assumed endpoints without a verified reset API;
- treated backend connection and profile-reset failures as warnings;
- accumulated backend sessions instead of revoking them;
- passed credentials in Maestro CLI arguments and relied on post-run redaction;
- did not test cleanup after intentional failure;
- expanded multiple design-system APIs for selectors not used by the final flow;
- claimed completion despite violating acceptance criteria 4 and 5.

## Why Lower Layers Are Insufficient

Unit and integration tests use fake repositories and in-memory sessions. They
do not prove real form entry, backend authentication, secure token persistence,
authenticated navigation, remote logout, and local session clearing together.

## Acceptance Criteria

1. Preflight creates a unique run-scoped identity and closes its setup session.
2. The flow signs in through rendered UI and reaches authenticated UI.
3. Logout returns to sign in and a protected route is inaccessible.
4. Cleanup restores the fixture after success and intentional failure.
5. No reusable credential or token value appears in process arguments or text artifacts.

## Implementation Checklist

- [x] Verify the required public backend endpoints.
- [x] Select shell `MAESTRO_` variables instead of CLI `-e` credentials.
- [x] Implement run-scoped registration and profile completion with hard-fail setup.
- [x] Add setup and cleanup traps with hard failure on unmet postconditions.
- [x] Inspect the compiled accessibility tree before adding identifiers.
- [x] Reuse existing accessibility labels without application code changes.
- [x] Add `.maestro/flows/auth/login_logout.yaml` with `requires_backend`.
- [x] Prove passing and assertion-failure cleanup.
- [x] Scan process invocation and all retained text artifacts for secrets/tokens.

## Verification

```bash
dart run tool/verify.dart --env dev
tool/agent/auth_fixture_evidence_check.sh \
  --flow .maestro/flows/auth/login_logout.yaml \
  --device <medium-phone-device> \
  --flavor dev \
  --app-file build/app/outputs/flutter-apk/app-dev-debug.apk \
  --skip-build
```

Passing evidence: `_artifacts/mobile/review-login-logout-medium/` on Medium
Phone, Android API 35. JUnit duration: 37 seconds. Wrapper duration: 56 seconds.
The post-run backend query reported zero active `maestro-login-*` sessions.

## Handoff Notes

Reuse `tool/agent/auth_fixture_evidence_check.sh` as the fixture owner for later
authenticated flows. `tool/agent/login_logout_evidence_check.sh` remains a thin
compatibility wrapper over the generic fixture command. Do not duplicate
registration, cleanup, or secret-redaction logic per flow.
