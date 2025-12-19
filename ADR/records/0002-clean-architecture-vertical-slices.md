---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [architecture, clean-architecture, vertical-slices]
---

# Clean Architecture with Vertical Feature Slices

## Context and Problem Statement

This template is intended to scale from a small app to multiple products and white‑labels. We need a structure that keeps business rules isolated from infrastructure, supports feature growth without a “god module”, and remains testable as teams and code size increase.

## Decision Drivers

* Maintain clear Domain ↔ Data ↔ Presentation boundaries.
* Keep features cohesive and easy to navigate.
* Enable unit testing of business rules without Flutter/UI.
* Support future extraction of large features into packages.
* Make cross‑cutting infrastructure reusable via `core/`.

## Considered Options

* Layer‑first app layout (global `data/`, `domain/`, `presentation/`).
* Feature‑first vertical slices (chosen).
* Package‑per‑feature from day one.

## Decision Outcome

Chosen option: **Feature‑first vertical slices following Clean Architecture**, because it balances clarity, testability, and scalability without prematurely splitting into multiple packages.

In practice:

* `lib/core/` holds shared infrastructure (config, DI, network, theme, services).
* Each feature lives under `lib/features/<feature>/` with:
  - `data/` (datasources, DTOs, mappers, repository implementations),
  - `domain/` (entities, value objects, failures, repository interfaces, use cases),
  - `presentation/` (Bloc/Cubit, pages, widgets),
  - `di/` (feature module wiring).

### Consequences

* Good, because features are cohesive and boundaries stay explicit.
* Good, because domain logic remains framework‑agnostic and easy to test.
* Neutral, because some boilerplate is required per feature.
* Bad, because ignoring boundaries can still lead to coupling without review discipline.

### Confirmation

Confirmed when:

* New features follow the `features/<feature>/{data,domain,presentation,di}` layout.
* PR reviews reject cross‑layer leaks (e.g., presentation importing remote DTOs).
* Refactors that change boundaries add or supersede the relevant ADRs.

