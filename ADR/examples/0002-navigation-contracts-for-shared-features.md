---
status: "accepted"
date: 2025-12-06
decision-makers: [Mobile Tech Lead, Platform Architect]
consulted: [Mobile Engineers, Product Owners]
informed: [Engineering Leadership]
scope: downstream-example
tags: [navigation, contracts, multi-app]
---

# Navigation Contracts for Shared Features

> **Note:** This ADR is a downstream example copied from another project. It is kept for reference only and is **not** a baseline decision for `mobile-core-kit`.

## Context and Problem Statement

We are consolidating most of the Product A + Product B business flows into `packages/features_shared`, but some presentation widgets still navigate using `package:product_a_mobile/navigation/...` imports. That creates a hard dependency from the shared package to a single app, so as soon as another app (e.g., `product_b_mobile`) tries to consume the shared feature it fails to resolve the URIs. We need a way for the shared feature code to trigger navigation without linking itself to a particular app’s routing tables.

## Decision Drivers

* Keep shared packages free of references to a single app so other products can reuse them.
* Avoid widespread `package:product_a_mobile` imports from shared code—this breaks the multi-app architecture.
* Allow future apps to provide their own navigation tables without editing shared widgets/controllers.
* Keep navigation usage simple for feature developers (no excessive abstraction).

## Considered Options

* Leave the route constants in each app and continue importing them from `package:product_a_mobile`.
* Move the shared routes (e.g., `AuthRoutes`, `PaymentRoutes`) into `features_shared`.
* Introduce navigation contracts in `features_shared` and register per-app implementations.

## Decision Outcome

Chosen option: **Introduce navigation contracts in `features_shared` and register per-app implementations**, because it keeps shared code app-agnostic while letting each app choose its own route strings or helpers. Shared widgets/controllers will call `Get.find<AuthRouteProvider>().forgotPassword` (or similar) and never import `product_a_mobile`. Each app still owns its navigation graph but binds its provider to the shared contract.

### Consequences

* Good, because shared packages no longer import app‑specific route classes—`features_shared` stays reusable across Product A, Product B, and future white labels.
* Good, because each app can eventually diverge its route paths without touching shared code; only the provider implementation changes.
* Neutral, because we add a small amount of boilerplate (a provider interface + per‑app implementations) for each feature area that needs navigation contracts.
* Bad, because we must update existing shared widgets/controllers to use the contract instead of direct route constants and register the providers once per app.

### Confirmation

Implementation is confirmed when:

* Shared widgets/controllers import navigation contracts from `features_shared` (e.g., `AuthRouteProvider`) instead of app packages.
* `apps/product_a_mobile` registers its provider (returning `AuthRoutes.forgotPassword`, etc.) in the appropriate binding.
* Any other app (e.g., future `apps/product_b_mobile`) can register a different provider without editing shared packages.
* Automated or manual reviews ensure no lingering `package:product_a_mobile/navigation/...` usages exist within `packages/features_shared`.

## Pros and Cons of the Options

### Leave routes in each app (current state)

Shared packages import `package:product_a_mobile/navigation/*`.

* Good, because no immediate refactor is required.
* Bad, because shared packages cannot be consumed outside Product A—they fail to compile for Product B or any other app.
* Bad, because any new app would need to duplicate shared feature code just to supply routes.

### Move route constants into `features_shared`

Shared code owns the route strings and exports them.

* Good, because shared widgets keep importing directly from `features_shared`.
* Neutral, because it works as long as every app uses the exact same paths.
* Bad, because if future apps need a different URI (e.g., Product B wants `/product-b/auth/forgot-pin`), the shared package must change or duplicate routes, reintroducing coupling.
* Bad, because route constants live in a shared feature package but describe app-specific navigation (blurred ownership).

### Navigation contracts in `features_shared` (chosen)

Define `abstract class AuthRouteProvider { String get forgotPassword; ... }` in a shared package, and have apps register their implementations. Shared widgets use `Get.find<AuthRouteProvider>()`.

* Good, because shared packages remain app-agnostic and reusable.
* Good, because each app controls routing and can diverge without touching shared flows.
* Good, because navigation usage remains simple and discoverable.
* Neutral, because there is more wiring per feature (one provider interface + registrations).
* Bad, because developers must remember to register the provider in each app binding.

## More Information

Linked decisions and resources:

* `docs/engineering/project_architecture.md` explains the modular feature layout that downstream apps may extend into multi‑app workspaces.
* `ADR/examples/0001-multi-app-monorepo-architecture.md` sets the broader monorepo direction.
* Once this ADR is in place we should record per-feature contracts (auth, payment, profile) and add tests or lint rules to ensure shared code no longer imports app routes.
