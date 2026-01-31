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

- `lib/core/domain/session/**` — session entities + ports (persist, refresh, logout policy).
- `lib/core/runtime/session/**` — session orchestration (restore/login/logout/refresh).
- `lib/core/domain/user/**` — user identity entities + “fetch me” port.
- `lib/core/runtime/startup/**` — startup hydration gate (runs once on boot; best-effort + safe).
- `lib/core/runtime/user_context/**` — UI-facing “current user” view model and refresh API.
- `lib/core/runtime/events/**` — app-level event bus + event types.
- `lib/core/infra/network/**` — request-time auth header injection + refresh/retry policy.
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
│  ├─ domain/
│  │  ├─ session/
│  │  │  ├─ entity/
│  │  │  │  ├─ auth_session_entity.dart
│  │  │  │  └─ auth_tokens_entity.dart
│  │  │  ├─ session_failure.dart
│  │  │  ├─ session_repository.dart
│  │  │  └─ token_refresher.dart
│  │  └─ user/
│  │     ├─ current_user_fetcher.dart
│  │     └─ entity/
│  │        └─ user_entity.dart
│  ├─ infra/
│  │  ├─ network/
│  │  │  ├─ api/
│  │  │  │  └─ api_client.dart
│  │  │  └─ interceptors/
│  │  │     └─ auth_token_interceptor.dart
│  │  └─ storage/
│  │     └─ secure/
│  │        └─ token_secure_storage.dart
│  └─ runtime/
│     ├─ events/
│     │  ├─ app_event.dart
│     │  └─ app_event_bus.dart
│     ├─ startup/
│     │  └─ app_startup_controller.dart
│     ├─ user_context/
│     │  ├─ current_user_state.dart
│     │  └─ user_context_service.dart
│     └─ session/
│        ├─ session_manager.dart
│        └─ session_repository_impl.dart
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
| Session lifecycle | `SessionManager` | `lib/core/runtime/session/session_manager.dart` | Core |
| Persist session | `SessionRepository` | `lib/core/domain/session/session_repository.dart` | Core |
| Persist session (impl) | `SessionRepositoryImpl` | `lib/core/runtime/session/session_repository_impl.dart` | Core |
| Secure token IO | `TokenSecureStorage` | `lib/core/infra/storage/secure/token_secure_storage.dart` | Core |
| Cached user IO (interface) | `CachedUserStore` | `lib/core/domain/session/cached_user_store.dart` | Core |
| Cached user IO (impl) | `UserLocalDataSource` | `lib/features/user/data/datasource/local/user_local_datasource.dart` | User feature |
| Refresh tokens (interface) | `TokenRefresher` | `lib/core/domain/session/token_refresher.dart` | Core |
| Refresh tokens (impl adapter) | `_AuthRepositoryTokenRefresher` | `lib/features/auth/di/auth_module.dart` | Auth feature |
| Failure semantics | `SessionFailure` | `lib/core/domain/session/session_failure.dart` | Core |
| User identity | `UserEntity` | `lib/core/domain/user/entity/user_entity.dart` | Core |
| Fetch “me” (interface) | `CurrentUserFetcher` | `lib/core/domain/user/current_user_fetcher.dart` | Core |
| Fetch “me” (impl adapter) | `_GetMeCurrentUserFetcher` | `lib/features/user/di/user_module.dart` | User feature |
| Startup hydration | `AppStartupController` | `lib/core/runtime/startup/app_startup_controller.dart` | Core |
| UI current user | `UserContextService` | `lib/core/runtime/user_context/user_context_service.dart` | Core |
| UI state | `CurrentUserState` | `lib/core/runtime/user_context/current_user_state.dart` | Core |
| Refresh/retry policy | `AuthTokenInterceptor` | `lib/core/infra/network/interceptors/auth_token_interceptor.dart` | Core |
| Event bus | `AppEventBus` | `lib/core/runtime/events/app_event_bus.dart` | Core |
| Session events | `SessionCleared`, `SessionExpired` | `lib/core/runtime/events/app_event.dart` | Core |

## Why the system is split this way

This split is intentional to make the template “enterprise safe”:

- `core/**` defines **stable contracts** (`TokenRefresher`, `CachedUserStore`, `CurrentUserFetcher`) and a **single orchestration policy** (`SessionManager`).
- `features/**` implement those contracts however the product needs (API shape, DB schema, caching strategy) **without** requiring core refactors.
- UI consumes **one** surface (`UserContextService`) instead of reading tokens/session in every screen.
