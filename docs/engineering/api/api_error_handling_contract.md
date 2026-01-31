# API Error Handling Contract (RFC7807 + Validation)

This document defines the **backend ↔ frontend contract** for errors in this codebase.
The goal is predictable handling, stable mappings, and user-friendly messaging without leaking
implementation details to the UI.

## 1) Principles

- **Backend provides stable error identifiers** (`code`, `traceId`).
- **Frontend owns user-facing copy** (localization + product tone).
- **Do not map UI behavior from human strings** (`title`, `detail`, `message`).
- **Prefer `code` first, HTTP status as fallback**.
- **Never include PII** (email, tokens, names) in errors or logs.

## 2) Supported Error Shapes

This template expects **RFC7807 Problem Details** (`application/problem+json`) for errors.

This is commonly returned by API gateways, middleware, or frameworks.

**Response**

```json
{
  "type": "about:blank",
  "title": "Too Many Requests",
  "status": 429,
  "detail": "Rate limit exceeded. Please try again later.",
  "code": "RATE_LIMITED",
  "traceId": "7e2c3f2b-7d49-4a17-9f4c-3d2c4b6d8a10"
}
```

Notes:
- Frontend will treat `title/detail` as **fallback message only**.
- `code` is still the preferred mapping key.

## 3) Validation Errors

Validation is represented as RFC7807 with an optional `errors[]` array for field-level details.

**Validation error item contract**

```json
{ "field": "email", "code": "invalid_email", "message": "Invalid email" }
```

Frontend behavior:
- Prefer mapping by `code` per field (local copy).
- Use backend `message` only as a fallback for unknown codes.

## 4) Frontend Mapping Rules (Template Standard)

### 4.1 Mapping precedence

1. `ApiFailure.code` (RFC7807 / envelope)
2. `ApiFailure.statusCode` fallback
3. Generic unexpected failure (log `code` + `traceId`)

### 4.2 Where mapping lives

- Mapping from `ApiFailure` → domain failures belongs in the **data layer boundary** (repo/mapper).
- Keep codes centralized:
  - Cross-cutting codes in `lib/core/infra/network/exceptions/api_error_codes.dart`
  - Feature-specific codes in `lib/features/<feature>/data/error/*_error_codes.dart`

Example (auth):
- Mapper: `lib/features/auth/data/error/auth_failure_mapper.dart`
- Codes: `lib/features/auth/data/error/auth_error_codes.dart`

## 5) Backend Error Catalog (Recommended)

Do not force frontend to “guess” codes by trial and error.

Maintain a versioned catalog (OpenAPI preferred), containing:
- `httpStatus`
- `code`
- meaning
- retryable?
- (optional) validation `errors[].field` + `errors[].code` list per endpoint

## 6) Observability

- Always log or report `traceId` with unknown/unexpected errors.
- Avoid logging raw response bodies if they may contain sensitive content.

## 7) Auth Endpoint Contract (Current Backend)

`POST /v1/auth/password/login`
- `VALIDATION_FAILED`
- `AUTH_INVALID_CREDENTIALS`
- `AUTH_USER_SUSPENDED`
- `RATE_LIMITED`

`POST /v1/auth/refresh`
- `VALIDATION_FAILED`
- `AUTH_REFRESH_TOKEN_INVALID`
- `AUTH_REFRESH_TOKEN_EXPIRED`
- `AUTH_REFRESH_TOKEN_REUSED`
- `AUTH_SESSION_REVOKED`
- `AUTH_USER_SUSPENDED`

These codes should be kept stable because frontend mapping depends on them.
