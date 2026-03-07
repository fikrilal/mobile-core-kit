---
status: accepted
date: 2026-03-07
decision-makers: Fikri, Codex
consulted: none
informed: future maintainers
scope: template
tags: [architecture, features, subfeatures]
tracking: null
---

# Use Graduated Feature Decomposition Instead of Uniform Folder Shapes

## Context and Problem Statement

Different features in this template accumulate complexity in different places.
Some remain cohesive with a shared data/domain core but become hard to navigate
in presentation. Others grow into multiple independent slices with distinct
ownership, runtime integration, or domain responsibilities. A single universal
folder shape for every feature would force symmetry where the actual pressure is
different.

## Decision Drivers

* Keep architecture aligned to actual ownership boundaries
* Avoid over-engineering through unnecessary layers or duplicated abstractions
* Preserve maintainability as features grow at different rates
* Keep the repository teachable to future maintainers

## Considered Options

* Enforce one uniform internal shape for every feature
* Keep all features flat until they become painful
* Use graduated decomposition based on feature complexity

## Decision Outcome

Chosen option: "Use graduated decomposition based on feature complexity",
because it preserves consistent principles without forcing identical folder
trees across unlike features.

### Consequences

* Good, because features may stay flat when that is enough
* Good, because presentation-only subfeatures can be introduced without forcing
  full vertical splits
* Good, because full vertical subfeatures remain available when data/domain also
  diverge
* Bad, because different features may have different internal layouts and
  require a short learning curve

### Confirmation

Confirm through code review and architecture linting that:

* features with distinct cross-slice ownership are split more strongly
* features with shared data/domain keep that shared core
* source-local READMEs explain non-obvious boundaries

## Pros and Cons of the Options

### Enforce one uniform internal shape for every feature

Every feature uses the same directory tree regardless of actual complexity.

* Good, because it is visually predictable
* Bad, because it often creates empty or unnecessary layers
* Bad, because it optimizes for symmetry instead of responsibility

### Keep all features flat until they become painful

All internal structure stays minimal until maintainers feel enough pain.

* Good, because it minimizes ceremony
* Good, because it delays abstraction until needed
* Bad, because large flat features become harder to navigate gradually
* Bad, because the eventual refactor is usually larger and riskier

### Use graduated decomposition based on feature complexity

Choose among flat, presentation-first subfeatures, or full vertical subfeatures
depending on where the complexity actually lives.

* Good, because it matches structure to real maintenance pressure
* Good, because it avoids forcing data/domain splits where they are still
  shared
* Good, because it supports stronger decomposition when slices truly diverge
* Neutral, because feature layouts may differ

## More Information

Current examples in this repository:

* `features/account` uses stronger subfeature separation because it mixes
  several substantial account-management slices and interfaces with the
  current-user kernel in `core`.
* `features/auth` uses lighter presentation-first subfeatures because the
  workflows are numerous, but the data/domain surface remains shared and
  cohesive.

See also:

* `docs/engineering/project_architecture.md`
* `lib/core/domain/README.md`
* `lib/core/runtime/session/README.md`
* `lib/features/auth/README.md`
