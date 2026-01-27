# Password Reset (Forgot Password) — Engineering Proposal

## Context / Goal

Implement **Password Reset** in `mobile-core-kit` aligned with the backend contract and repo architecture:

- Clean Architecture boundaries (Domain ↔ Data ↔ Presentation).
- Good security posture (no account enumeration, no token leakage).
- Predictable UX for both “request reset email” and “reset via deep link”.
- Template‑grade: easy to port, easy to reason about, consistent with existing auth patterns.

This proposal intentionally focuses on **mobile implementation** and its integration points (routing, deep links, session handling).

## Backend contract (source of truth)

Backend repo: `/mnt/c/Development/_CORE/backend-core-kit`

- OpenAPI: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
- Engineering notes: `/mnt/c/Development/_CORE/backend-core-kit/docs/engineering/auth/password-reset.md`

### Link format (frontend‑owned)

The backend worker generates:

`{PUBLIC_APP_URL}/reset-password?token=<raw-token>`

Where `PUBLIC_APP_URL` is currently set to the app link domain (e.g. `https://links.fikril.dev`).

The mobile app (frontend) must:

- Read the `token` query parameter.
- Submit `{ token, newPassword }` to confirm the reset.

### Endpoint 1 — Request password reset (public)

- `POST /v1/auth/password/reset/request`
- Requires auth: **no**
- Success: `204 No Content`
- Important behavior:
  - Returns `204` even if the email is unknown (prevents account enumeration).
  - Enqueues a worker job best-effort for existing users.
- Request DTO: `PasswordResetRequestDto`
  - `email: string` (required)
- Error codes:
  - `VALIDATION_FAILED`
  - `RATE_LIMITED`
  - `INTERNAL`

### Endpoint 2 — Confirm password reset (public)

- `POST /v1/auth/password/reset/confirm`
- Requires auth: **no**
- Success: `204 No Content`
- Important behavior:
  - Consumes a one‑time token, updates/creates password credentials.
  - Revokes **all sessions + refresh tokens** for the user.
- Request DTO: `PasswordResetConfirmRequestDto`
  - `token: string` (required)
  - `newPassword: string` (minLength: **10**, required)
- Error codes:
  - `VALIDATION_FAILED`
  - `AUTH_PASSWORD_RESET_TOKEN_INVALID`
  - `AUTH_PASSWORD_RESET_TOKEN_EXPIRED`
  - `INTERNAL`

## Current gaps in mobile

1. No endpoints in `AuthEndpoint` for reset request/confirm.
2. No `AuthRemoteDataSource` methods for reset request/confirm.
3. No domain contracts/use cases (request + confirm).
4. No failure mapping for reset token invalid/expired.
5. No routes/screens:
   - “Forgot password” entry on sign-in.
   - Reset password screen driven by the deep link.
6. Deep link allowlist does not include `/reset-password`.

## Recommended design (enterprise / template‑grade)

### High-level UX

**A) Request flow (from sign-in):**

1. User taps “Forgot password?” on sign-in.
2. User enters email and submits.
3. Always show success copy: “If an account exists, we’ve sent a reset link.” (no enumeration).
4. Handle 429 rate limit with a clear “try again later” message.
5. User returns to sign-in.

**B) Confirm flow (from deep link):**

1. User opens `https://links.fikril.dev/reset-password?token=...`.
2. App routes to a Reset Password page that:
   - Reads token from the query param.
   - Lets user enter new password + confirm password.
3. On submit, call confirm endpoint.
4. On success:
   - **Clear local session** (tokens + cached user) because backend revoked sessions.
   - Navigate to sign-in and show success snackbar.
5. If token is missing/invalid/expired:
   - Show a deterministic failure state (similar to verify email), with CTA back to sign-in.

### Placement (structure ownership)

Keep password reset in **auth feature** because:

- It is an authentication/security concern.
- Endpoints are under `/v1/auth/...`.
- It should be reusable in future template consumers.

Routing should still be **navigation-owned** (GoRouter), and deep-link parsing remains core (`DeepLinkParser`).

### System tree (proposed)

```
lib/
└─ features/
   └─ auth/
      ├─ data/
      │  ├─ datasource/remote/
      │  │  └─ auth_remote_datasource.dart
      │  ├─ error/
      │  │  ├─ auth_error_codes.dart              # add reset token codes
      │  │  └─ auth_failure_mapper.dart           # map codes → AuthFailure/ValidationError
      │  ├─ model/remote/
      │  │  ├─ password_reset_request_model.dart
      │  │  └─ password_reset_confirm_request_model.dart
      │  └─ repository/
      │     └─ auth_repository_impl.dart          # orchestration-only
      ├─ domain/
      │  ├─ entity/
      │  │  ├─ password_reset_request_entity.dart
      │  │  └─ password_reset_confirm_request_entity.dart
      │  ├─ usecase/
      │  │  ├─ request_password_reset_usecase.dart
      │  │  └─ confirm_password_reset_usecase.dart
      │  ├─ value/
      │  │  └─ password_reset_token.dart          # non-empty token
      │  └─ repository/
      │     └─ auth_repository.dart               # add request/confirm methods
      └─ presentation/
         ├─ cubit/password_reset_request/...
         ├─ cubit/password_reset_confirm/...
         └─ pages/
            ├─ password_reset_request_page.dart   # from sign-in
            └─ password_reset_confirm_page.dart   # from deep link

lib/
└─ navigation/
   └─ auth/
      ├─ auth_routes.dart                         # add routes
      └─ auth_routes_list.dart                    # wire providers + token query

lib/
└─ core/services/deep_link/deep_link_parser.dart  # allowlist '/reset-password'
```

## Domain layer

### Entities

1) `PasswordResetRequestEntity`

- `email`

2) `PasswordResetConfirmRequestEntity`

- `token`
- `newPassword`

Note: backend confirm DTO doesn’t require `confirmNewPassword`, but mobile UI should include it for UX; confirm matching is validated in presentation and use case.

### Use cases

1) `RequestPasswordResetUseCase`

- Final gate validation:
  - email format (reuse `EmailAddress` VO).
- Calls repository `requestPasswordReset(...)`.
- Returns `Either<AuthFailure, Unit>`.

2) `ConfirmPasswordResetUseCase`

- Final gate validation:
  - token non-empty (new `PasswordResetToken` VO).
  - `newPassword` policy (reuse `Password` VO — minLength 10).
  - optional: `confirmNewPassword` match (use `ConfirmPassword` VO) if you keep confirm in the use case signature; otherwise presentation-only.
- Calls repository `confirmPasswordReset(...)`.
- Returns `Either<AuthFailure, Unit>`.

## Data layer

### Endpoints

Add to `AuthEndpoint`:

- `/auth/password/reset/request`
- `/auth/password/reset/confirm`

### Remote datasource

Add methods to `AuthRemoteDataSource`:

- `requestPasswordReset(PasswordResetRequestModel)` → `ApiResponse<ApiNoData>`
- `confirmPasswordReset(PasswordResetConfirmRequestModel)` → `ApiResponse<ApiNoData>`

Notes:

- Both endpoints are **public** (`requiresAuth: false`).
- Neither endpoint declares idempotency headers in OpenAPI; do not invent additional semantics unless backend adds it.

### Repository

Add to `AuthRepository`:

- `Future<Either<AuthFailure, Unit>> requestPasswordReset(PasswordResetRequestEntity request)`
- `Future<Either<AuthFailure, Unit>> confirmPasswordReset(PasswordResetConfirmRequestEntity request)`

`AuthRepositoryImpl` should:

- Convert entity → model (`Model.fromEntity(...)`).
- Call remote datasource.
- Convert response to Either via `toEitherWithFallback(...)`.
- Map failures via `mapAuthFailure` (extend to include reset token codes).

### Failure mapping

Add codes to `AuthErrorCodes`:

- `AUTH_PASSWORD_RESET_TOKEN_INVALID`
- `AUTH_PASSWORD_RESET_TOKEN_EXPIRED`

Mapping recommendation (template-grade UX):

- `AUTH_PASSWORD_RESET_TOKEN_INVALID` → `AuthFailure.validation([ValidationError(field: 'token', code: <stable>)])`
- `AUTH_PASSWORD_RESET_TOKEN_EXPIRED` → `AuthFailure.validation([ValidationError(field: 'token', code: <stable>)])`

Why validation?

- It supports deterministic UI (page-level failure state) without adding new failure variants.
- It matches the pattern used for `AUTH_CURRENT_PASSWORD_INVALID` (maps to a field validation error).

Alternatively (acceptable but weaker UX):

- Map invalid/expired token codes to `AuthFailure.unexpected()` and rely on the page body copy.

## Presentation + Navigation

### Routes (auth zone)

Add to `AuthRoutes`:

- `AuthRoutes.requestPasswordReset` (e.g. `/auth/password/reset/request`)
- `AuthRoutes.confirmPasswordReset` (e.g. `/auth/password/reset/confirm`)

**Deep link mapping**:

- Add external path allowlist: `/reset-password` → `AuthRoutes.confirmPasswordReset`
- Keep host allowlist as `links.fikril.dev`

### appRedirect handling (important)

Password reset is a **deterministic deep link** that should behave like verify email:

- It should bypass onboarding gating.
- It should not be blocked by hydration gating.
- It should be allowed even if the user is currently authenticated (edge case: user taps email on same device).

Recommendation:

- Add `isPasswordResetConfirm = locationPath == AuthRoutes.confirmPasswordReset` and treat it like `isVerifyEmail` in `app_redirect.dart` (allow / canonicalize).

### Cubits

Separate cubits are recommended (clear responsibilities):

1) `PasswordResetRequestCubit`
   - `email`, `emailTouched`, `emailError`, `status` (initial/submitting/success/failure), `failure?`
   - on submit:
     - validate email (VO)
     - call use case
     - on success show “email sent (if exists)” message and return to sign-in

2) `PasswordResetConfirmCubit`
   - `token` (from route query), `newPassword`, `confirmNewPassword`, touched flags, per-field errors, status, failure?
   - on submit:
     - validate token + password + confirm
     - call use case confirm
     - on success:
       - call `SessionManager.clearSession(...)` (or equivalent) to ensure local state matches server revocation
       - navigate to sign-in and show success snackbar

Touched-aware errors:

- Gate display to touched fields (avoid cross-field “phantom errors”).
- Use stable `ValidationError.code` and localize via `messageForValidationError`.

## Localization

Add ARB keys for:

- Forgot password entry (sign-in CTA).
- Request page: title/body/button + generic success body.
- Confirm page: title/body/button + success snackbar text.
- Token invalid/expired copy (page failure state).
- Rate limit copy (already exists via generic errors, but may need auth-specific UX copy).

## Testing strategy (minimum template-quality)

Unit tests (fast, stable):

1) VO tests:
   - `PasswordResetToken.create('')` fails, non-empty passes.
2) Usecase tests:
   - invalid email → validation failure; repo not called.
   - missing token / short password → validation failure; repo not called.
3) Failure mapping tests:
   - invalid/expired token codes map to expected failure/validation errors.
4) Cubit tests (optional but recommended):
   - request flow: submitting → success; rate limit mapped to failure.
   - confirm flow: token missing → failure state; submit success clears session intent.

## Open questions (confirm before implementation)

1) Deep link path naming: backend uses `/reset-password`. Confirm mobile should treat this as canonical and keep it stable.
2) Should confirm reset always clear local session even if the user was unauthenticated? (Recommended yes; it’s a no-op in that case, but protects against stale local tokens.)
3) Do we want a “Resend reset email” UX on the confirm failure screen, or keep it simple (CTA back to sign-in + request again)?

