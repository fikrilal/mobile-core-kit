# Core Runtime Session

`lib/core/runtime/session` owns app-level session orchestration.

This folder is where runtime code coordinates authenticated session lifecycle
using contracts from `lib/core/domain/session`.

## What belongs here

- session orchestration services, such as `SessionManager`
- runtime implementations that coordinate secure storage, cached user state,
  token refresh, and session clearing
- code that reacts to session-expiry conditions at app-runtime level

## What does not belong here

- auth feature use cases such as login, register, password reset, or remote
  logout APIs
- feature UI code
- implementations of auth-specific ports owned by a feature

## Boundary rule

`core/runtime/session` may depend on:

- `core/domain/session`
- `core/runtime/events`
- storage/runtime infrastructure needed to persist session state

It should not own auth feature behavior. Features may provide adapters that
runtime consumes through `core/domain` ports, for example:

- `TokenRefresher` implemented by `features/auth`

## Related docs

- `docs/core/session/README.md`
- `docs/engineering/project_architecture.md`
- `lib/core/domain/README.md`
