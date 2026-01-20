# System Tree (Where the Session System Lives)

This document answers:

- “Which layer owns what?”
- “Where do I change behavior vs swap implementations?”
- “How do we keep `core/**` independent from `features/**`?”

## Architecture boundary rule

This template enforces a strict boundary:

- `lib/core/**` **must not** import `lib/features/**`
- **Exception:** `lib/core/di/**` composes DI and may import feature modules (`lib/features/*/di/**`).

This is enforced by architecture linting (`custom_lint`), so the system remains **template-grade** and reusable.

## High-level directory ownership

- `lib/core/session/**` — session orchestration (tokens, restore, refresh, logout) and the **interfaces** needed by core to stay independent.
- `lib/core/user/**` — core user entity + user-fetch abstraction.
- `lib/core/services/app_startup/**` — startup hydration gate (runs once on boot; best-effort + safe).
- `lib/core/services/user_context/**` — UI-facing “current user” view model and refresh API.
- `lib/core/network/**` — request-time auth header injection + refresh/retry policy.
- `lib/features/auth/**` — login/logout/refresh flows + adapter implementing `TokenRefresher`.
- `lib/features/user/**` — `GET /me` + local persistence + adapters implementing:
  - `CurrentUserFetcher`
  - `CachedUserStore`

## System tree (key files)

The session system is spread across these paths:

```text
lib/
├─ core/
│  ├─ di/
│  │  └─ service_locator.dart
│  ├─ events/
│  │  ├─ app_event.dart
│  │  └─ app_event_bus.dart
│  ├─ network/
│  │  ├─ api/
│  │  │  └─ api_client.dart
│  │  └─ interceptors/
│  │     └─ auth_token_interceptor.dart
│  ├─ services/
│  │  ├─ app_startup/
│  │  │  └─ app_startup_controller.dart
│  │  └─ user_context/
│  │     ├─ current_user_state.dart
│  │     └─ user_context_service.dart
│  ├─ session/
│  │  ├─ cached_user_store.dart
│  │  ├─ entity/
│  │  │  ├─ auth_session_entity.dart
│  │  │  └─ auth_tokens_entity.dart
│  │  ├─ session_failure.dart
│  │  ├─ session_manager.dart
│  │  ├─ session_repository.dart
│  │  ├─ session_repository_impl.dart
│  │  └─ token_refresher.dart
│  ├─ storage/
│  │  └─ secure/
│  │     └─ token_secure_storage.dart
│  └─ user/
│     ├─ current_user_fetcher.dart
│     └─ entity/
│        └─ user_entity.dart
└─ features/
   ├─ auth/
   │  └─ di/
   │     └─ auth_module.dart
   └─ user/
      ├─ di/
      │  └─ user_module.dart
      ├─ domain/
      │  ├─ repository/
      │  │  └─ user_repository.dart
      │  └─ usecase/
      │     └─ get_me_usecase.dart
      └─ data/
         └─ datasource/
            ├─ remote/
            │  └─ user_remote_datasource.dart
            └─ local/
               ├─ user_local_datasource.dart
               ├─ dao/
               │  └─ user_dao.dart
               └─ model/
                  └─ user_local_model.dart
```

## Responsibility map (class → file → owner)

| Concept | Class / Type | File | Owned by |
|---|---|---|---|
| Session lifecycle | `SessionManager` | `lib/core/session/session_manager.dart` | Core |
| Persist session | `SessionRepository` | `lib/core/session/session_repository.dart` | Core |
| Persist session (impl) | `SessionRepositoryImpl` | `lib/core/session/session_repository_impl.dart` | Core |
| Secure token IO | `TokenSecureStorage` | `lib/core/storage/secure/token_secure_storage.dart` | Core |
| Cached user IO (interface) | `CachedUserStore` | `lib/core/session/cached_user_store.dart` | Core |
| Cached user IO (impl) | `UserLocalDataSource` | `lib/features/user/data/datasource/local/user_local_datasource.dart` | User feature |
| Refresh tokens (interface) | `TokenRefresher` | `lib/core/session/token_refresher.dart` | Core |
| Refresh tokens (impl adapter) | `_AuthRepositoryTokenRefresher` | `lib/features/auth/di/auth_module.dart` | Auth feature |
| Failure semantics | `SessionFailure` | `lib/core/session/session_failure.dart` | Core |
| User identity | `UserEntity` | `lib/core/user/entity/user_entity.dart` | Core |
| Fetch “me” (interface) | `CurrentUserFetcher` | `lib/core/user/current_user_fetcher.dart` | Core |
| Fetch “me” (impl adapter) | `_GetMeCurrentUserFetcher` | `lib/features/user/di/user_module.dart` | User feature |
| Startup hydration | `AppStartupController` | `lib/core/services/app_startup/app_startup_controller.dart` | Core |
| UI current user | `UserContextService` | `lib/core/services/user_context/user_context_service.dart` | Core |
| UI state | `CurrentUserState` | `lib/core/services/user_context/current_user_state.dart` | Core |
| Refresh/retry policy | `AuthTokenInterceptor` | `lib/core/network/interceptors/auth_token_interceptor.dart` | Core |
| Event bus | `AppEventBus` | `lib/core/events/app_event_bus.dart` | Core |
| Session events | `SessionCleared`, `SessionExpired` | `lib/core/events/app_event.dart` | Core |

## Why the system is split this way

This split is intentional to make the template “enterprise safe”:

- `core/**` defines **stable contracts** (`TokenRefresher`, `CachedUserStore`, `CurrentUserFetcher`) and a **single orchestration policy** (`SessionManager`).
- `features/**` implement those contracts however the product needs (API shape, DB schema, caching strategy) **without** requiring core refactors.
- UI consumes **one** surface (`UserContextService`) instead of reading tokens/session in every screen.
