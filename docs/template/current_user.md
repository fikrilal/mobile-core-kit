# Current User (Template Mechanism)

This template provides a **single, safe way** to read the currently signed-in user (“me”) across the app.

Goals:

- Keep UI simple: read `displayName`, `email`, `initials` without wiring session logic per screen.
- Avoid race bugs: cached-user restore and `GET /v1/me` hydration must not leak across account switches.
- Preserve boundaries: `core/**` must not depend on `features/**` (except DI composition).

## The Standard API (What to Use)

Use `UserContextService`:

- Code: `lib/core/runtime/user_context/user_context_service.dart`
- State: `lib/core/runtime/user_context/current_user_state.dart`

It observes `SessionManager.sessionNotifier` and exposes:

- `ValueListenable<CurrentUserState>` (`stateListenable`) for UI binding
- computed helpers:
  - `displayName`
  - `email`
  - `initials`
- refresh entrypoints:
  - `ensureUserFresh()` — returns an existing user if already available, otherwise triggers refresh
  - `refreshUser()` — explicitly calls remote `GET /v1/me` via the core abstraction `CurrentUserFetcher`

## How it works (High Level)

1) **Session lifecycle** is owned by `SessionManager` (tokens + session state):
   - `lib/core/runtime/session/session_manager.dart`
2) **User feature** owns “me” persistence + remote fetching, but core calls it via interfaces:
   - `CurrentUserFetcher` (`lib/core/domain/user/current_user_fetcher.dart`)
   - `CachedUserStore` (`lib/core/domain/session/cached_user_store.dart`)
3) `UserContextService` simply *projects* session state into a stable “current user” view model.

### Status model

`CurrentUserState.status`:

- `signedOut` — no session/tokens
- `authPending` — session exists but user not yet available (tokens restored, waiting for cache or hydration)
- `available` — session has a user

## UI usage (Example)

Use `ValueListenableBuilder` and read the helpers from the service:

```dart
final userContext = locator<UserContextService>();

ValueListenableBuilder<CurrentUserState>(
  valueListenable: userContext.stateListenable,
  builder: (context, state, _) {
    return Column(
      children: [
        AppAvatar(
          displayName: userContext.displayName ?? userContext.email,
          initials: userContext.initials,
        ),
        if (state.isAuthPending) const AppDotWave(),
      ],
    );
  },
);
```

Rule of thumb:

- If you only need to *display* user info: listen to `stateListenable` and read helpers.
- If you need to *guarantee freshness* (e.g. before a user-scoped operation): call `ensureUserFresh()` or `refreshUser()`.

## What NOT to do

- Don’t call `GET /v1/me` directly from screens/widgets.
- Don’t read `SessionManager.sessionNotifier` in feature UI to display user fields.
  - That spreads session semantics everywhere and makes migrations/refactors expensive.
- Don’t store a user object in multiple places (session + UI + local caches) without explicit invalidation rules.

## Scaling: adding user-scoped “slices”

Examples of “slices”:

- unread inbox badge count
- profile completeness
- entitlements/roles

Guidelines:

- Start with feature-owned state (use cases + bloc/cubit) if only one screen needs it.
- If 2+ places need the same user-scoped data, consider a shared slice:
  - Add a template-level slice under `lib/core/runtime/user_context/`
  - Keep core independent of features by depending on **core interfaces**.
  - Invalidate on `SessionCleared` / `SessionExpired`.

This repo intentionally defers `UserDataSlice<T>` until there are at least two real slices to justify it.
