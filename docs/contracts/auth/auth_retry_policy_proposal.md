# Proposal: Auth Refresh + Retry Policy (Mobile Core Kit)

This document proposes a production-grade policy for:

- when the mobile client refreshes tokens
- when it retries requests after a refresh
- how it handles refresh failures (especially with rotating refresh tokens)

This is intended to be shared with backend engineers and used to align on safe,
predictable semantics.

Related background: `docs/contracts/auth/auth_refresh_and_retry_contract.md:1`.

Status (mobile-core-kit): implemented the core policy (single-flight refresh,
401 refresh+retry for reads by default (writes require `Idempotency-Key`),
refresh fail-closed on unknown outcome). The remaining open item is a more
explicit “replayability” signal beyond `allowAuthRetry` when dealing with
streaming uploads.

---

## Backend Constraints (confirmed)

1) **401 implies no side effects (for protected routes)**
- Auth/authorization is enforced in Nest guards before the controller handler runs.
- A `401`/`403` happens pre-handler, so no mutation code executes.

2) **401 vs 403**
- `401` = missing/invalid/expired access token → code: `UNAUTHORIZED`
- `403` = token valid but lacks permission → code: `FORBIDDEN`

3) **Refresh token rotation**
- Refresh tokens rotate **only on a successful `200` refresh**.
- The refresh response includes the **new refresh token**.
- Invalid/expired/reused/revoked refresh tokens return `401` with stable codes:
  - `AUTH_REFRESH_TOKEN_INVALID`
  - `AUTH_REFRESH_TOKEN_EXPIRED`
  - `AUTH_REFRESH_TOKEN_REUSED`
  - `AUTH_SESSION_REVOKED`

4) **Strict refresh token reuse detection**
- Re-sending the same refresh token after a successful refresh can revoke the session.
- Therefore, the client must treat refresh as **at-most-once** and must not auto-retry refresh when the outcome is unknown (timeout/no response).

---

## Goals

- Make “access token expired” invisible to users, including form submits.
- Prevent accidental session revocation caused by refresh-token reuse.
- Keep behavior safe-by-default and easy to reason about in production.

## Non-goals (for this proposal)

- General network retries for timeouts/5xx for write endpoints (needs idempotency keys).
- Background refresh scheduling outside request flow.

---

## Proposed Policy

### A) Single-flight refresh (MUST)

- Only one refresh request can be in-flight per process.
- All requests that need a refresh await the same in-flight refresh result.

Rationale: prevents concurrency races and refresh-token reuse.

### B) Preflight refresh (SHOULD)

Before sending an authenticated request:

- If the access token is “expiring soon” (client-computed `expiresAt` with leeway),
  attempt a refresh first, then attach the new access token.

Rationale: avoids many avoidable 401s and improves UX.

### C) 401 refresh + retry (MUST for protected requests)

For any request with `requiresAuth=true` that receives a `401`:

1) Attempt refresh (single-flight).
2) If refresh succeeds, **retry the original request once** with the new access token.
3) Set a guard flag (e.g. `retried=true`) to ensure no infinite loops.

Important: backend-core-kit recommends treating write retries as safe only when
protected by an `Idempotency-Key`. In mobile-core-kit, reads retry after refresh
by default; writes retry after refresh only when `Idempotency-Key` is present.

### D) 403 behavior (MUST NOT refresh/retry)

For `403 FORBIDDEN`:

- Do not refresh.
- Do not retry.
- Surface permission failure to the caller/UI.

### E) Refresh failure classification (MUST)

When refresh fails:

1) **Session-invalidating refresh failures (logout immediately)**
- If refresh returns `401` with:
  - `AUTH_REFRESH_TOKEN_INVALID`
  - `AUTH_REFRESH_TOKEN_EXPIRED`
  - `AUTH_REFRESH_TOKEN_REUSED`
  - `AUTH_SESSION_REVOKED`
- Then:
  - clear local session
  - redirect user to sign-in

2) **Unknown-outcome refresh failures (fail closed)**
- If refresh fails due to timeout/no response/connection drop (i.e., we cannot prove the server did not return `200`):
  - clear local session
  - redirect user to sign-in
  - do **not** auto-retry refresh

Rationale: if the server actually returned `200` and rotated the refresh token,
retrying refresh with the old token risks reuse detection and session revocation.

3) **Non-200, known outcome refresh failures (retry allowed)**
- If the client receives a non-200 response where we can prove the refresh did not succeed (e.g. `429`, `5xx`):
  - refresh token did not rotate (backend-confirmed rotation is only on 200)
  - the client may retry refresh later (with backoff), but must still keep single-flight and never do rapid repeated refresh attempts

Note: even if we allow “retry later”, the immediate request that triggered refresh should fail deterministically (no hidden loops).

### F) Replayability guard (SHOULD)

Retrying a request requires that the request is replayable:

- JSON bodies and standard form submits are replayable.
- Streaming bodies/uploads may not be replayable.

Policy:

- Default behavior: allow retry-after-refresh for typical JSON requests.
- Allow explicit per-request override flags:
  - `allowAuthRetry` (force on/off)
  - `isReplayableBody` (or similar)

---

## Error and UX outcomes

- If access token expired:
  - request gets refreshed and replayed automatically once
  - user sees no error and the form submission succeeds
- If refresh token invalid/expired/reused/revoked:
  - user is logged out and redirected to sign-in with a clear “session expired” message
- If refresh outcome unknown (timeout/no response):
  - user is logged out (fail closed) to avoid reuse revocation

---

## Why idempotency keys still matter

The backend guarantee makes “retry-after-refresh on 401” safe because 401 implies no side effects.

However, it does not make retries safe for:

- request timeouts (server might have committed the write but response was lost)
- client crashes after send
- intermediate proxy errors

If we later want safe retries for write requests beyond the 401 case, we should add:

- `Idempotency-Key` support for write endpoints, with a well-defined TTL and scope.

---

## Proposed Implementation Plan (mobile)

1) **Update auth error code mapping**
- Add `AUTH_REFRESH_TOKEN_INVALID/EXPIRED/REUSED` and `AUTH_SESSION_REVOKED`.
- Ensure these map to a domain failure that triggers local logout.

2) **Update AuthTokenInterceptor retry policy**
- Expand 401 refresh+retry to all methods for `requiresAuth=true`.
- Keep the `retried=true` guard to prevent loops.
- Keep single-flight refresh.

3) **Define “unknown outcome refresh”**
- Detect timeouts/no response and treat as fail-closed logout.
- Add a small unit test suite around refresh classification and retry gating.

4) **Add a replayability override**
- Ensure non-replayable requests can opt out of retry-after-refresh.

---

## Open Questions (mobile ↔ backend)

1) Are there any protected endpoints where a `401` might occur after side effects (should be “no”, based on guards)?
2) Do any endpoints require multipart/stream bodies that should never be retried automatically?
