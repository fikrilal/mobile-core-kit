---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [navigation, go-router]
---

# GoRouter with Per‑Feature Route Lists

## Context and Problem Statement

Apps created from this template need declarative routing, deep‑link support, and a way for features to contribute routes without centralizing all navigation in one large file.

## Decision Drivers

* Declarative route definitions with deep‑linking.
* Modular composition of routes per feature.
* Simple integration with analytics and navigation services.
* Avoid third‑party routing abstractions that hide platform behavior.

## Considered Options

* Manual Navigator 2.0 router configuration.
* AutoRoute or similar code‑generated routing.
* GoRouter with per‑feature route lists (chosen).

## Decision Outcome

Chosen option: **GoRouter composed from per‑feature route lists**, because it is well‑supported, declarative, and matches existing structure in `lib/navigation/`.

Pattern:

* Global router builder lives in `lib/navigation/app_router.dart`.
* Each feature exports a `List<GoRoute>` (e.g., `lib/navigation/auth/auth_routes_list.dart`).
* `createRouter()` composes those lists and attaches cross‑cutting observers (e.g., `AnalyticsRouteObserver`).

### Consequences

* Good, because features can add routes without editing unrelated modules.
* Good, because deep links and redirects are centralized.
* Neutral, because route ownership must be kept clear between core and features.
* Bad, because poorly‑maintained route lists can still lead to duplication without review.

### Confirmation

Confirmed when:

* New features add their routes under `lib/navigation/<feature>/` and export a list.
* `app_router.dart` remains a thin composer, not a feature dump.

