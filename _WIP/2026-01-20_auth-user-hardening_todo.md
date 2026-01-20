# Auth + User Hardening TODO (toward Current User Core Service)

**Project:** `mobile-core-kit`  
**Date:** 2026-01-20  
**Status:** TODO / execution plan

This is the end-to-end checklist to harden **auth + user/session foundations** first, then implement the **template-standard “current user” core service** (as proposed in `_WIP/2026-01-20_current-user-service-proposal.md`).

## Target outcomes (definition of done)

- [x] **Architecture boundaries are clean:** `tool/lints/architecture_lints.yaml` no longer needs the temporary exceptions under `core_no_features` for `lib/core/session/**` and `lib/core/services/app_startup/**`.
- [x] **Core is truly core:** `lib/core/**` imports **zero** `lib/features/**` (except `lib/core/di/**` importing `lib/features/*/di/**`).
- [x] **User feature owns “me” data end-to-end:** remote + local persistence live under `lib/features/user/**` (not `auth`).
- [x] **Session is stable + deterministic:** token + cached-user persistence is race-safe and fully covered by unit tests.
- [x] **App startup hydration is robust:** no hidden feature imports from core; predictable behavior on offline/unauthenticated/timeout.
- [x] **Core “current user” access is implemented:** `UserContextService` exists, is wired, and used by Profile UI.
- [x] **Verification passes:** `dart run tool/verify.dart --env dev` (or WSL wrapper) is green.

## Phase 0 — Baseline & scoping (no behavior changes)

- [x] Re-run full verification and capture the output in this doc (for before/after):
  - [x] `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`
- [x] Write a short “current flow” diagram (1 page max) covering:
  - [x] login/register → session persisted (tokens + user)
  - [x] cold start → session restored → cached user restored → `GET /me` hydration
  - [x] refresh token flow (single-flight + logout on unauthenticated)
  - [x] logout flow (remote revoke best-effort + local clear)
- [x] Add/confirm acceptance tests we must have before starting the big refactor:
  - [x] session restore doesn’t block startup
  - [x] cached user is never shown across account switches
  - [x] logout always clears cached user

### Phase 0 output — verification baseline (dev)

Command:

```bash
tool/agent/dartw --no-stdin run tool/verify.dart --env dev
```

Result (2026-01-20):

- ✅ `flutter analyze`: no issues
- ✅ `dart run custom_lint`: no issues
- ✅ `tool/verify_modal_entrypoints.dart`: OK
- ✅ `tool/verify_hardcoded_ui_colors.dart`: OK
- ✅ `flutter test`: **All tests passed** (**234** tests)
- ✅ `dart format --set-exit-if-changed .`: 0 changed
- Notes:
  - `flutter pub get` reports **38** packages with newer incompatible versions (expected; not part of Phase 0).
  - `dart format` emits warnings resolving `package:flutter_lints/flutter.yaml` from `analysis_options.yaml` (seen previously; investigate separately if it persists for all dev setups).

### Current flow diagram (today)

#### Login / register (tokens + user returned by API)

1) UI → `LoginCubit` / `RegisterCubit` → `LoginUserUseCase` / `RegisterUserUseCase`
2) `AuthRepositoryImpl` → `AuthRemoteDataSource` → API returns `AuthSessionEntity(tokens + user)`
3) `SessionManager.login(session)`:
   - persists via `SessionRepository.saveSession(...)`
   - emits in-memory session via `sessionNotifier`/`stream`
4) `SessionRepositoryImpl.saveSession(...)`:
   - writes tokens to secure storage (`TokenSecureStorage`)
   - caches user to sqflite (`CachedUserStore.write(user)` → `UserLocalDataSource` → `UserDao` → `users` table)

#### Cold start (restore tokens, then user)

1) App bootstrap → `SessionManager.init()`:
   - reads tokens from secure storage (`SessionRepository.loadSession()` → `TokenSecureStorage.read()`)
   - emits session (may be “auth pending”: tokens present but `user == null`)
   - kicks off best-effort `restoreCachedUserIfNeeded()` (does not block startup)
2) `restoreCachedUserIfNeeded()`:
   - loads cached user via `SessionRepository.loadCachedUser()` → sqflite
   - **race guard:** only applies if session still matches the access token captured at start
3) `AppStartupController.initialize()`:
   - waits for session init (timeout-protected)
   - marks app ready after onboarding read (timeout-protected)
   - if still `isAuthPending` after a short cached-user wait, triggers hydration (`GET /me`)

#### `GET /me` hydration (only if authenticated but user not yet available)

1) `AppStartupController` calls `CurrentUserFetcher.fetch()`
2) `UserRepositoryImpl` → `UserRemoteDataSource.getMe()`
3) On success: `SessionManager.setUser(user)` (persists + emits)
4) On unauthenticated failure: `SessionManager.logout(reason: 'hydrate_unauthenticated')`

#### Refresh token flow

1) `AuthTokenInterceptor` triggers refresh when needed (and dedupes concurrent refresh)
2) `SessionManager.refreshTokens()`:
   - calls `TokenRefresher.refresh(refreshToken)`
   - on `unauthenticated`: publishes `SessionExpired(reason: 'refresh_failed')` then `logout(...)`
   - on success: persists updated tokens and emits session

#### Logout flow

1) UI → `LogoutCubit` → `LogoutFlowUseCase`
2) Best-effort remote revoke (timeout) via `LogoutRemoteUseCase`
3) Always clears local state via `SessionManager.logout(reason: ...)`:
   - `SessionRepository.clearSession()` clears secure storage + cached user DB
   - emits null session + publishes `SessionCleared(reason: ...)`

### Acceptance tests (must-have before Phase 1/2 refactor)

Status: ✅ implemented (2026-01-20)

- [x] Session restore:
  - [x] Cold start with persisted tokens reaches “startup ready” without blocking on cached-user restore.
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart` (initialize: restore doesn’t block).
- [x] Cached user restore:
  - [x] With tokens present and cached user present, the user becomes available without calling `GET /me`.
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart` (hydrate not triggered once auth pending resolves).
  - [x] Cached user restore is ignored if session changes mid-flight.
    - Covered by: `test/core/session/session_manager_test.dart` (restore guard tests).
- [x] Hydration correctness:
  - [x] If `GET /me` returns `unauthenticated`, session is cleared (and cached user is cleared via `SessionRepository.clearSession()`).
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart` (unauthenticated → logout).
  - [x] If `GET /me` is in-flight and the session is cleared, hydration does not apply user afterward.
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart` (mid-flight clear guard).
  - [x] If `GET /me` is in-flight and the user signs into a different account, hydration result does not overwrite the new session’s user.
    - Implemented by: refresh-token session-key guard in `lib/core/services/app_startup/app_startup_controller.dart`.
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart` (mid-flight session switch guard).
- [x] Logout correctness:
  - [x] Logout always clears secure tokens + cached user and publishes `SessionCleared`.
    - Covered by: `test/core/session/session_manager_test.dart` (logout publishes `SessionCleared`).

## Phase 1 — Fix ownership: move user persistence to `features/user`

Goal: user feature owns “me” storage; auth feature owns auth flows; session orchestration remains template-level.

Status: ✅ implemented (2026-01-20)

- [x] Create local persistence under user feature:
  - [x] Move `lib/features/auth/data/datasource/local/dao/user_dao.dart` → `lib/features/user/data/datasource/local/dao/user_dao.dart`
  - [x] Move `lib/features/auth/data/model/local/user_local_model.dart` → `lib/features/user/data/model/local/user_local_model.dart`
  - [x] Create `lib/features/user/data/datasource/local/user_local_datasource.dart`:
    - [x] `Future<UserEntity?> getCachedMe()`
    - [x] `Future<void> cacheMe(UserEntity user)`
    - [x] `Future<void> clearMe()`
- [x] Move DB table registration from auth to user:
  - [x] Remove `AppDatabase.registerOnCreate((db) async => UserDao(db).createTable())` from `lib/features/auth/di/auth_module.dart`
  - [x] Add it to `lib/features/user/di/user_module.dart`
- [x] Replace `AuthLocalDataSource` (auth-owned user persistence) with user-owned local datasource:
  - [x] Delete `lib/features/auth/data/datasource/local/auth_local_datasource.dart`
  - [x] Update `lib/core/session/session_repository_impl.dart` to write/read via `CachedUserStore` (core seam) implemented by user feature.
- [x] Add tests for local persistence:
  - [x] “cacheMe then getCachedMe returns entity”
  - [x] “clearMe removes entity”
  - [x] “schema is created via AppDatabase onCreate tasks”

## Phase 2 — Decouple core from features (remove `core_no_features` exceptions)

Goal: eliminate the known technical debt called out in `tool/lints/architecture_lints.yaml`.

### 2.1 Move shared types out of features (core-owned)

- [x] Move session-owned types out of `features/auth/domain` into `lib/core/session/`:
  - [x] `AuthTokensEntity` → `lib/core/session/entity/auth_tokens_entity.dart` (kept name)
  - [x] `AuthSessionEntity` → `lib/core/session/entity/auth_session_entity.dart` (kept name)
  - [x] `RefreshRequestEntity` → `lib/core/session/entity/refresh_request_entity.dart` (kept name)
- [x] Move `UserEntity` out of `features/user/domain/entity` into core (recommended: user is cross-cutting in almost all apps):
  - [x] `lib/features/user/domain/entity/user_entity.dart` → `lib/core/user/entity/user_entity.dart`
  - [x] Update mappers (`UserModel.toEntity()`, local model mapping) accordingly.

### 2.2 Introduce core interfaces to remove core → feature dependencies

- [x] Create a core refresh abstraction so `SessionManager` no longer imports auth use cases/failures:
  - [x] `lib/core/session/token_refresher.dart`:
    - [x] `Future<Either<SessionFailure, AuthTokensEntity>> refresh(String refreshToken)`
  - [x] `lib/core/session/session_failure.dart` (subset we actually need for session decisions):
    - [x] `network`, `unauthenticated`, `tooManyRequests`, `serverError`, `unexpected`
  - [x] Auth feature provides adapter implementation (registered in `AuthModule`) that maps `AuthFailure` → `SessionFailure`.
- [x] Create a core cached-user abstraction so `SessionRepositoryImpl` doesn’t import user feature data:
  - [x] `lib/core/session/cached_user_store.dart`:
    - [x] `Future<UserEntity?> read()`
    - [x] `Future<void> write(UserEntity user)`
    - [x] `Future<void> clear()`
  - [x] User feature provides adapter implementation wrapping `UserLocalDataSource` (registered in `UserModule`).
- [x] Create a core “current user fetch” abstraction for startup hydration (optional but recommended to remove imports from `AppStartupController`):
  - [x] `lib/core/user/current_user_fetcher.dart`
  - [x] User feature adapter wraps `GetMeUseCase` and returns `Either<SessionFailure, UserEntity>`.

### 2.3 Refactor core to use only core types/interfaces

- [x] Update `lib/core/session/session_manager.dart`:
  - [x] Replace `RefreshTokenUsecase` dependency with `TokenRefresher`.
  - [x] Replace `AuthFailure` usage with `SessionFailure`.
  - [x] Update construction call sites (DI, tests, integration tests).
- [x] Update `lib/core/session/session_repository_impl.dart`:
  - [x] Replace `AuthLocalDataSource` dependency with `CachedUserStore`.
  - [x] Ensure “tokens-only session persisted” still clears cached user to prevent stale profile.
- [x] Update `lib/core/services/app_startup/app_startup_controller.dart`:
  - [x] Remove direct imports of `GetMeUseCase` and `AuthFailure` by depending on `CurrentUserFetcher` + `SessionFailure`.
- [x] Move DI wiring to remove core → feature imports:
  - [x] `lib/core/di/service_locator.dart` no longer imports `lib/features/user/domain/usecase/get_me_usecase.dart`
  - [x] `AppStartupController` gets `CurrentUserFetcher` (core type) instead of `GetMeUseCase` (feature type)
- [x] Update architecture lint config:
  - [x] Remove the temporary allowlists in `tool/lints/architecture_lints.yaml` for:
    - [x] `lib/core/session/**` → `lib/features/auth/**`
    - [x] `lib/core/session/**` → `lib/features/user/domain/entity/**`
    - [x] `lib/core/services/app_startup/**` → `lib/features/user/domain/usecase/**`
    - [x] `lib/core/services/app_startup/**` → `lib/features/auth/domain/failure/**`
    - [x] `lib/core/di/**` → `lib/features/user/domain/usecase/**`

## Phase 3 — Session + auth flow hardening (behavior + tests)

### 3.1 Session restoration & caching semantics

- [x] Add unit tests for `SessionManager` (beyond refresh tests):
  - [x] `init()` restores tokens and emits session
  - [x] `restoreCachedUserIfNeeded()` loads cached user only when:
    - [x] session exists
    - [x] user is null
    - [x] access token hasn’t changed mid-flight
  - [x] `login()` persists tokens (and user when present)
  - [x] `setUser()` persists updated cached user
  - [x] `logout()` clears tokens + cached user and publishes `SessionCleared`
- [x] Add unit tests for `SessionRepositoryImpl` with fakes:
  - [x] “saveSession writes secure tokens”
  - [x] “saveSession clears cached user when user is null”
  - [x] “loadSession returns null when any required token field is missing”
  - [x] “loadCachedUser delegates to cached user store”
  - [x] “clearSession clears secure tokens + cached user store”
- [ ] Decide (and document) whether we support:
  - [ ] multi-account on the same device (switch user) — if yes, add explicit “session key” concept for race guards
  - [ ] guest mode — if yes, define whether user cache persists

### 3.2 Auth feature focus & correctness

- [x] Ensure auth feature stays focused on auth:
  - [x] No DB user persistence code under `features/auth`
  - [x] Auth use cases remain pure: login/register/logout/refresh/google sign-in
- [x] Add auth flow tests that assert cached user behavior:
  - [x] After login, cached user exists (via session persistence)
    - Covered by: `test/features/auth/presentation/cubit/login/login_cubit_persistence_test.dart`
  - [x] After logout, cached user is cleared
    - Covered by: `test/features/auth/domain/usecase/logout_flow_usecase_test.dart`
  - [x] Refresh failure unauthenticated triggers logout and clears cached user
    - Covered by: `test/core/session/session_manager_refresh_logout_persistence_test.dart`

## Phase 4 — Startup hydration hardening (template-level reliability)

- [x] Expand `AppStartupController` test coverage:
  - [x] When onboarding is incomplete, hydration never runs
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart`
  - [x] When `isAuthPending` is true and device goes online, hydration runs (and is cooldown-throttled)
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart`
  - [x] On unauthenticated hydration failure, session is cleared
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart`
  - [x] On transient hydration failure, session remains (no logout)
    - Covered by: `test/core/services/app_startup/app_startup_controller_test.dart`
- [x] Add explicit “single-flight hydration” guard if needed (similar to token refresh policy).
  - Implemented via `_isHydratingUser` and covered by: `test/core/services/app_startup/app_startup_controller_test.dart`

## Phase 5 — Implement the core “current user” layer (after hardening is done)

Goal: provide the template-standard “read current user safely” API for UI + future user-scoped slices.

- [x] Implement `UserContextService` in `lib/core/services/user_context/`:
  - [x] Observes `SessionManager.sessionNotifier`
  - [x] Exposes:
    - [x] `ValueListenable<CurrentUserState>` (`lib/core/services/user_context/current_user_state.dart`)
    - [x] `displayName`, `email`, `initials` helpers
    - [x] `ensureUserFresh()` and `refreshUser()` using `CurrentUserFetcher`
  - [x] Resets derived state on `SessionCleared` / `SessionExpired`
- [ ] (Optional, recommended for scaling) Implement `UserDataSlice<T>` (defer until we have 2+ real slices).
- [x] Update Profile UI to consume `UserContextService`:
  - [x] `lib/features/profile/presentation/pages/profile_page.dart`
- [x] Add unit tests:
  - [x] `test/core/services/user_context/user_context_service_test.dart`
  - [x] service reflects session changes (signedOut/authPending/available)
  - [x] refresh respects single-flight + session race guards
  - [x] ensureUserFresh returns existing user without fetching

## Phase 6 — Docs & template guidance (so downstream teams don’t reinvent this)

- [x] Add a short template doc:
  - [x] `docs/template/current_user.md`
- [x] Update relevant existing docs:
  - [x] `docs/engineering/project_architecture.md` (explicit session/current-user ownership)
  - [x] `docs/template/README.md` (index entry)
- [x] Add a “usage snippet” for `AppText` with alternate fonts / Space Grotesk usage:
  - [x] `docs/template/fonts.md`

## Suggested implementation sequence (PR-sized chunks)

1) **Move user local persistence to user feature** (Phase 1) + tests for local datasource  
2) **Introduce core interfaces/types** (`CachedUserStore`, `TokenRefresher`, `SessionFailure`, move `UserEntity`)  
3) **Refactor core session + startup to depend only on core** + update DI wiring + remove lint exceptions  
4) **Expand session + startup tests** (Phase 3–4) until confidence is high  
5) **Implement `UserContextService` (+ slice)** + update Profile UI + docs

## References (current code)

- `_WIP/2026-01-20_current-user-service-proposal.md`
- `tool/lints/architecture_lints.yaml`
- `lib/core/session/session_manager.dart`
- `lib/core/session/session_repository_impl.dart`
- `lib/core/services/app_startup/app_startup_controller.dart`
- `lib/features/auth/di/auth_module.dart`
- `lib/features/auth/data/datasource/local/dao/user_dao.dart`
- `lib/features/auth/data/model/local/user_local_model.dart`
- `lib/features/user/domain/usecase/get_me_usecase.dart`
- `lib/features/user/data/repository/user_repository_impl.dart`
