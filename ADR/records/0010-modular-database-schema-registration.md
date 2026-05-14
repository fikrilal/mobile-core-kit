---
status: accepted
date: 2026-05-14
decision-makers: Fikri, Codex
consulted: none
informed: future maintainers
scope: template
tags: [database, schema, di, architecture]
tracking: null
---

# Use Modular Database Schema Registration via the Composition Root

## Context and Problem Statement

Local persistence tables are owned by feature data layers, but database schema
registration must happen before the shared `AppDatabase` is opened. Hiding table
registration inside unrelated feature dependency modules makes the startup
contract harder to review and easier to miss as local features grow.

## Decision Drivers

* Keep `core/infra` feature-agnostic.
* Preserve feature ownership of feature-owned tables and DAOs.
* Make schema registration run during startup, not page or route activation.
* Avoid a heavier schema framework until migrations and cross-feature ordering
  require it.

## Considered Options

* Keep schema registration inside feature service modules.
* Centralize all schema details in `core/infra/database`.
* Use modular feature-owned schema registration orchestrated by `core/di`.

## Decision Outcome

Chosen option: "Use modular feature-owned schema registration orchestrated by
`core/di`", because it makes startup ordering explicit without making
`core/infra` depend on feature DAO classes.

Pattern:

* Each feature that owns local tables exposes a schema registration module under
  `lib/features/<feature>/di/`.
* `lib/core/di/registrars/database_schema_registrar.dart` composes those schema
  modules during `registerLocator()`.
* `registerDatabaseSchema()` must run before any dependency can open
  `AppDatabase().database`.
* Schema registration covers fresh database creation. New tables after release
  still require database version bumps and migrations.

### Consequences

* Good, because feature data layers continue to own their DAO/table details.
* Good, because there is one startup registration point to review when adding
  local persistence.
* Good, because `core/infra/database` remains reusable and feature-agnostic.
* Neutral, because adding a new feature table requires updating the central
  schema registrar.
* Bad, because missing schema contributor registration is still possible unless
  caught by review or tests.

### Confirmation

Confirm through code review, `custom_lint`, and tests that:

* no file under `lib/core/infra/**` imports `lib/features/**`;
* feature schema contributors live near feature DI;
* `registerDatabaseSchema()` is called early from `registerLocator()`;
* new persisted tables include on-create registration and, after release,
  migrations.

## Pros and Cons of the Options

### Keep schema registration inside feature service modules

Feature modules register table creation alongside datasources and repositories.

* Good, because it is minimal for the first table.
* Bad, because schema registration is hidden among service wiring.
* Bad, because future route-lazy registration could make table creation depend
  on whether a feature page was visited before the database opened.

### Centralize all schema details in `core/infra/database`

Core database code imports every DAO and registers every table directly.

* Good, because all schema details are physically in one file.
* Bad, because `core/infra` would depend on feature code.
* Bad, because it violates the repository architecture boundary.

### Use modular feature-owned schema registration orchestrated by `core/di`

Feature schema modules register their own tables; the composition root invokes
all contributors during startup.

* Good, because it balances centralized orchestration with decentralized
  ownership.
* Good, because it follows the existing GetIt per-feature module approach.
* Neutral, because the registrar list must be maintained.
* Bad, because it is not a full migration registry.

## More Information

Related decisions:

* `ADR/records/0002-clean-architecture-vertical-slices.md`
* `ADR/records/0003-getit-di-per-feature-modules.md`
