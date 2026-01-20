# Current User Access Proposal (Template-grade, enterprise standard)

**Project:** `mobile-core-kit`  
**Date:** 2026-01-20  
**Status:** Proposal (no code changes yet)

## Context

This repository is a **base/template** for future apps. That changes the bar:

- We need a **default, repeatable pattern** (teams will copy this).
- We should bias toward **long-term scalability and consistency** over the smallest possible change.
- We must still avoid unnecessary complexity: template defaults should be easy to adopt and hard to misuse.

We already persist user data locally after login and on hydration (`GET /me`) via:

- Session persistence: `lib/core/session/session_manager.dart` → `SessionRepository.saveSession(...)`
- Local user cache: `lib/features/auth/data/datasource/local/auth_local_datasource.dart` (sqflite `users` table)
- Startup hydration: `lib/core/services/app_startup/app_startup_controller.dart` → `_getMe()` → `_sessionManager.setUser(user)`

So the data exists and is kept reasonably fresh.

## Problem

Consumer UI (e.g., profile header, settings screens, “Hello, {name}”) needs an ergonomic, reactive way to read **current user display info** (name/email/initials) without:

- Direct DB access (tight coupling + duplication)
- Knowing session internals (`AuthSessionEntity`, token state, “auth pending” semantics)
- Re-implementing “cached-first, refresh later” patterns repeatedly

Right now, the closest “source of truth” is `SessionManager.sessionNotifier`, but it is **too session-shaped** for typical UI usage and doesn’t define a template-level convention for:

- where “current user” lives conceptually
- how other user-scoped caches should behave (TTL, invalidation, session end)
- how consumers should subscribe without learning auth/session internals

## Goals

- **Single source of truth** for current user (no “two competing caches”).
- **Reactive** updates for UI (ValueListenable/Stream-friendly).
- **Clear semantics** for states:
  - signed out
  - authenticated-but-user-not-yet-hydrated (auth pending)
  - user available
- **Low complexity** to start (only what we need today), but **scalable** when we add more “user-scoped” data later.
- **Testable** (easy to fake/mocking in widget + bloc tests).
- **Template consistency:** provide a “blessed” pattern that future features can follow (and tests/docs can reference).

## Non-goals (for now)

- Introducing a reactive database (e.g., Drift) just for this.
- Making sqflite reactive (no DB watchers).
- Building a full “profile domain” or adding new endpoints.

## What “enterprise standard” looks like here

In enterprise Flutter apps, it’s common to have an **Authentication/Session facade** that exposes:

- current auth status
- current user (often nullable)
- a small set of user display helpers (display name / email / initials)

Crucially, it should be a **thin read-optimized facade** over the real source of truth, not a “god service” that does everything.

Our codebase already has the right primitives:

- A session lifecycle orchestrator: `SessionManager` (in-memory + persistence)
- App-wide events for session lifecycle: `SessionExpired` / `SessionCleared` in `lib/core/events/app_event.dart`
- A best-effort “hydrate user” flow on startup: `AppStartupController`

## Decision (recommended, template-standard)

Adopt a slice-based `UserContextService` (or `UserDataService`) as the **template-standard** way to expose:

1) **Current user** (name/email/initials) for regular UI usage  
2) Future **user-scoped cached data** (entitlements, profile completion, preferences, subscription, etc.)

This is the reliable approach because it scales *by default* and prevents every downstream project/team from inventing its own “current user” helper or ad-hoc caching rules.

## Recommended design: `UserContextService` + `UserDataSlice<T>`

### Hard boundaries (so it stays “enterprise clean”)

**`SessionManager` remains the single source of truth for auth/session**
- Owns tokens + login/logout + persistence + session lifecycle.
- Emits session changes via `sessionNotifier`.

**`UserContextService` is a read-optimized facade for user-scoped data**
- Exposes user display info in a UI-friendly shape.
- Coordinates “cache-first + refresh (TTL)” where appropriate.
- Clears in-memory slices on session end.
- Must not contain feature business logic, routing, or UI concerns.
- Must not create a competing persistent store for `me` (delegates to `SessionManager.setUser`).

**Features keep ownership of fetch/persist logic**
- Network + local persistence stays in repositories/use cases.
- `UserContextService` composes them via slices (wiring/invalidation only).

### Suggested location (template-friendly)

Place this under `lib/core/services/` so every cloned project has a consistent convention:

- `lib/core/services/user_context/user_context_service.dart`
- `lib/core/services/user_context/user_context_service_impl.dart`
- `lib/core/services/user_context/user_data_slice.dart`

### Public API (consumer-friendly, minimal but scalable)

```dart
enum CurrentUserStatus { signedOut, authPending, available }

@immutable
class CurrentUserState {
  final CurrentUserStatus status;
  final UserEntity? user;
  const CurrentUserState(this.status, this.user);
}

abstract class UserContextService extends ValueListenable<CurrentUserState> {
  CurrentUserState get state;
  UserEntity? get user;

  // Derived convenience for UI
  String? get displayName; // e.g., "First Last", fallback to email
  String? get email;
  String? get initials; // use `NameUtils.initialsFrom(...)`

  /// Emits cached if available, refreshes when stale.
  Future<void> ensureUserFresh();

  /// Force refresh from network (single-flight).
  Future<void> refreshUser();

  /// Clears caches when session ends.
  void clear();
}
```

**Why `ValueListenable`?** This repo already uses it for app-wide controllers (`ThemeModeController`, `LocaleController`), and it composes cleanly with `ValueListenableBuilder` in widgets without introducing new state management.

### `me/current user` semantics (reliability rules)

`UserContextService` should **derive** current user from `SessionManager` and never invent its own authority:

- `signedOut`: `SessionManager.session == null`
- `authPending`: session exists but `session.user == null` (tokens restored, user hydration pending)
- `available`: session exists and `session.user != null`

This keeps user visibility coupled to session validity and prevents “stale user shown while logged out”.

### Refresh policy (recommended defaults)

For template maturity, `UserContextService` should support both:

- `ensureUserFresh()` — safe to call from UI; cache-first; refreshes only when stale
- `refreshUser()` — explicit force refresh (still single-flight)

Recommended default TTL for `me`: **12–24 hours**.

- User identity changes rarely; we don’t want noisy network calls.
- A daily-ish refresh avoids long-lived stale data in apps where profile can change server-side.
- Downstream projects can tighten or disable TTL depending on requirements (subscription-heavy apps may refresh more often).

### Refresh mechanics (avoid subtle enterprise bugs)

`refreshUser()` should be implemented as:

- **Single-flight** (dedupe concurrent refresh calls).
- **Race-safe** across session changes:
  - capture a stable “session key” at refresh start (e.g., access token or session id),
  - after the network call returns, only apply the result if the current session still matches.
- **Delegated persistence**:
  - call `GetMeUseCase` (feature use case),
  - on success call `SessionManager.setUser(user)` (so the persisted cache stays consistent),
  - let `SessionManager.sessionNotifier` drive UI updates.
- **Failure behavior**:
  - keep last known good user visible,
  - do not throw into UI by default (log/telemetry only).

### Slice pattern (generic, reusable for future scaling)

Define a generic helper similar to the old project’s `UserDataSlice<T>`:

- `loadCached(): Future<T?>` (local DB, SharedPrefs, etc.)
- `fetchFresh(): Future<T?>` (network)
- `ttl` (optional, default conservative)
- `clear()` on session end
- “single-flight” refresh to avoid thrash

Template guardrails for slices:

- Each slice must have **one responsibility** (e.g., `entitlements`, not “all profile stuff”).
- Slices should **not** depend on presentation/UI.
- Slices should be cleared on `SessionCleared` / `SessionExpired`.
- Slices should swallow transient failures and keep last known good value unless the product explicitly needs error surfaces.

This slice becomes the template-level building block for any user-scoped cached data.

### Data flow (current user)

1) `SessionManager` emits session changes (login/logout/hydration) via `sessionNotifier`.
2) `UserContextServiceImpl` listens and updates its `CurrentUserState` + derived helpers.
3) `ensureUserFresh()` / `refreshUser()` uses `GetMeUseCase` and delegates persistence to `SessionManager.setUser(user)` to keep a single source of truth.
4) On `SessionCleared`/`SessionExpired`, `UserContextService.clear()` resets slices (and `SessionManager` already clears persistence).

### How consumers use it (example pattern)

- UI reads `UserContextService` (not `SessionManager`) to avoid session internals in feature code.
- Widgets can follow the same “controller injection” pattern as `LocaleSettingTile`/`ThemeModeSettingTile`:
  - default to `locator<UserContextService>()`
  - allow passing a controller for test determinism.

Example (Profile header):

```dart
final userContext = locator<UserContextService>();

return ValueListenableBuilder<CurrentUserState>(
  valueListenable: userContext,
  builder: (context, state, _) {
    final name = userContext.displayName ?? userContext.email ?? '—';
    return AppText.headlineMedium(name);
  },
);
```

## Naming guidance

Avoid names that invite “do everything”:

- Prefer: `UserContextService`, `CurrentUserState`, `UserDataSlice<T>`, `<Thing>Slice`
- Avoid: `UserService` (too broad), `UserManager` (ambiguous ownership), `AppState` (vague)

## Template-level architecture alignment (recommended improvement)

Right now, cached user persistence lives under `features/auth/...` (`AuthLocalDataSource` + `UserDao`). For a template repo, a cleaner boundary is:

- `auth` owns **tokens + login/logout**
- `user` owns **user persistence + “me” model**

Proposed (future) refactor for maturity:

- Move `UserDao` + `UserLocalModel` into `lib/features/user/data/datasource/local/`
- Introduce `GetCachedMeUseCase` (or `UserRepository.getCachedMe()`) so user caching is owned by the user feature
- Keep `SessionManager` calling an abstract `CachedUserStore` interface (defined in `core/`) to avoid `core` depending on `auth` implementation details

This isn’t required to ship the user context layer, but it is a template-quality improvement that reduces cross-feature coupling.

## Scalability plan (phased, template-friendly)

### Phase 1 — Establish the standard

- Add `UserContextService` + `UserDataSlice<T>` in `lib/core/services/user_context/`.
- Implement the `me` slice:
  - cached: existing DB (via current `SessionRepository.loadCachedUser()` or the refactor above)
  - fresh: `GetMeUseCase` → `SessionManager.setUser(user)`
- Document “how to consume current user” for UI/widgets (1–2 snippets).

### Phase 2 — Grow without rewriting

When future projects add user-scoped aggregates, they add new slices:

- `entitlements` (subscription/roles)
- `profileCompletion`
- `userPreferences` (server-synced)
- `featureFlagsForUser`

Each slice has its own cache + refresh semantics, but shares the same template helper and session-end invalidation.

### Phase 3 — Optional upgrade path

If apps need true reactive local storage:

- Replace sqflite reads with a reactive DB (e.g., Drift)
- Update slice `loadCached` to subscribe/watch instead of polling
- Keep the `UserContextService` API stable for consumers

## Suggested repository changes (if we implement this)

1) New core service + helper:
   - `lib/core/services/user_context/user_context_service.dart`
   - `lib/core/services/user_context/user_context_service_impl.dart`
   - `lib/core/services/user_context/user_data_slice.dart`
2) DI wiring:
   - register in `lib/core/di/service_locator.dart` as a lazy singleton
   - clear on `SessionCleared` / `SessionExpired` (via `AppEventBus`) if needed
3) Docs:
   - add an engineering doc or short section under an existing one (e.g. session/auth docs) explaining “Current user access pattern”

## Testing strategy (template expectation)

- `UserDataSlice<T>` unit tests (fast, deterministic):
  - returns cached value before refresh
  - refreshes only when stale (TTL)
  - single-flight refresh (N callers → 1 network call)
  - clear on session end
- `UserContextServiceImpl` unit tests:
  - `SessionManager.sessionNotifier` mapping to `CurrentUserStatus`
  - `displayName/email/initials` derivation rules
  - `refreshUser()` race guard (doesn’t apply results after logout/account switch)
- Widget tests:
  - prefer controller injection (pass a fake `UserContextService`) to avoid global locator state in tests.

## Risks + mitigations (template-specific)

- **Risk:** Service becomes a “god object”.  
  **Mitigation:** enforce “slice-only” composition; no feature-specific logic in `UserContextServiceImpl` beyond wiring/invalidation.

- **Risk:** Two sources of truth (SessionManager vs user context).  
  **Mitigation:** user context never persists directly; it delegates to `SessionManager.setUser` and listens to `SessionManager` for state.

- **Risk:** Too much abstraction for small apps.  
  **Mitigation:** default implementation ships with only the `me` slice; additional slices are opt-in and follow the same pattern.

## Open questions (to confirm before implementation)

1) Should the user context layer also expose a `ValueListenable<UserEntity?>` for very simple use cases, in addition to the richer `CurrentUserState`?
2) What TTL should the template default to for `me` refresh (e.g., 12h vs 24h vs “no TTL, manual only”)?
3) Do we want `UserContextService` to automatically refresh on app resume / token refresh, or keep refresh explicit?

---

## Appendix — Why this still stays clean

Even though this looks like “more code”, it is **lower total complexity** for a template:

- One standard pattern beats many inconsistent helpers.
- “Slice” composition makes growth predictable and testable.
- UI code stays dumb and consistent: `ValueListenableBuilder(userContext, ...)` + derived getters.
