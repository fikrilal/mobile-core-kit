# Core Session System (Engineering Docs)

This folder documents the **end-to-end session + current-user (“me”) system** in this template:

- **Tokens** (secure storage)
- **Session lifecycle** (restore/login/logout/refresh)
- **Cached user** (sqflite) and safe restore semantics
- **Startup hydration** (`GET /me` when needed)
- **Request-time refresh + retry** (Dio interceptor)
- **UI consumption** (`UserContextService`)

These docs are intentionally **detailed** because this repository is a **template** and this system is easy to get subtly wrong.

## Reading order

1) `docs/core/session/system_tree.md` — where the code lives (core vs features), at a glance  
2) `docs/core/session/components.md` — responsibilities and invariants per class/file  
3) `docs/core/session/flows.md` — end-to-end flows with mermaid diagrams  
4) `docs/core/session/testing.md` — how to test and how to extend safely  

## Quick pointers (most referenced code)

Core:

- Session orchestration: `lib/core/runtime/session/session_manager.dart`
- Persistence boundary: `lib/core/domain/session/session_repository.dart`
- Persistence implementation: `lib/core/runtime/session/session_repository_impl.dart`
- Token refresh abstraction: `lib/core/domain/session/token_refresher.dart`
- Failure semantics: `lib/core/domain/session/session_failure.dart`
- Cached user abstraction: `lib/core/domain/session/cached_user_store.dart`
- Current user fetch abstraction: `lib/core/domain/user/current_user_fetcher.dart`
- Startup hydration: `lib/core/runtime/startup/app_startup_controller.dart`
- UI-friendly current user: `lib/core/runtime/user_context/user_context_service.dart`
- Network refresh + retry: `lib/core/infra/network/interceptors/auth_token_interceptor.dart`

Feature adapters (implement core abstractions):

- Token refresh adapter: `lib/features/auth/di/auth_module.dart`
- Cached user + `GET /me` adapters: `lib/features/user/di/user_module.dart`

