# Core Domain

`lib/core/domain` is the app's shared business kernel.

It exists for **pure, cross-cutting domain contracts and shared business
types** that multiple parts of the app depend on, especially:

- `lib/core/runtime/**`
- feature adapters that implement core ports
- app-level orchestration that must not depend on feature internals

## What belongs here

Put code in `core/domain` only if it is all of these:

1. Pure Dart
2. Cross-feature or app-foundational
3. Stable enough to act as a shared contract
4. Independent of any one product workflow

Typical contents:

- ports / interfaces
- shared domain entities
- shared failure semantics
- session and current-user abstractions

Examples in this repo:

- `session/session_repository.dart`
- `session/token_refresher.dart`
- `session/cached_user_store.dart`
- `user/current_user_fetcher.dart`
- `session/entity/auth_session_entity.dart`
- `user/entity/user_entity.dart`
- `auth/auth_failure.dart`

## What does not belong here

Do not put code here if it is owned by a single feature or workflow.

Keep these out of `core/domain`:

- remote/local datasources
- DTOs / API models
- repository implementations
- use cases tied to one feature workflow
- DI modules
- Flutter/UI code
- Dio, sqflite, shared_preferences, GetIt, or platform integrations

Examples that should stay in features:

- profile editing
- active sessions screen logic
- account deletion flow
- profile image upload flow

Those belong under `features/<feature>/domain` or the relevant subfeature.

## Dependency rules

`core/domain` is an inward-facing boundary.

Rules:

1. `core/domain` must not import `features/**`
2. `core/domain` must not import `core/runtime`, `core/infra`, or `core/platform`
3. `core/runtime` may depend on `core/domain`
4. features may implement `core/domain` ports
5. implementations live outside `core/domain`

Example:

- `core/domain/user/current_user_fetcher.dart` defines the port
- `features/account/adapters/current_user_fetcher_adapter.dart` implements it
- `core/runtime/user_context/user_context_service.dart` depends only on the port

## Decision checklist

Before adding something to `core/domain`, ask:

1. Is this needed by more than one feature or by app runtime?
2. Is this a contract or shared business type, not an implementation?
3. Can it stay pure Dart with no infra/UI dependencies?
4. Would it still make sense if the owning feature were moved or replaced?

If any answer is "no", it probably does not belong in `core/domain`.

## Anti-pattern

`core/domain` is **not** a dumping ground for code that merely looks reusable.

If code is only shared because one feature is currently large, prefer:

- `features/<feature>/domain`
- `features/<feature>/subfeatures/<slice>/domain`

Move code into `core/domain` only when it is truly foundational.

## Related docs

- `docs/engineering/project_architecture.md`
- `docs/template/current_user.md`
- `docs/core/session/README.md`
