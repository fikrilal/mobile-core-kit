---
status: "proposed"
date: 2025-12-03
decision-makers: [Mobile Tech Lead, Backend Tech Lead, Product Owner A, Product Owner B]
consulted: [Mobile Engineers, QA, DevOps]
informed: [Management, Customer Success, Support]
scope: downstream-example
tags: [monorepo, multi-app, packaging]
---

# Multi-App Monorepo Architecture for Product A and Product B

> **Note:** This ADR is a downstream example copied from another project. It is kept for reference only and is **not** a baseline decision for `mobile-core-kit`.

## Context and Problem Statement

The existing Product A mobile app is live in production with core features such as auth, profile, savings, payments, and other Product‑A‑specific flows. A new product, Product B, is being developed that shares many of these core capabilities but has important differences:

- Product B omits several Product‑A‑specific modules.
- Product B introduces its own product‑specific features that may diverge from Product A over time.
- Product B’s home and navigation shell (e.g., fewer bottom‑nav tabs) is significantly different from Product A’s shell.

In addition, we expect to white-label both product families:

- Product A Tenant 1, Product A Tenant 2, etc.
- Product B Tenant X, Product B Tenant Y, etc.

These white labels will have different branding (colors, logos, fonts) and possibly slightly different configurations (base URLs, IDs, feature toggles).

The key question:

> How should we structure the codebase and repositories so we can:
> - Share core platform features (auth, savings, bill payments, payments, profile, services) across products and white labels,
> - Allow Product A and Product B to diverge in their home and navigation shells and in product‑specific features,
> - Avoid code duplication and painful bugfix porting as the number of products increases?

## Decision Drivers

* Minimize duplication of platform features (auth, savings, bill payments, payments, profile, services, design system).
* Allow significant product‑specific differences in home UX and navigation structure (Product A vs Product B) without entangling shells.
* Support product‑specific features that may diverge over time (Product‑A‑specific vs Product‑B‑specific flows).
* Support white‑label growth (Product A/B variants per tenant) with manageable overhead.
* Maintain and extend the existing Clean Architecture and feature-first structure.
* Keep the development and CI experience understandable and efficient for the team.

## Considered Options

* Option A: Separate repos per product (copy/fork Product A → Product B).
* Option B: Single repo, single app, multiple flavors + product config.
* Option C: Single repo, multiple apps (monorepo) + shared packages (chosen).

## Decision Outcome

Chosen option: **Option C: Single repo, multiple apps (monorepo) + shared packages.**

We will:

1. Use a single Git repository (monorepo) containing multiple Flutter apps under `apps/`:
   - `apps/product_a_mobile/` for Product A apps.
   - `apps/product_b_mobile/` for Product B apps.
2. Extract shared platform code and commonly reused features into packages under `packages/`:
   - `platform_core` for configuration, networking, storage, services, and other cross-cutting infrastructure.
   - `design_system` for theme, tokens, and shared UI components.
   - `features_shared` for cross-product features (auth, profile, savings, bill payments, payments, member, etc.).
   - `features_product_a` for Product‑A‑only features.
   - `features_product_b` for Product‑B‑only features.
3. Treat each app as a thin shell responsible for:
   - App-specific entrypoints and env wiring.
   - Product-specific home and navigation structure.
   - Selecting which feature packages are wired into the router and DI.
4. Represent white labels (Product A Tenant 1, Product B Tenant X, etc.) as flavors and configuration within each app, not as separate repos or apps.

This option best balances sharing and divergence and aligns with the existing Clean Architecture and feature-first design.

### Consequences

* Good, because **shared platform logic is implemented once**:
  - Core features (auth, savings, bill payments, payments, profile) and shared infra (network, DB, services) are defined in packages and reused in all apps and tenants.
  - Bug fixes and improvements to shared features apply to both Product A and Product B automatically.
* Good, because **product shells can diverge cleanly**:
  - Product A and Product B can own independent home layouts and navigation patterns in their respective `apps/*` without complex product conditionals in shared code.
  - Product‑specific features live in product‑specific modules and do not pollute shared domains.
* Good, because **white-label growth is manageable**:
  - Adding new Product A or Product B tenants is mainly a matter of new flavors/configuration and branding, not new repos or large code duplication.
* Good, because **the architecture matches industry patterns**:
  - Monorepo with multiple apps and shared packages mirrors architectures used in multi-brand mobile products and modular native/Flutter apps.
* Bad, because **there is upfront refactoring cost**:
  - We must move existing Product A `lib/core` and shared features into packages.
  - We need to create `apps/product_a_mobile` and later `apps/product_b_mobile` and adjust imports and tooling (e.g. commands, CI).
* Bad, because **we introduce more moving parts (apps + packages)**:
  - Developers must understand the dependency graph (apps → feature packages → platform_core / design_system).
  - CI needs to be aware of multiple apps and packages.
* Bad, because **there is a risk of over-fragmentation**:
  - If we split into too many tiny packages too early, maintenance overhead increases.
  - We need discipline to keep `platform_core` and feature boundaries clear and avoid creating a "misc" dumping ground.

### Confirmation

We will consider this ADR implemented and effective when:

* The repository contains:
  - `apps/product_a_mobile/` as a working app using `platform_core`, `design_system`, and `features_shared`.
  - `packages/platform_core/`, `packages/design_system/`, and at least one `packages/features_shared/` extracted from the current codebase.
* A `apps/product_b_mobile/` app exists that:
  - Shares the platform packages.
  - Has its own home screen and navigation shell.
* CI pipelines:
  - Can `analyze` and `test` both apps and the shared packages.
  - Build Product A and Product B apps independently.
* Future product‑specific features are added under `features_product_b` (or an equivalent Product‑B‑specific package), not inside Product A or shared code.

Compliance can be confirmed via:

* Architectural/code reviews of new features and cross-cutting changes.
* Optional static checks (e.g. Melos workspace rules or custom scripts) enforcing that:
  - `features_product_a` does not depend on `features_product_b`, and vice versa.
  - Apps depend only on appropriate feature packages and platform_core/design_system.

## Pros and Cons of the Options

### Option A: Separate repos per product (copy/fork Product A → Product B)

* Good, because:
  - Hard isolation between Product A and Product B; changes in one cannot break the other directly.
  - Very simple mental model (one repo per product).
* Neutral, because:
  - Each repo can have its own release cadence and governance, but this also splits ownership and can be positive or negative depending on team size.
* Bad, because:
  - Shared platform code (auth, savings, payments, core services, design system) is duplicated.
  - Bug fixes and improvements must be manually ported across repos, leading to divergence.
  - Architectural refactors must be repeated or re-applied in multiple codebases.
  - With many white labels (Product A tenants, Product B tenants), the number of repos and maintenance overhead explodes.

### Option B: Single repo, single app, multiple flavors + product config

* Good, because:
  - All shared logic lives in one place; fixes and refactors apply to all products.
  - We can reuse the existing app structure with minimal refactoring.
  - Build tooling and CI stay centered around a single Flutter app (with flavors).
* Good, because:
  - White labels are easy to add as additional flavors and envs.
* Bad, because:
  - As product shells diverge (e.g., Product B has fewer bottom‑nav tabs than Product A), the app shell code becomes full of `if (productType == productB)` conditionals.
  - Product‑specific features risk leaking their differences into shared feature modules instead of being modeled cleanly as separate slices.
  - Over time, the single app becomes harder to reason about and test per product, especially when product-specific navigation graphs grow.

### Option C: Single repo, multiple apps (monorepo) + shared packages (chosen)

* Good, because:
  - Shared features and platform services are implemented once and reused across all apps.
  - Product A and Product B can have completely different home layouts and navigation shells without impacting each other.
  - Product‑specific features can live in product‑specific modules and remain decoupled from other products.
  - The architecture matches common industry practice for multi-brand platforms (apps + shared libraries).
* Good, because:
  - White labels are represented as flavors/configs within each app, not as separate repos.
* Bad, because:
  - Requires initial refactoring effort and the introduction of workspace tooling.
  - Increases structural complexity (apps + packages) that must be learned by the team.

## More Information

References on Architectural Decision Records (ADRs) and templates:

* “Preserving Critical Software Knowledge Using Architectural Decision Records” — Code Soapbox  
  (local reference: `ADR/references/codesoapbox_adr.html`)
* “Architectural Decision Records ADR” — Open Practice Library  
  (local reference: `ADR/references/openpracticelibrary_adr.html`)
* MADR template v4.0.0 — <https://github.com/adr/madr>  
  (local reference: `ADR/template/madr-template-raw.md` and `ADR/template/adr-template.md`)

This ADR is closely related to:

- `docs/engineering/project_architecture.md` — describes the feature‑first Clean Architecture and vertical slices.
- `docs/engineering/data_domain_guide.md` — describes domain/data layering within features.
- `docs/engineering/ui_state_architecture.md` — describes controller + state + effect UI patterns.
- (Downstream-only) multi‑app monorepo docs that informed this example are not part of this template.

