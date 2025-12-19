---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [di, getit, modularity]
---

# GetIt DI with Per‑Feature Modules

## Context and Problem Statement

The template needs dependency injection that is lightweight, explicit, and works well with vertical slices. We must wire core services once, then let features register their own datasources, repositories, use cases, and Bloc/Cubits in a modular way.

## Decision Drivers

* Keep wiring explicit and easy to trace.
* Support lazy initialization and test overrides.
* Avoid coupling DI to widget trees.
* Allow feature modules to self‑register dependencies.

## Considered Options

* Use Provider/Riverpod for DI.
* Use a code‑generated DI framework.
* Use GetIt service locator with feature modules (chosen).

## Decision Outcome

Chosen option: **GetIt (`locator`) with per‑feature DI modules**, because it provides simple, explicit wiring and aligns with existing code in `lib/core/di/service_locator.dart`.

Pattern:

* Core DI lives in `setupLocator()` and registers shared services.
* Each feature has `lib/features/<feature>/di/<feature>_module.dart` that registers:
  - datasources (`registerLazySingleton`),
  - repositories (`registerLazySingleton`),
  - use cases (`registerFactory`),
  - Bloc/Cubits (`registerFactory`).
* Features are composed into the app in `setupLocator()` by calling their `register()` methods.

### Consequences

* Good, because dependencies are easy to locate and override in tests.
* Good, because features remain modular and reusable.
* Neutral, because the service‑locator style relies on disciplined registrations.
* Bad, because missing registrations surface at runtime unless guarded by tests/reviews.

### Confirmation

Confirmed when:

* New features add a `<feature>_module.dart` and register dependencies there.
* `setupLocator()` only composes modules and core services (no feature wiring inline).
* Tests can replace dependencies via `locator.registerSingleton` / `resetLocator()`.

