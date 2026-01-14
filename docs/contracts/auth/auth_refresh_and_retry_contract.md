# Auth Token Refresh & Request Retry (Mobile ↔ Backend Contract)

This document explains how the current Flutter template handles:

- attaching access tokens to requests
- refreshing tokens
- retrying failed requests after refresh

It also outlines what the backend needs to guarantee (or implement) if we want
to safely improve UX for authenticated **write** requests (POST/PATCH/PUT/DELETE)
when the access token is expired or otherwise rejected.

---

## TL;DR

- Mobile uses an **access token** for `Authorization: Bearer <token>` and a **refresh token** to mint a new access token.
- Mobile currently has **two refresh paths**:
  1. **Preflight refresh** (before sending a request) when the token is close to expiry.
  2. **401 refresh + retry** (after a request fails) for protected requests, with method-based safety rules:
     - reads (`GET`/`HEAD`) retry after refresh by default
     - writes (`POST`/`PUT`/`PATCH`/`DELETE`) retry after refresh **only when an `Idempotency-Key` is present**
- The retry is guarded (`retried=true`) and happens **at most once** per request.
- For non-replayable requests (streaming/multipart), the call site should opt out via `RequestOptions.extra['allowAuthRetry'] = false`.

---

## Backend Confirmations (received)

The backend team confirmed the following semantics (summarized verbatim). These are important because they determine what the mobile app can safely do automatically.

### 1) “401 implies no side effects” (confirmed)

- For protected routes, auth/authorization is enforced in Nest guards before the controller handler runs (e.g., `AccessTokenGuard` / `RbacGuard`).
- Therefore, a `401`/`403` happens pre-handler and no DB mutation code executes.

Implication: for authenticated **write** requests that return `401`, it is safe for the client to refresh and retry because the server guarantees no side effects occurred on that 401 attempt.

### 2) 401 vs 403 (confirmed)

- `401` = missing/invalid/expired access token → code: `UNAUTHORIZED`
- `403` = token valid but lacks permission → code: `FORBIDDEN`

Implication: only `401` is a candidate for “refresh then retry”; `403` should never trigger retry.

### 3) Refresh behavior (confirmed)

- Refresh tokens **rotate only on a successful 200 refresh**, and the refresh response includes the **new refresh token**.
- Invalid/expired/reused/revoked refresh tokens return `401` with stable error codes:
  - `AUTH_REFRESH_TOKEN_INVALID`
  - `AUTH_REFRESH_TOKEN_EXPIRED`
  - `AUTH_REFRESH_TOKEN_REUSED`
  - `AUTH_SESSION_REVOKED`

### 4) Important nuance: refresh token reuse detection is strict (confirmed)

- Re-sending the same refresh token (due to race/timeout retry) can revoke the session.

Implication for mobile: the client must treat refresh as **at-most-once** and should not automatically retry refresh if the outcome is unknown (timeout/no response).

### 5) Canonical platform error codes (confirmed)

- Access token missing/invalid/expired: `UNAUTHORIZED`
- Permission denied: `FORBIDDEN`
- Validation: `VALIDATION_FAILED`
- Refresh token invalid/expired/reused/session revoked: `AUTH_*` codes above

---

## Current Mobile Behavior (as implemented)

### Session & token storage

- Tokens are persisted in secure storage:
  - `lib/core/storage/secure/token_secure_storage.dart:1`
- A “session” is effectively:
  - `accessToken`, `refreshToken`, `expiresIn`, and optional computed `expiresAt`
  - optionally a cached user profile (sqlite) for fast UI hydration
  - `lib/core/session/session_repository_impl.dart:1`
- Token refresh is orchestrated by:
  - `lib/core/session/session_manager.dart:1`

Key detail: mobile computes `expiresAt` when it receives tokens and uses a small
leeway window to refresh early (`~1 minute`).

### Request pipeline (Dio + interceptors)

Requests typically go through `ApiHelper`, which sets request metadata:

- `extra['requiresAuth'] = true` by default (most endpoints are treated as protected)
- `extra['host'] = ApiHost.*` controls baseUrl selection
- `lib/core/network/api/api_helper.dart:1`

Interceptors:

- `BaseUrlInterceptor` sets the base URL per-host.
- `HeaderInterceptor` adds standard headers and avoids `Content-Type` on bodyless requests.
- `AuthTokenInterceptor` attaches the bearer token and handles refresh/retry logic.
- `LoggingInterceptor` logs (redacted) depending on build config.
- `ErrorInterceptor` logs error details.
- `lib/core/network/api/api_client.dart:1`

### Refresh trigger #1: preflight refresh (before sending a request)

In `AuthTokenInterceptor.onRequest`:

- If `requiresAuth == true` and the token is “expiring soon”, the app attempts a
  single shared refresh (`_refreshOnce()`).
- After that, it attaches `Authorization: Bearer <latest_access_token>`.

This helps avoid many 401s, but it only works when the client can accurately
predict token expiry (and when the token is rejected only due to expiry).

### Refresh trigger #2: 401 refresh + retry (after a request fails)

In `AuthTokenInterceptor.onError`:

- If the response is `401` and `requiresAuth == true`, the interceptor *may*
  refresh and then replay the request once (`retried=true` guard).
- This is gated by a safety rule (reads are retried by default; writes require
  `Idempotency-Key` to be retried).

### Retry rules (what gets auto-retried today)

By default, any request with `requiresAuth=true` is eligible for a single
refresh+retry when it fails with `401`, but the retry is gated:

- reads: `GET`, `HEAD`
- writes: `POST`, `PATCH`, `PUT`, `DELETE` only when `Idempotency-Key` is present

Call sites can opt out (recommended for non-replayable bodies like streaming
uploads) via:

- `RequestOptions.extra['allowAuthRetry'] = false`

Implementation reference:

- `lib/core/network/interceptors/auth_token_interceptor.dart:1`

Important: the kit only retries on **401 after refresh** (at most once). If you
want safe retries for write requests on timeouts/unknown outcomes, you need
idempotency keys (server support + client key reuse).

---

## What this means for “Submit Form” flows

Scenario: user submits an authenticated write request (e.g. POST `/notes`).

There are three important cases:

1) **Token is near expiry and client knows it**
   - Mobile preflight refreshes before sending the POST.
   - Request usually succeeds without seeing a 401.

2) **Server returns 401 due to access token rejection, but refresh token is valid**
   - Examples:
     - access token expired earlier than expected
     - token revoked/invalidated server-side (logout all devices, admin revoke)
     - token rotation semantics changed, old access tokens invalidated
   - Current behavior:
     - Reads: refresh + retry once by default.
     - Writes: refresh + retry once only when an `Idempotency-Key` is present.
     - Call sites can opt out with `allowAuthRetry=false` for non-replayable requests.

   - Backend confirmed behavior (important):
     - A 401/403 happens before controller execution and therefore has **no side effects**.
     - This makes “refresh then retry the write once” safe for the 401 case specifically.

3) **Refresh token is invalid/expired/revoked**
   - Refresh should fail and the client must log out and re-auth.
   - Mobile already has logic to clear session on `unauthenticated` refresh failure:
     - `lib/core/session/session_manager.dart:1`

---

## Backend Confirmation Needed (minimum)

If the backend wants the mobile app to “recover gracefully” from 401s, we need
clear, reliable semantics:

### 1) Auth check happens before side effects

Please confirm:

- For protected endpoints, authentication/authorization is validated *before*
  any mutation is applied.
- If the access token is expired/invalid, the backend returns **401** and
  guarantees **no side effects** happened for that request.

This matters because the client’s decision to “retry after refresh” is only safe
if a 401 implies “request did not execute”.

Status: confirmed by backend (guards enforce auth before handler).

### 2) 401 vs 403 meaning

Please confirm the contract:

- `401 Unauthorized`: access token missing/expired/invalid (retry after refresh may succeed).
- `403 Forbidden`: token valid but user lacks permission (retry will not help).

### 3) Refresh endpoint behavior

Please confirm:

- Refresh endpoint accepts a refresh token and returns:
  - a new access token, and
  - a rotated refresh token
- If refresh token is invalid/expired/revoked, backend returns `401` (or `400`)
  with stable auth error codes so mobile can clear session and re-auth.

Mobile currently maps the following refresh failures to logout:

- `lib/features/auth/data/error/auth_failure_mapper.dart:1`

Backend note: refresh tokens rotate on successful refresh (200); resending the same refresh token after a successful refresh can revoke the session (strict reuse detection). This strongly discourages automatic refresh retries on timeout/unknown outcome.

### 4) Error code consistency (recommended)

Mobile already supports RFC7807-like `code` fields (e.g. `UNAUTHORIZED`,
`VALIDATION_FAILED`, `RATE_LIMITED`). Keeping these consistent makes UX and
telemetry more predictable.

---

## Backend Work Needed (for safe write retries)

If the goal is: “user submits a form once; mobile can safely retry the write if
the token is rejected or the outcome is unknown”, the best-practice solution is
**idempotency keys**.

### Option A (recommended): Idempotency-Key for write endpoints

Backend implements an idempotency mechanism such that repeating the same write
request does not create duplicate records.

Typical spec:

- Request header: `Idempotency-Key: <uuid>`
- Scope: key is unique per (user, endpoint) or (user, endpoint, key)
- TTL: e.g. 24 hours (or shorter, depending on business needs)
- Behavior:
  - First request executes the mutation and stores the key + result.
  - Subsequent requests with the same key return the same result (or a stable
    “already processed” response) without reapplying the mutation.

With this in place:

- Mobile can safely refresh on 401 and retry the original write request once.
- Mobile can also consider safe retries on network timeouts, not just 401.

### Option B: Guarantee “401 implies not executed” for writes

If backend guarantees that *any* 401 happens before side effects, then retrying
after refresh is safe for the 401 case specifically. This still does **not**
solve retries for timeouts/unknown outcomes, but it helps the token-expired UX.

If we adopt this, we should still document which endpoints are safe to auto-retry
and which are not (some endpoints may have non-obvious side effects).

Status: confirmed by backend (guards enforce auth before handler).

---

## What Mobile Can Improve Without Backend Changes

Even without idempotency keys, mobile can improve UX safely by:

- Refreshing on any 401 for protected endpoints and retrying once, while still
  **not** auto-retrying for timeouts/unknown outcomes.
- Optionally surfacing a specific UI message for write requests that fail due to
  expired/invalid access token (e.g., “Session refreshed. Please try again.”).

Auto-resubmitting writes on timeouts/unknown outcomes without backend support is
risky and not recommended.

---

## Questions for Backend (closed)

1) For protected write endpoints, does a 401 guarantee “no mutation executed”?
2) Do you support idempotency keys today? If not, are you open to adding them?
3) Do refresh tokens rotate? If yes, does refresh return the new refresh token?
4) What are the canonical error `code` values for:
   - invalid/expired access token
   - invalid refresh token
   - permission denied
   - validation failed

Status: answered by backend (see “Backend Confirmations” section).
