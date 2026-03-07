# Auth Feature

`features/auth` is one cohesive bounded context, but it is not flat anymore.

The auth feature uses presentation-first subfeatures:

- shared data and domain remain at the feature root
- workflow-specific presentation lives under `subfeatures/`

## Why

Auth has multiple user journeys:

- sign in
- registration
- email verification
- password recovery
- credential management
- sign out

Those workflows are numerous enough to make a flat `presentation/` tree hard to
navigate, but the feature still shares one cohesive auth data/domain surface.

That means:

- subfeatures help presentation maintainability
- full vertical slice duplication would be unnecessary today

## Current structure

- `data/` and `domain/` stay shared
- `subfeatures/*/presentation/` owns pages, cubits, and local presentation
  state per workflow
- `di/auth_module.dart` remains the single auth DI entrypoint
- `adapters/` contains explicit bridges from auth to core ports

## Boundary note

Auth owns auth lifecycle behavior. Core runtime owns session orchestration.

Example split:

- auth provides `TokenRefresher` through an adapter
- core runtime owns `SessionManager`

## Related docs

- `docs/engineering/project_architecture.md`
- `ADR/records/0009-graduated-feature-decomposition.md`
