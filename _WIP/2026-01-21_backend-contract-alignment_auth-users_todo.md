# TODO — Align Mobile Auth/User Contracts to backend-core-kit

**Repo:** `mobile-core-kit`  
**Backend contract source:** `backend-core-kit` (`/mnt/c/Development/_CORE/backend-core-kit`)  
**Date:** 2026-01-21  
**Status:** In progress (Phase 0–4 complete; Phase 2.4/2.5 + Phase 3.3+ pending)

This TODO aligns **feature-level API contracts** (Auth + Users) in this mobile template to the
**backend-core-kit** OpenAPI contract and standards.

This is intentionally detailed because this repo is a **template**: we want future teams to get a
working, enterprise-grade baseline without “contract drift”.

---

## References (source of truth)

Backend-core-kit:

- OpenAPI snapshot: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
- Standards:
  - `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/api-response-standard.md`
  - `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/authentication.md`
  - `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/error-codes.md`
  - `/mnt/c/Development/_CORE/backend-core-kit/docs/standards/pagination-filtering-sorting.md`

Mobile-core-kit (current):

- Network contract doc: `docs/template/networking_backend_contract.md`
- Auth endpoints/constants: `lib/core/network/endpoints/auth_endpoint.dart`
- User endpoints/constants: `lib/core/network/endpoints/user_endpoint.dart`
- Auth remote datasource: `lib/features/auth/data/datasource/remote/auth_remote_datasource.dart`
- User remote datasource: `lib/features/user/data/datasource/remote/user_remote_datasource.dart`
- Auth session/tokens entities: `lib/core/session/entity/auth_session_entity.dart`, `lib/core/session/entity/auth_tokens_entity.dart`
- Session persistence: `lib/core/session/session_repository_impl.dart`
- Token refresh + retry policy: `lib/core/session/session_manager.dart`, `lib/core/network/interceptors/auth_token_interceptor.dart`

---

## Definition of done (DoD)

- [ ] Mobile can **register/login/refresh/logout** against backend-core-kit without “adapter hacks”.
- [ ] Mobile can **GET /v1/me** and map it into the app’s `UserEntity` (names, emailVerified, etc.).
- [ ] Token expiry is computed deterministically from the access token (JWT `exp`) and persisted so:
  - [ ] cold start restore works (`SessionRepositoryImpl.loadSession()` succeeds)
  - [ ] preflight refresh (`isAccessTokenExpiringSoon`) works
- [ ] Google sign-in path + payload matches backend-core-kit’s **OIDC exchange** contract.
- [ ] Unit tests cover the new DTO parsing + token-expiry derivation + endpoint path changes.
- [ ] Template docs are updated so downstream teams don’t re-break the contract.

Non-goals (for this alignment):

- Multi-account switching (this template has guest mode, not multi-account).
- Implementing every backend-core-kit endpoint under `/v1/me/**` (sessions list, profile images, etc.).
  - We can add those later as optional template modules.

---

## Gap summary (current mismatches)

### 1) `GET /me` path mismatch (fixed)

- Backend: `GET /v1/me`
- Mobile: `UserEndpoint.me = '/me'` → `/v1/me` ✅

### 2) Auth success payload mismatch (login/register/refresh)

Backend `AuthResultEnvelopeDto`:

```json
{ "data": { "user": { ... }, "accessToken": "...", "refreshToken": "..." } }
```

Mobile currently expects:

```json
{ "data": { "tokens": { "accessToken": "...", "refreshToken": "...", "expiresIn": ... }, "user": { ... } } }
```

Backend does **not** send:

- `tokens` object
- `expiresIn`
- `tokenType`

So mobile must derive expiry from the JWT `exp` (or we change backend, but the kit standard does not).

### 3) Register request mismatch (names)

Backend `POST /v1/auth/password/register` request:

- `email`, `password`, optional `deviceId`, optional `deviceName`

Mobile sends **required** `firstName` and `lastName` in `RegisterRequestModel`.

### 4) “Me” payload shape mismatch (profile nesting)

Backend `MeDto`:

- `profile: { displayName, givenName, familyName }`
- plus `roles`, `authMethods`, optional `accountDeletion`

Mobile `UserModel` expects flat fields:

- `firstName`, `lastName`, optional `createdAt`

### 5) Google/OIDC exchange mismatch

Backend:

- `POST /v1/auth/oidc/exchange` with `{ provider: "GOOGLE", idToken: "<google-oidc-id-token>" }`

Mobile:

- `POST /auth/google` with `{ idToken: "<firebase-id-token>" }`

---

## Decision points (pick and lock before implementation)

- [x] **Register UX decision (agreed): progressive profiling, client-derived**
  - [x] `POST /v1/auth/password/register` is **account created + authenticated session issued**.
    - Request: `{ email, password, deviceId?, deviceName? }`
    - Response: `{ data: { user, accessToken, refreshToken } }`
  - [x] No backend `onboarding.status/nextStep` in the baseline contract.
  - [x] Client derives “profile completeness” from `GET /v1/me` (data presence), and:
    - [x] After register/login/OIDC exchange → fetch `/v1/me` and route to **Complete Profile** if required fields are missing.
    - [x] On cold start with tokens restored → fetch `/v1/me` and re-route to **Complete Profile** if still incomplete (resume).
    - [x] Profile completion persists via `PATCH /v1/me` (use `Idempotency-Key` for safe retries).
- [x] **Google sign-in decision (agreed): OIDC exchange**
  - [x] Client obtains **Google OIDC `id_token`** via `google_sign_in` and calls `POST /v1/auth/oidc/exchange`.
  - [x] Remove Firebase ID token exchange from this flow:
    - [x] No FirebaseAuth sign-in needed for Google exchange.
    - [x] Remove unused code paths and dependencies (no deprecation layer; delete/replace).
- [x] **User domain model decision (agreed): expand UserEntity + persistence**
  - [x] Expand `UserEntity` to align with backend `MeDto` (roles, authMethods, profile, accountDeletion).
  - [x] Expand remote models + local cached-user schema accordingly.
  - [x] Add a DB migration path (cached user is a cache, but migrations must still be deterministic and tested).

---

## Phase 0 — Baseline & contract snapshot

- [x] Capture the backend-core-kit endpoints we must support (copy minimal OpenAPI snippets into this doc for traceability):
  - [x] `POST /v1/auth/password/register`
  - [x] `POST /v1/auth/password/login`
  - [x] `POST /v1/auth/refresh`
  - [x] `POST /v1/auth/logout`
  - [x] `POST /v1/auth/oidc/exchange`
  - [x] `GET /v1/me`
  - [x] `PATCH /v1/me` (profile completion; required for the agreed progressive flow)
- [x] Confirm which base URL the mobile client should use for local dev with backend-core-kit (platform nuance):
  - Backend-core-kit runs at `http://127.0.0.1:4000` with routes under `/v1`.
  - Mobile `dev.yaml` should point to a **host reachable from the running client**:
    - Android emulator: `http://10.0.2.2:4000/v1` ✅ (chosen baseline)
    - iOS simulator: `http://127.0.0.1:4000/v1`
    - Flutter web/desktop: `http://127.0.0.1:4000/v1`
    - Physical device: `http://<LAN_IP_OF_DEV_MACHINE>:4000/v1`
  - Then update `.env/dev.yaml` accordingly and regenerate build config.
- [x] Run verification baseline (so we can tell what changed):
  - [x] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

### Phase 0 output — verification baseline (dev)

Command:

```bash
tool/agent/dartw --no-stdin run tool/verify.dart --env dev
```

Result (2026-01-21):

- ✅ `flutter analyze`: no issues
- ✅ `dart run custom_lint`: no issues
- ✅ `flutter test`: all tests passed
- ✅ `tool/verify_modal_entrypoints.dart`: OK
- ✅ `tool/verify_hardcoded_ui_colors.dart`: OK
- Notes:
  - `flutter pub get` reports newer incompatible versions (expected; not part of this alignment).
  - `dart format (check)` prints “Changed …” output and `analysis_options.yaml` shows a package resolution warning for `package:flutter_lints/flutter.yaml` in this environment (seen previously; investigate separately if it persists).

### Phase 0 — Backend OpenAPI excerpts (traceability)

Source: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

#### Auth

`POST /v1/auth/password/register`

```yaml
/v1/auth/password/register:
  post:
    operationId: auth.password.register
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/PasswordRegisterRequestDto"
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/AuthResultEnvelopeDto"
```

`POST /v1/auth/password/login`

```yaml
/v1/auth/password/login:
  post:
    operationId: auth.password.login
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/PasswordLoginRequestDto"
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/AuthResultEnvelopeDto"
```

`POST /v1/auth/oidc/exchange`

```yaml
/v1/auth/oidc/exchange:
  post:
    operationId: auth.oidc.exchange
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/OidcExchangeRequestDto"
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/AuthResultEnvelopeDto"
```

`POST /v1/auth/refresh`

```yaml
/v1/auth/refresh:
  post:
    operationId: auth.refresh
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/RefreshRequestDto"
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/AuthResultEnvelopeDto"
```

`POST /v1/auth/logout`

```yaml
/v1/auth/logout:
  post:
    operationId: auth.logout
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/LogoutRequestDto"
    responses:
      "204": {}
```

#### Users / Me

`GET /v1/me`

```yaml
/v1/me:
  get:
    operationId: users.me.get
    security:
      - access-token: []
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/MeEnvelopeDto"
```

`PATCH /v1/me`

```yaml
/v1/me:
  patch:
    operationId: users.me.patch
    security:
      - access-token: []
    parameters:
      - name: Idempotency-Key
        in: header
        required: false
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/PatchMeRequestDto"
    responses:
      "200":
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/MeEnvelopeDto"
```

#### DTO shape notes (what mobile must model)

Auth success envelope:

```json
{ "data": { "user": { "id": "...", "email": "...", "emailVerified": false, "authMethods": ["PASSWORD"] }, "accessToken": "...", "refreshToken": "..." } }
```

Me envelope (profile is nested + nullable):

```json
{
  "data": {
    "id": "...",
    "email": "...",
    "emailVerified": false,
    "roles": ["USER"],
    "authMethods": ["PASSWORD"],
    "profile": { "displayName": null, "givenName": null, "familyName": null, "profileImageFileId": null },
    "accountDeletion": null
  }
}
```

---

## Phase 1 — Endpoint path alignment (low risk)

- [x] Update `UserEndpoint.me` to match backend:
  - [x] `lib/core/network/endpoints/user_endpoint.dart`: `'/me'`
  - [x] Update call sites:
    - [x] `lib/features/user/data/datasource/remote/user_remote_datasource.dart`
  - [x] Update any comments/docs that mention `/users/me`:
    - [x] `lib/core/session/entity/auth_session_entity.dart` comment (“hydrate via GET …”)
    - [x] `docs/template/networking_backend_contract.md`
- [x] Add/update unit tests (smoke-level):
  - [x] Ensure `UserRemoteDataSource.getMe()` hits `/me` path:
    - [x] `test/features/user/data/datasource/remote/user_remote_datasource_test.dart`

---

## Phase 2 — Auth success DTO alignment (login/register/refresh)

### 2.1 Introduce backend-compatible DTOs

- [x] Replace mobile auth-success DTOs to match backend-core-kit (no backward compatible parsing):
  - [x] `lib/features/auth/data/model/remote/auth_result_model.dart`
    - shape: `{ user, accessToken, refreshToken }`
    - note: `ApiHelper` already unwraps `{ data: ... }`, so no envelope model is needed
  - [x] Removed old `{ tokens: { ... }, user: ... }` DTOs:
    - [x] deleted `AuthSessionModel` and `AuthTokensModel` (and generated files)
- [x] Update `AuthRemoteDataSource`:
  - [x] `register()` parses `AuthResultModel`
  - [x] `login()` parses `AuthResultModel`
  - [x] `refreshToken()` parses `AuthResultModel` (matches backend `/v1/auth/refresh`)
    - repository can ignore `user` for refresh

### 2.2 Token expiry derivation (required)

Backend does not send `expiresIn`, so mobile must derive token expiry from JWT `exp`.

- [x] Add a small core utility:
  - [x] `lib/core/utilities/jwt_utils.dart`:
    - parse JWT payload without verification (client-side convenience)
    - extract `exp` (seconds since epoch) and compute:
      - `expiresAt: DateTime`
      - `expiresIn: int` (max(0, exp-now))
- [x] Update auth mapping to always produce `AuthTokensEntity` with:
  - [x] `expiresAt` (derived from JWT `exp`)
  - [x] `expiresIn` (derived from JWT `exp`, clamped `>= 0`)
  - [x] `tokenType = 'Bearer'`
  - [x] Wired via `AuthResultModel.toTokensEntity()` (single source of truth for auth-success parsing)
- [x] Add tests:
  - [x] `test/core/utilities/jwt_utils_test.dart`
  - [x] `test/features/auth/data/model/remote/auth_result_model_test.dart`

### 2.3 Register payload decision + implementation

**Agreed approach:** progressive profiling. Register creates an authenticated session; profile fields
are filled via `PATCH /v1/me` and the client resumes completion based on `GET /v1/me`.

- [x] Update domain + models:
  - [x] `RegisterRequestEntity` remove required `firstName/lastName` (names do not belong to auth register payload)
  - [x] `RegisterRequestModel` match backend (`email`, `password`)
    - optional `deviceId/deviceName` are supported by backend but deferred to Phase 6 “Device identity plumbing”.
  - [x] Register validation rules updated accordingly
- [x] Update UI:
  - [x] `lib/features/auth/presentation/pages/register_page.dart` remove first/last name fields
  - [x] Add **Complete Profile** screen (under user feature) that collects names and calls `PATCH /v1/me`
  - [x] Add resume behavior:
    - [x] After auth success: `GET /v1/me` → if required fields missing → navigate to Complete Profile
    - [x] On cold start with tokens: `GET /v1/me` → if required fields missing → navigate to Complete Profile
- [x] Implement `PATCH /v1/me` under user feature:
  - [x] Add DTO(s) matching backend (`PatchMeRequestDto` → `profile: { displayName?, givenName?, familyName? }`)
  - [x] Ensure request retry safety:
    - [x] Client sets `Idempotency-Key` for this PATCH
    - [x] Mobile retry policy already respects idempotency for writes (`AuthTokenInterceptor`)
- [ ] Optional UX hardening:
  - [ ] Store a local “profile draft” while the user is on Complete Profile so closing the app mid-form can resume cleanly.

### 2.4 Update refresh + retry semantics (already mostly aligned)

- [x] Ensure refresh handling stays **fail-closed** on unknown outcome:
  - [x] `mapAuthFailureForRefresh()` treats `null`/`-2` as unauthenticated (unknown outcome → force re-auth)
  - [x] `SessionManager.refreshTokens()` logs out when refresh maps to `unauthenticated`
  - [x] Tests:
    - [x] `test/features/auth/data/error/auth_failure_mapper_test.dart`
    - [x] `test/core/session/session_manager_test.dart`
- [x] Validate `AuthTokenInterceptor` retry policy stays aligned with backend idempotency rules:
  - [x] GET/HEAD retry OK after refresh
  - [x] write retry only with `Idempotency-Key` header
  - [x] Tests:
    - [x] `test/core/network/interceptors/auth_token_interceptor_test.dart`

### 2.5 Tests (must-have)

- [x] Auth DTO parsing tests:
  - [x] login/register parsing from backend-shaped JSON
    - [x] `test/features/auth/data/model/remote/auth_result_model_test.dart`
  - [x] refresh parsing from backend-shaped JSON
    - [x] `test/features/auth/data/model/remote/auth_result_model_test.dart`
- [x] JWT expiry derivation tests:
  - [x] exp present → computed `expiresAt/expiresIn`
    - [x] `test/core/utilities/jwt_utils_test.dart`
    - [x] `test/features/auth/data/model/remote/auth_result_model_test.dart`
  - [x] exp missing/malformed → safe fallback behavior (policy: `expiresIn=0`, `expiresAt=null`)
    - [x] `test/core/utilities/jwt_utils_test.dart`
    - [x] `test/features/auth/data/model/remote/auth_result_model_test.dart`
- [x] Session persistence tests:
  - [x] after login/register, `SessionRepositoryImpl.loadSession()` restores tokens with derived expiry
    - [x] `test/core/session/session_expiry_persistence_test.dart`

---

## Phase 3 — Users “me” DTO alignment

### 3.1 Add backend-shaped Me models

- [x] Add models matching backend `MeDto` (nested profile):
  - [x] `MeModel` with:
    - `id`, `email`, `emailVerified`
    - `roles: List<String>`
    - `authMethods: List<String>`
    - `profile: MeProfileModel(displayName, givenName, familyName)`
    - optional `accountDeletion`
- [x] Update `UserRemoteDataSource.getMe()` parser to parse `MeModel` instead of `UserModel`.

### 3.2 Map backend Me → app `UserEntity`

Agreed: **full mapping**. `UserEntity` becomes the client-side representation of backend `MeDto`
(while still allowing partial data when the user comes from auth responses only).

- [x] Expand `UserEntity` (and local persistence schema) to include:
  - [x] `roles: List<String>` (from `MeDto.roles`)
  - [x] `authMethods: List<String>` (from `MeDto.authMethods`, and `AuthUserDto.authMethods` where present)
  - [x] `profile` object:
    - `displayName`, `givenName`, `familyName`, `profileImageFileId`
  - [x] optional `accountDeletion`:
    - `requestedAt`, `scheduledFor` (ISO datetime strings, or parsed DateTimes)

### 3.3 Cached user persistence (schema impact)

Agreed: schema changes required.

- [x] Update `UserLocalModel.createTableQuery` + mapping to store the expanded entity.
  - [x] Profile fields stored as columns (givenName/familyName/displayName/profileImageFileId).
  - [x] `roles/authMethods` stored as JSON `TEXT` (`rolesJson/authMethodsJson`).
  - [x] `accountDeletion` stored as columns (`accountDeletionRequestedAt/accountDeletionScheduledFor`).
- [ ] Migration strategy (template note):
  - Cached user is treated as a **cache**, so we do not bump DB version or add migrations in this contract-alignment pass.
  - If a downstream app needs to preserve cache across upgrades, bump `AppDatabase._dbVersion` and add migrations in `AppDatabase.registerMigration(...)`.
- [x] Update `UserLocalModel.fromMap/toMap` and tests.
  - [x] `test/features/user/data/datasource/local/user_local_datasource_test.dart`

### 3.4 Tests (must-have)

- [x] Me parsing tests:
  - [x] nested profile JSON maps correctly to `UserEntity`
    - [x] `test/features/user/data/model/remote/me_model_test.dart`
- [x] Cached user restore still works:
  - [x] `SessionManager.restoreCachedUserIfNeeded()` emits user without network call
    - [x] `test/core/session/session_manager_test.dart`
    - [x] `test/core/services/app_startup/app_startup_controller_test.dart` (ensures no `/me` fetch after cached user restore)

---

## Phase 4 — OIDC (Google) alignment

Backend contract:

- `POST /v1/auth/oidc/exchange` with `provider=GOOGLE` and Google OIDC `id_token`.

Mobile tasks:

- [x] Replace endpoint constant:
  - [x] `lib/core/network/endpoints/auth_endpoint.dart`: replace `google` with `oidcExchange = '/auth/oidc/exchange'`
- [x] Replace request model:
  - [x] `OidcExchangeRequestModel { provider, idToken }`
  - [x] Note: backend supports optional `deviceId/deviceName`; template defers these to Phase 6 “Device identity plumbing”.
- [x] Update auth repository/usecase/cubit naming:
  - [x] `googleSignIn()` becomes `signInWithGoogleOidc()` (or similar) but keep UI copy “Continue with Google”
- [x] Update federated auth service:
  - [x] Stop returning Firebase ID token
  - [x] Return Google OIDC `idToken` from `google_sign_in` directly
  - [x] Remove FirebaseAuth dependency from this flow (Firebase can still exist for messaging/crashlytics/analytics, etc.)
  - [x] Remove unused code and unused dependencies (no deprecation layer)
- [x] Tests:
  - [x] service returns null on cancel
  - [x] exchange request body matches backend contract

---

## Phase 5 — Docs alignment (template hygiene)

- [x] Update `docs/template/networking_backend_contract.md`:
  - [x] `/v1/me` instead of `/v1/users/me`
  - [x] Auth success payload shape `{ user, accessToken, refreshToken }`
  - [x] Note “expiresIn derived from JWT exp” policy
  - [x] Note idempotency retry policy for writes
- [x] Add a short “Mobile ↔ backend-core-kit integration” doc section:
  - [x] recommended `.env/dev.yaml` base URL(s) for local backend (Android emulator: `http://10.0.2.2:4000/v1`)
  - [x] how to run backend + mobile together

---

## Phase 6 — Optional enterprise upgrades (nice-to-have)

- [ ] Add a client-generated request id:
  - [ ] new interceptor that sets `X-Request-Id` on every request if absent (UUIDv4)
  - aligns with backend’s “accept from clients; generate if missing”
- [ ] Device identity plumbing:
  - [ ] stable `deviceId` provider + optional `deviceName`
  - pass through to login/register/oidc exchange payloads
- [ ] Implement more `/v1/me/**` endpoints as optional modules:
  - [ ] push token register/revoke
  - [ ] session list + revoke-other-sessions
  - [ ] profile image upload plan + complete
  - [ ] account deletion request/cancel

---

## Suggested execution order (PR-sized chunks)

1) Phase 1 (paths + docs)  
2) Phase 2 (auth DTO + jwt expiry derivation + tests)  
3) Phase 3 (me DTO + mapping + tests)  
4) Phase 4 (OIDC exchange)  
5) Phase 5 (docs)  
