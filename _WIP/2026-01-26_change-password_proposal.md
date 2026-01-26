# Change Password (Mobile) — Engineering Proposal

## Context / Goal

Implement **Change Password** in `mobile-core-kit` aligned to the backend contract, following the repo’s Clean Architecture boundaries and reliability rules (idempotency, safe retries, typed failure mapping, validation at two layers).

This feature should be “template quality”: predictable behavior, clear separation of responsibilities, and easy to port across projects.

## Backend contract (source of truth)

Backend repo: `/mnt/c/Development/_CORE/backend-core-kit`  
OpenAPI: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

### Endpoint

- `POST /v1/auth/password/change`
- Requires auth: **access token** (`security: access-token`)
- Success: `204 No Content`
- Server behavior: **revokes other sessions** (and their refresh tokens) but **keeps the current session active**

### Idempotency

- Optional header: `Idempotency-Key` (recommended UUIDv4, 1–128 chars)
- Replays return `Idempotency-Replayed: true`
- Error code possible: `IDEMPOTENCY_IN_PROGRESS`

### Request DTO

`ChangePasswordRequestDto`

- `currentPassword: string` (minLength: 1)
- `newPassword: string` (minLength: 10)
- Required: both fields

### Error codes (`x-error-codes`)

- `VALIDATION_FAILED`
- `UNAUTHORIZED`
- `IDEMPOTENCY_IN_PROGRESS`
- `CONFLICT`
- `AUTH_PASSWORD_NOT_SET`
- `AUTH_CURRENT_PASSWORD_INVALID`
- `INTERNAL`

## Current gaps in mobile

1. No `/auth/password/change` endpoint wiring in `AuthEndpoint` + `AuthRemoteDataSource`.
2. No domain contract/usecase for change password.
3. Auth value object password policy currently enforces `minLength: 8`, but backend requires `minLength: 10` for password register and change password.
4. No typed mapping for `AUTH_PASSWORD_NOT_SET` and `AUTH_CURRENT_PASSWORD_INVALID`.

## Recommended design (enterprise / template-grade)

### Placement

Keep the feature **auth-owned**:

- API call belongs to `features/auth` (security/auth concern).
- UI entrypoint can be linked from Profile/Settings via routing (Profile should not import Auth domain/data due to `architecture_imports` rules).

### System tree (proposed)

```
lib/
└─ features/
   └─ auth/
      ├─ data/
      │  ├─ datasource/remote/
      │  │  └─ auth_remote_datasource.dart        # add changePassword()
      │  ├─ error/
      │  │  ├─ auth_error_codes.dart              # add new auth codes
      │  │  └─ auth_failure_mapper.dart           # map new codes
      │  ├─ model/remote/
      │  │  └─ change_password_request_model.dart # request DTO
      │  └─ repository/
      │     └─ auth_repository_impl.dart          # call datasource, map failures
      ├─ domain/
      │  ├─ entity/
      │  │  └─ change_password_request_entity.dart
      │  ├─ usecase/
      │  │  └─ change_password_usecase.dart
      │  ├─ value/
      │  │  ├─ login_password.dart                # reuse for currentPassword (non-empty)
      │  │  └─ password.dart                      # update policy (minLength: 10)
      │  └─ repository/
      │     └─ auth_repository.dart               # add changePassword()
      └─ presentation/ (later)
         ├─ cubit/change_password/...
         └─ pages/change_password_page.dart
```

### Domain layer

#### Request entity

Introduce `ChangePasswordRequestEntity`:

- `currentPassword`
- `newPassword`

#### Usecase: `ChangePasswordUseCase`

Responsibilities:

- **Final gate validation** (even if presentation validates):
  - `currentPassword`: non-empty (reuse `LoginPassword.create`)
  - `newPassword`: min length 10 (use `Password.create` after updating policy)
  - Optional additional rule (recommended): `newPassword != currentPassword` (avoid server `CONFLICT`)
- Return `Either<AuthFailure, Unit>`

Validation error representation:

- Prefer `AuthFailure.validation([...])` with `ValidationError(field: ..., code: ...)` consistent with existing auth usecases.

### Data layer

#### Remote datasource

Add a method:

- `Future<ApiResponse<ApiNoData>> changePassword(ChangePasswordRequestModel requestModel, {String? idempotencyKey})`

Implementation:

- `POST AuthEndpoint.changePassword`
- `host: ApiHost.auth`, `requiresAuth: true`, `throwOnError: false`
- Add header `Idempotency-Key: <generated>` (default `IdempotencyKeyUtils.generate()`)

Why:

- Our auth token retry interceptor only retries “write” requests safely when an idempotency key is present.

#### Repository

Add to `AuthRepository`:

- `Future<Either<AuthFailure, Unit>> changePassword(ChangePasswordRequestEntity request)`

Implementation in `AuthRepositoryImpl`:

- Convert entity → model
- Call remote datasource
- `.toEitherWithFallback('Change password failed.')`
- Map `ApiFailure` via a dedicated mapper (either extend `mapAuthFailure` or add `mapAuthFailureForChangePassword`)

### Failure mapping (important UX + correctness)

Add codes in `AuthErrorCodes`:

- `AUTH_PASSWORD_NOT_SET`
- `AUTH_CURRENT_PASSWORD_INVALID`

Mapping recommendation:

- `AUTH_CURRENT_PASSWORD_INVALID` → `AuthFailure.validation([ValidationError(field: 'currentPassword', code: <stable-code>)])`
  - This supports field-level inline error without adding new failure types.
- `AUTH_PASSWORD_NOT_SET` → **typed** failure (recommended), e.g. `AuthFailure.passwordNotSet()`
  - Rationale: this is not a field validation; it’s an account state (OIDC-only user) and needs a different UX (“Set a password”).

If you want to keep `AuthFailure` minimal, fallback option is mapping this to `AuthFailure.unexpected()` but that loses UX quality.

### Password policy alignment (must)

Backend requires `minLength: 10` for:

- Register (password)
- Change password

So the auth `Password` VO should be updated:

- `input.length < 10` instead of `< 8`

This aligns:

- realtime validation in registration/change-password UI
- final gate validation in usecases
- prevents avoidable backend `VALIDATION_FAILED`

### Presentation layer (later, but recommended behavior)

Route entrypoint:

- Exposed from Profile/Settings via route constant (Profile does not import Auth feature code).

Cubit:

- `ChangePasswordCubit` with `status` enum:
  - `initial` / `editing` / `submitting` / `success` / `failure`
- Fields:
  - `currentPassword`, `newPassword`, optional `confirmNewPassword`
  - `currentPasswordError`, `newPasswordError`, `confirmError`
  - `failure` (for generic message)
- Side effects:
  - success snackbar + `Navigator.pop()` only after explicit user tap (per your UX requirement)

### Session implications

Backend keeps current session active; therefore:

- do **not** clear tokens locally
- do **not** force refresh
- simply show success and return

## Testing strategy

Minimum unit coverage (fast, stable):

1. `Password` VO updated policy: “len 9 fails, len 10 passes”
2. `ChangePasswordUseCase`:
   - empty current password → `AuthFailure.validation` on `currentPassword`
   - new password too short → `AuthFailure.validation` on `newPassword`
   - new password equals current → `AuthFailure.validation` (optional rule)
3. Failure mapper:
   - `AUTH_CURRENT_PASSWORD_INVALID` → expected failure type (validation or typed)
   - `AUTH_PASSWORD_NOT_SET` → expected failure type

Cubit tests can be added when presentation is implemented (state transitions + field errors).

## Open questions (confirm before implementation)

1. Should we add a dedicated `AuthFailure.passwordNotSet()` + localized copy (“This account doesn’t have a password yet. Set one first.”)?
2. Do we enforce `newPassword != currentPassword` client-side (recommended) or rely on backend `CONFLICT`?

