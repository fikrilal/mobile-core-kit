# Networking + Backend Contract Guide

This template ships with a production-style networking stack (Dio + typed parsers + interceptors).
When you clone this repo for a real product, the **first thing you should align** is the network
layer’s contract with your backend: response envelope, error shape, and pagination.

This doc explains what the template currently assumes and what to change for a different backend.

---

## 1) Current backend contract (what the template expects)

### 1.1 Success responses: `{ data, meta? }`

Most endpoints should return:

```json
{
  "data": { /* payload */ },
  "meta": { /* optional */ }
}
```

- Lists should return `data: []` with optional `meta`.
- The template **preserves `meta`** on `ApiResponse.meta`.
- `204 No Content` returns an empty body (no envelope).
- Some endpoints may intentionally return a raw JSON body (e.g. health checks).

Where it’s implemented:
- Parsing is handled in `lib/core/network/api/api_helper.dart` (single place).
- The parsed result type is `ApiResponse<T>` (`lib/core/network/api/api_response.dart`).

### 1.2 Errors: RFC 7807 (`application/problem+json`)

Errors are expected to use Problem Details:

```json
{
  "type": "about:blank",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Optional detail",
  "code": "UNAUTHORIZED",
  "traceId": "req_..."
}
```

Where it’s implemented:
- Dio error mapping lives in `lib/core/network/exceptions/api_failure.dart`.
- `ApiFailure.traceId` prefers `X-Request-Id` header, falling back to body `traceId`.

### 1.3 Request correlation: `X-Request-Id`

The backend should echo `X-Request-Id` on responses.
The template records it as:
- `ApiResponse.traceId` for success responses
- `ApiFailure.traceId` for error responses

### 1.4 Cursor pagination: `meta.nextCursor`, `meta.limit`

Cursor-list endpoints should return:

```json
{
  "data": [ /* items */ ],
  "meta": {
    "nextCursor": "cursor_string_or_null",
    "limit": 25
  }
}
```

Where it’s implemented:
- `ApiPaginatedResult<T>` is cursor-based: `nextCursor`, `limit` (`lib/core/network/api/api_paginated_result.dart`).
- Domain helpers are cursor-based: `DomainCursorPagination` (`lib/core/network/api/pagination_utils.dart`).

### 1.5 Auth session payloads: `{ user, accessToken, refreshToken }`

When integrating with `backend-core-kit`, the auth endpoints return an auth result shaped like:

```json
{
  "data": {
    "user": { "id": "u1", "email": "user@example.com", "emailVerified": true },
    "accessToken": "<jwt>",
    "refreshToken": "<opaque>"
  }
}
```

Notes:

- The mobile template expects this shape for:
  - register (`POST /v1/auth/password/register`)
  - login (`POST /v1/auth/password/login`)
  - refresh (`POST /v1/auth/refresh`)
- Token expiry is **derived** from the access token’s JWT `exp` claim (backend does not send `expiresIn`).
  - See: `lib/core/utilities/jwt_utils.dart` + `AuthResultModel.toTokensEntity()`
  - Persisted fields: `expiresIn` (seconds remaining) and `expiresAtMs` (absolute timestamp), so cold-start restore can preflight refresh.

### 1.6 Idempotency + retry rules (important)

The template aligns its automatic auth-retry policy with backend-core-kit’s idempotency standards:

- **Reads** (`GET`, `HEAD`) may be retried after a token refresh.
- **Writes** (`POST`, `PUT`, `PATCH`, `DELETE`) are only retried if an `Idempotency-Key` header is present.

Where it’s implemented:

- `AuthTokenInterceptor` enforces the retry rule: `lib/core/network/interceptors/auth_token_interceptor.dart`
- Feature datasources must set `Idempotency-Key` when the operation is safe to retry (example: `PATCH /v1/me`).

---

## 2) How to customize the template for your backend

### 2.1 Base URLs (per environment)

Edit `.env/dev.yaml`, `.env/staging.yaml`, `.env/prod.yaml` and regenerate:

`dart run tool/gen_config.dart --env dev`

Then use:
- `BuildConfig.apiUrl(ApiHost.core|auth|profile)` from `lib/core/configs/build_config.dart`.

See: `docs/template/env_config.md`.

#### backend-core-kit (local) quick defaults

When running `backend-core-kit` locally, API runs at `http://127.0.0.1:4000` with routes under `/v1`.

In `.env/dev.yaml`, set `core/auth/profile` to a base URL reachable from your client runtime:

- Android emulator: `http://10.0.2.2:4000/v1`
- iOS simulator / Flutter desktop / Flutter web: `http://127.0.0.1:4000/v1`
- Physical device: `http://<LAN_IP_OF_DEV_MACHINE>:4000/v1`

### 2.2 Endpoint paths

Endpoint constants live under:
- `lib/core/network/endpoints/`

Update those paths to match your backend routing (and keep feature routes grouped).

### 2.3 Auth header + token refresh behavior

The request auth policy is driven by:
- `requiresAuth` parameter in `ApiHelper` calls (`lib/core/network/api/api_helper.dart`)
- `AuthTokenInterceptor` (Bearer token injection + refresh) (`lib/core/network/interceptors/auth_token_interceptor.dart`)
- Session persistence and refresh logic (`lib/core/session/session_manager.dart`)

If your backend’s auth scheme differs (header name, token type, refresh flow), change these in
the interceptor/session layer (not in each feature datasource).

### 2.4 Response envelope changes (if your backend differs)

If your backend does **not** return `{ data, meta? }`:
- Update parsing in one place: `lib/core/network/api/api_helper.dart`
  - `_processResponse(...)` should recognize the backend shape
  - `_parseData(...)` should extract the payload and preserve metadata
- Update `ApiFailure.fromDioException` only if your error shape is not RFC 7807.

Avoid “adapter logic” in repositories/datasources; keep contract translation inside `core/network`.

### 2.5 Pagination changes (cursor vs offset/page)

If your backend uses offset/page pagination instead of cursor:
- Replace the cursor fields (`meta.nextCursor`) with your backend’s fields
- Update `ApiPaginatedResult<T>` and `pagination_utils.dart` to match
- Keep the domain-facing pagination type aligned with your product needs

---

## 3) Adding a new API call (recommended pattern)

1) Add/confirm the endpoint constant under `lib/core/network/endpoints/...`.
2) In the feature `RemoteDataSource`, call `ApiHelper` with a typed parser:
   - `getOne<T>()` for objects
   - `getList<T>()` for arrays
   - `getPaginated<T>()` only for cursor pagination endpoints that return `meta.nextCursor`
3) Map DTO → entity in the repository (keep domain pure).

---

## 4) Verification checklist (after customizing)

- Generate env config: `dart run tool/gen_config.dart --env dev`
- Analyze: `fvm flutter analyze`
- Tests: `fvm flutter test`

---

## 5) Mobile ↔ backend-core-kit integration (local)

Backend (from `/mnt/c/Development/_CORE/backend-core-kit`):

- `cp env.example .env`
- `npm run deps:up` (Postgres + Redis)
- `npm install`
- `npm run prisma:migrate && npm run prisma:generate`
- `npm run start:dev` (API on `http://127.0.0.1:4000`, Swagger at `/docs`)

Mobile (this repo):

1) Ensure `.env/dev.yaml` points to the reachable base URL (see section 2.1).
2) Regenerate build config: `dart run tool/gen_config.dart --env dev`
3) Run: `fvm flutter run -t lib/main_dev.dart --dart-define=ENV=dev`

WSL note:

- Prefer using the wrappers under `tool/agent/` when running Flutter/Dart from WSL:
  - `tool/agent/dartw --no-stdin run tool/gen_config.dart --env dev`
  - `tool/agent/flutterw analyze`
  - `tool/agent/flutterw --no-stdin test`
