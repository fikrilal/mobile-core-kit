---
status: "accepted"
date: 2025-12-12
decision-makers: [Mobile Core Kit maintainers]
consulted: [Mobile Engineers]
informed: [All contributors]
scope: template
tags: [adr, process, governance]
---

# Use Architectural Decision Records (ADRs) in `mobile-core-kit`

## Context and Problem Statement

`mobile-core-kit` is a reusable Flutter starter template intended to be cloned and extended across multiple apps and teams. As the kit evolves, we need a lightweight way to preserve *why* durable architectural choices were made so that:

- contributors can extend the kit consistently without re‑debating past decisions,
- downstream adopters understand the defaults they inherit,
- future maintainers can safely revisit decisions when constraints change.

We therefore need a simple, repeatable process to document architecturally significant decisions as part of normal development.

## Decision Drivers

* Preserve critical architectural knowledge close to the code.
* Keep documentation lightweight and PR‑reviewable.
* Make baseline template decisions explicit to downstream adopters.
* Support evolution via superseding rather than rewriting history.
* Avoid introducing new tooling dependencies.

## Considered Options

* Keep decisions implicit in code and engineering docs only.
* Use long‑form design docs per feature or epic.
* Adopt Architectural Decision Records in‑repo (chosen).

## Decision Outcome

Chosen option: **Adopt Architectural Decision Records (ADRs) in‑repo**, because they provide a lightweight, durable log of decisions with clear tradeoffs and a structured change history.

### ADR Rules in This Repo

1. **What needs an ADR**
   - Any decision that changes *how future work is done* or establishes durable constraints, including:
     - core architectural patterns (layering, slicing, DI, navigation),
     - cross‑cutting library or platform choices,
     - contracts/boundaries between core and features,
     - decisions that would be costly to reverse without context.
   - Pure implementation details stay in PR descriptions or engineering docs.

2. **Where ADRs live**
   - Baseline template decisions: `ADR/records/`.
   - Downstream or historical examples: `ADR/examples/` (not inherited as defaults).

3. **Naming & numbering**
   - Zero‑padded sequence: `00xx-short-title.md`.
   - Numbers are monotonic within `records/`. Examples may keep their original numbers.

4. **Statuses**
   - One of: `proposed`, `accepted`, `rejected`, `deprecated`, `superseded by ADR-00xx`.
   - ADRs are immutable records; only the `status` and `date` fields may be updated after acceptance.

5. **Superseding**
   - If a decision changes, write a new ADR and set the old ADR status to `superseded by ADR-00xx`.

6. **Workflow**
   - Create ADRs in the same PR as the change they describe.
   - Review ADRs like code: focus on context, drivers, options, and consequences.

### Consequences

* Good, because baseline template rules become explicit and discoverable.
* Good, because future changes can be reasoned about using historical context.
* Neutral, because contributors must spend a small amount of time writing ADRs.
* Bad, because ADRs can become stale if not maintained through PR discipline.

### Confirmation

We consider this ADR implemented when:

* `ADR/records/` contains baseline template ADRs describing the durable architectural defaults.
* New baseline‑level changes add or supersede ADRs as part of the same PR.
* PR review checks that baseline ADRs are not app‑specific; those belong in `ADR/examples/` or downstream repos.

