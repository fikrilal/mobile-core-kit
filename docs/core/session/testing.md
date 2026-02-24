# Testing & Change Safety

This system has “looks fine in the happy path” traps. The template includes **must-have tests** to prevent regressions.

Run everything:

```bash
dart run tool/verify.dart --env dev
```

---

## What we test (and why)

### Session persistence correctness

Goal: ensure tokens + cached user behave deterministically across app restarts and edge cases.

Covered by:

- `test/core/runtime/session/session_repository_impl_test.dart`

Key assertions:

- `saveSession` persists secure tokens
- `saveSession` clears cached user when saving tokens-only session (stale user protection)
- `loadSession` returns null if any required token field is missing
- `clearSession` clears secure tokens + cached user

### Session lifecycle + race guards

Goal: ensure async restores/refresh cannot overwrite a new session.

Covered by:

- `test/core/runtime/session/session_manager_test.dart`
- `test/core/runtime/session/session_manager_refresh_logout_persistence_test.dart`

Key assertions:

- `init()` restores session tokens and emits session
- `restoreCachedUserIfNeeded()` applies cached user only if access token is unchanged
- `refreshTokens()` does not apply refreshed tokens after logout/account switch
- unauthenticated refresh failure triggers logout and clears persistence

### Startup hydration safety

Goal: ensure startup always becomes ready and hydration is conservative, single-flight, and safe.

Covered by:

- `test/core/runtime/startup/app_startup_controller_test.dart`

Key assertions:

- startup does not block forever (timeouts + fail-open defaults)
- hydration only runs after onboarding complete
- hydration is cooldown-throttled on repeated online signals
- hydration logs out only on unauthenticated failures
- hydration result is ignored if session changes mid-flight (refresh-token guard)

### UI-facing current user API

Goal: ensure UI consumes a stable API and refresh semantics are correct.

Covered by:

- `test/core/runtime/user_context/user_context_service_test.dart`

Key assertions:

- state transitions: signedOut → authPending → available
- `ensureUserFresh()` returns existing user without calling network
- `refreshUser()` is single-flight
- `refreshUser()` ignores result if session changes mid-flight
- default unauthenticated refresh triggers logout

---

## How to add new behavior safely (checklist)

### If you change token refresh behavior

Where:

- `lib/core/infra/network/interceptors/auth_token_interceptor.dart`
- `lib/core/runtime/session/session_manager.dart`
- `lib/features/auth/di/auth_module.dart` (adapter mapping)

Checklist:

- [ ] keep single-flight refresh behavior (or update tests)
- [ ] ensure write retry still requires idempotency key
- [ ] ensure unauthenticated refresh failure logs out and clears cached user
- [ ] update the contract doc if policy changes:
  - `docs/contracts/auth/auth_refresh_and_retry_contract.md`

### If you change cached user storage

Where:

- core contract: `lib/core/domain/session/cached_user_store.dart`
- implementation: `lib/features/user/data/datasource/local/user_local_datasource.dart`
- db bootstrap: `lib/core/infra/database/app_database.dart`, `lib/features/user/di/user_module.dart`

Checklist:

- [ ] `SessionRepositoryImpl.saveSession` still clears cached user when session.user is null
- [ ] table creation is registered via `AppDatabase.registerOnCreate`
- [ ] defensive `createTable()` calls remain safe (or document removal)
- [ ] update tests:
  - `test/features/user/data/datasource/local/user_local_datasource_test.dart`

### If you change hydration logic

Where:

- `lib/core/runtime/startup/app_startup_controller.dart`
- `lib/core/domain/user/current_user_fetcher.dart`
- `lib/features/user/di/user_module.dart` (adapter mapping)

Checklist:

- [ ] hydration remains single-flight
- [ ] hydration remains guarded by session key (refresh token)
- [ ] transient failures do not logout
- [ ] cooldown prevents request spam on connectivity flaps

### If you change UI current user semantics

Where:

- `lib/core/runtime/user_context/user_context_service.dart`
- `lib/core/runtime/user_context/current_user_state.dart`

Checklist:

- [ ] status mapping stays consistent (`signedOut/authPending/available`)
- [ ] refresh remains single-flight and guarded
- [ ] session lifecycle events reset derived state (SessionCleared/Expired)
- [ ] UI continues to use this service (do not regress to reading `SessionManager` everywhere)

---

## Debugging tips

When things go wrong, these questions narrow it down fast:

1) Is there a session?
   - Check `SessionManager.sessionNotifier.value`
2) Is the session auth pending?
   - tokens exist but user is null
3) Did cached user restore run and get ignored?
   - access token changed mid-flight, or user already set
4) Did hydration run?
   - onboarding gate, cooldown gate, offline state
5) Did token refresh happen and rotate the session key?
   - could invalidate in-flight hydration/refresh results

Enable logging (dev builds) and inspect:

- session init logs (`SessionManager`)
- hydration logs (`AppStartupController`)
- interceptor logs (`AuthTokenInterceptor`)
