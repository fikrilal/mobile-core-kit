# Components & Responsibilities (Deep Dive)

This document describes the *contracts* and *responsibilities* of each component in the session system.

If you only need the big picture: see `docs/core/session/flows.md`.

---

## Glossary (shared vocabulary)

**Session**
- In-memory representation of authentication state: tokens + (optional) user.
- In this template: `AuthSessionEntity(tokens, user?)`.

**Tokens**
- Access token + refresh token + metadata (`expiresIn`, computed `expiresAt`).
- Persisted in **secure storage**, never in sqflite.

**Auth pending**
- Session exists (tokens present) but `user == null`.
- Typical on cold start: tokens restored first, user restored later from cache or hydrated via `GET /me`.

**Cached user**
- Local copy of “me” stored in sqflite to avoid blocking UI on `GET /me` and to enable fast startup.

**Hydration**
- Fetching “me” from the server (`GET /me`) to populate the session user.

**Session key**
- A stable identifier used to guard against race conditions (logout/account switch) while async work is in-flight.
- This template uses the **refresh token** as a practical session key for hydration + user refresh,
  and the **access token** for cached-user restore (cheap + available at restore time).

---

## Core session layer

### `SessionManager`

**File:** `lib/core/session/session_manager.dart`

**Role:** the single source of truth for session state within the process.

**Owns:**

- In-memory session (`_currentSession`)
- Broadcasting changes:
  - `ValueListenable<AuthSessionEntity?> sessionNotifier` (UI/services)
  - `Stream<AuthSessionEntity?> stream` (rarely needed; for integration or advanced observers)
- High-level operations:
  - `init()` — restore persisted session tokens (best-effort)
  - `restoreCachedUserIfNeeded()` — best-effort cached-user restore, non-blocking
  - `login(AuthSessionEntity)` — persist tokens + user (if present)
  - `setUser(UserEntity)` — update user inside current session and persist
  - `refreshTokens()` — refresh access token using refresh token (logout on unauthenticated)
  - `logout()` — clear tokens + cached user and publish `SessionCleared`

**Does NOT own:**

- HTTP retry policy → owned by `AuthTokenInterceptor`
- “current user” presentation helpers → owned by `UserContextService`
- “me” fetching details → owned by user feature via `CurrentUserFetcher`

**Concurrency and race guards:**

- `init()` is single-flight via `_initFuture`.
- `restoreCachedUserIfNeeded()` is single-flight via `_restoreCachedUserFuture`.
- Cached-user restore uses a guard:
  - capture `accessTokenAtStart`
  - apply cached user only if `latest.tokens.accessToken == accessTokenAtStart`
- Token refresh uses a guard:
  - capture `refreshTokenAtStart`
  - persist refreshed tokens only if current session still has same refresh token

**Events:**

- `logout()` publishes `SessionCleared(reason: ...)` after local clear.
- `refreshTokens()` publishes `SessionExpired(reason: 'refresh_failed')` *before* logout on unauthenticated refresh failures.

Why publish both?

- `SessionExpired` communicates “session ended due to auth expiry” (useful for telemetry/UI policy).
- `SessionCleared` is the canonical “session is now cleared” signal; consumers should treat it as the final state transition.

### `SessionRepository` (interface)

**File:** `lib/core/session/session_repository.dart`

**Role:** persistence boundary for session data.

**Contract:**

- `saveSession(session)` must persist tokens and user cache consistently.
- `loadSession()` must return `null` if persisted state is incomplete/unusable.
- `loadCachedUser()` returns cached “me” (or null).
- `clearSession()` clears both secure tokens and cached user.

### `SessionRepositoryImpl` (implementation)

**File:** `lib/core/session/session_repository_impl.dart`

**Role:** concrete persistence policy used by `SessionManager`.

**Uses:**

- Secure storage: `TokenSecureStorage`
- Cached user interface: `CachedUserStore`

**Important invariant (stale user protection):**

- When saving a session where `session.user == null`, it **clears** cached user.

This prevents a common bug:

- tokens restored but user not yet hydrated → UI shows stale name/email from a previous account.

### `TokenSecureStorage`

**File:** `lib/core/storage/secure/token_secure_storage.dart`

**Role:** isolated secure storage wrapper with platform-safe configuration.

**Notes:**

- Uses `FlutterSecureStorage` with platform options:
  - Android: `resetOnError`, `migrateOnAlgorithmChange`
  - iOS: `unlocked_this_device`, non-synchronizable
- Reads tokens via `readAll()` with a fallback to per-key reads if plugin fails.
  - This is a startup-safety decision: “fail open to signed-out” instead of crashing startup.

### `SessionFailure`

**File:** `lib/core/session/session_failure.dart`

**Role:** a core-level failure type used only for decisions needed by session orchestration.

Key point:

- This is intentionally **smaller** than feature failure types (e.g., auth/user failures).
- Core doesn’t need “emailTaken” or “validation error”; it needs a small set of semantics:
  - `unauthenticated` (logout or clear)
  - `network` (retry later; do not logout)
  - `tooManyRequests` (cooldown/backoff; do not logout)
  - `serverError` (do not logout by default)
  - `unexpected`

This keeps `core/**` stable while features evolve.

### `TokenRefresher`

**File:** `lib/core/session/token_refresher.dart`

**Role:** core abstraction for refreshing tokens, implemented by the auth feature.

Contract:

- Input: refresh token string
- Output: `Either<SessionFailure, AuthTokensEntity>`

Core uses this inside `SessionManager.refreshTokens()` and does not care whether the implementation uses:

- REST
- GraphQL
- Firebase
- Cognito
- etc.

---

## Core user abstractions

### `UserEntity`

**File:** `lib/core/user/entity/user_entity.dart`

**Role:** core domain identity object for “me”.

Notes:

- This is intentionally template-level because “me” is cross-cutting (profile header, settings, feature gating).
- Product teams may extend fields, but should keep mapping/persistence consistent.

### `CurrentUserFetcher`

**File:** `lib/core/user/current_user_fetcher.dart`

**Role:** core abstraction for fetching “me” from remote source.

Key design choice:

- Core startup + `UserContextService` depend on this interface to avoid `core → features` imports.

---

## Startup hydration layer

### `AppStartupController`

**File:** `lib/core/services/app_startup/app_startup_controller.dart`

**Role:** determines when the app becomes “startup ready”, and performs best-effort user hydration when needed.

Responsibilities:

- Restore session tokens (timeout-protected)
- Determine onboarding requirement (timeout-protected)
- Mark startup ready (must always complete)
- Trigger hydration **only when**:
  - onboarding is complete
  - session is `authPending` (tokens exist, user not present)
  - device is online (or transitions offline → online)
  - hydration cooldown allows it (avoid spam)
  - only one hydration in-flight (single-flight guard)

Race guard:

- Captures `refreshTokenAtStart` and ignores hydration result if refresh token changes mid-flight.

Why ignore if refresh token changes?

- It signals logout, account switch, or token rotation; applying “me” after that would be wrong.

---

## UI-facing current user layer

### `UserContextService`

**File:** `lib/core/services/user_context/user_context_service.dart`

**Role:** a small template-level service that exposes **safe, UI-friendly access** to the current user.

Responsibilities:

- Observe `SessionManager.sessionNotifier` and project it into:
  - `CurrentUserStatus.signedOut` / `authPending` / `available`
- Provide computed UI helpers:
  - `displayName`, `email`, `initials`
- Provide an explicit refresh API:
  - `ensureUserFresh()` (no-op if user exists; otherwise refresh)
  - `refreshUser()` (calls `CurrentUserFetcher.fetch()`, with single-flight + race guard)
- Reset derived state on session lifecycle events:
  - `SessionCleared`
  - `SessionExpired`

What it explicitly does *not* do:

- It does not own session lifecycle (no implicit login/logout).
- It does not do periodic refresh; it only refreshes on explicit calls.

Concurrency details (`refreshUser()`):

- Single-flight: concurrent refresh calls share the same future when session key is unchanged.
- Race guard: captures `refreshTokenAtStart` and ignores result if the session changes mid-flight.
- Default unauth policy: if refresh returns unauthenticated, it logs out (`SessionManager.logout`).

### `CurrentUserState`

**File:** `lib/core/services/user_context/current_user_state.dart`

**Role:** immutable state snapshot for `UserContextService`.

Fields:

- `status` (signedOut/authPending/available)
- `user` (nullable)
- `isRefreshing` (bool)
- `lastFailure` (nullable `SessionFailure`)
- `lastRefreshedAt` (nullable `DateTime`)

Why keep `lastFailure/lastRefreshedAt`?

- For UI and telemetry: you can show “tap to retry”, debug “why is user missing”, etc.
- Without forcing every feature to manage its own “me hydration” state.

---

## Network refresh + retry policy

### `ApiClient` (interceptor composition)

**File:** `lib/core/network/api/api_client.dart`

Important because ordering matters:

1) BaseUrl
2) Header
3) **AuthTokenInterceptor** (auth header + refresh/retry)
4) Logging
5) Error mapping

### `AuthTokenInterceptor`

**File:** `lib/core/network/interceptors/auth_token_interceptor.dart`

Role:

- Adds `Authorization: Bearer <token>` for requests that require auth.
- Refreshes tokens when needed (preflight and/or on 401).
- Retries eligible requests after refresh succeeds.

Key policies:

- `requiresAuth` default is `true` unless explicitly set to `false`.
- Retry rules:
  - GET/HEAD: retryable after refresh
  - writes (POST/PUT/PATCH/DELETE): retryable only if an `Idempotency-Key` header exists
  - can be explicitly disabled via `allowAuthRetry: false`
- Single-flight refresh:
  - `_refreshCompleter` dedupes refresh across concurrent requests.
- Preflight refresh:
  - If token is “expiring soon” and the request has not been retried, it attempts refresh best-effort before attaching Authorization.

Contract alignment:

- Backend expectations and idempotency requirements are documented in:
  - `docs/contracts/auth/auth_refresh_and_retry_contract.md`

---

## Feature adapters (how core stays independent)

### Auth feature adapter: `_AuthRepositoryTokenRefresher`

**File:** `lib/features/auth/di/auth_module.dart`

Role:

- Implements `TokenRefresher` by calling `AuthRepository.refreshToken(...)`
- Maps `AuthFailure` → `SessionFailure`

### User feature adapter: `_GetMeCurrentUserFetcher`

**File:** `lib/features/user/di/user_module.dart`

Role:

- Implements `CurrentUserFetcher` by calling `GetMeUseCase`
- Maps `AuthFailure` → `SessionFailure`

### User feature adapter: `UserLocalDataSource` (implements `CachedUserStore`)

**File:** `lib/features/user/data/datasource/local/user_local_datasource.dart`

Role:

- Implements `CachedUserStore` so core can persist cached “me”.

Important note:

- It calls `dao.createTable()` defensively even though the table is registered via `AppDatabase.registerOnCreate`.
- This is deliberate: it makes tests and “first run after schema change” scenarios more robust.

---

## Database bootstrap (relevant to cached user)

### `AppDatabase`

**File:** `lib/core/database/app_database.dart`

Role:

- Owns sqflite instance and centralizes schema registration.

Session system relies on:

- User feature calling `AppDatabase.registerOnCreate(...)` to register the `users` table creation task.

Testing helper:

- `DbBasePathProvider basePathOverride` exists to avoid platform-channel directory lookups in tests.

