---
status: accepted
date: 2026-08-16
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [localization, custom-lint, harness, accessibility]
tracking: _WIP/2026-08-16_localization-enforcement-and-consumer-adoption-proposal.md
---

# Enforce localization at registered user-visible sinks

## Context and Problem Statement

The template requires user-facing copy to come from ARB resources, but the
existing `hardcoded_ui_strings` rule recognizes only a few widget shapes.
Agents can therefore pass direct literals through accessibility properties,
Flutter widgets, or project-specific presentation models while every declared
localization check remains green.

## Decision Drivers

* Recurring agent mistakes must become mechanical feedback.
* The rule must cover visible and assistive-technology copy.
* Common parameter names such as `label` must not create broad false positives.
* Generated consumers need a narrow extension point for their own UI APIs.
* The rule must remain deterministic, local, and simple to repair.

## Considered Options

* Match registered target and argument pairs, with additive consumer sinks.
* Scan every string literal in presentation paths.
* Match common argument names on every invocation.
* Keep the narrow widget checks and rely on agent instructions and review.
* Add whole-program string data-flow analysis.

## Decision Outcome

Chosen option: "Match registered target and argument pairs, with additive
consumer sinks", because it covers known user-visible boundaries without
classifying technical strings solely by their text or argument name.

The initial detector reports non-empty direct literal copy at configured sinks.
Interpolation-only expressions such as `'${value}'` contain no fixed copy and
are not reported; interpolations with fixed prose are reported. It does not
trace strings through variables, fields, factories, or other files.

Baseline Flutter and design-system sinks are built into
`mobile_core_kit_lints`. Consumers may add target-specific named or positional
arguments through strict `analysis_options.yaml` configuration. Additions merge
with, and cannot replace, the defaults.

Targets use their simple Dart type identifier, including when referenced
through an import prefix. This keeps consumer configuration stable and supports
the constructor and static-helper AST shapes exposed by the pinned analyzer.
The narrow production path scope and exact argument match limit same-name API
collisions; recurring collision evidence would justify resolved-library
identity in a later decision.

### Consequences

* Good, because visible and accessibility literals fail in the normal agent
  lint loop.
* Good, because diagnostics name the target and argument agents must repair.
* Good, because product-specific presentation models can be covered without
  coupling them to core-kit.
* Good, because ARB generation and translation completeness retain separate,
  understandable responsibilities.
* Bad, because indirect hardcoded copy remains outside the initial boundary.
* Bad, because existing generated consumers must port the contract explicitly.

### Confirmation

Table-driven tests confirm the default and configured sink registry, strict
configuration, path scope, literal matching, and false-positive boundaries. A
temporary fixture runs the installed custom-lint plugin and proves a violating
source fails while localized values pass. The repository full verification
profile remains the release gate.

## Pros and Cons of the Options

### Registered target and argument pairs

* Good, because ownership and matching are explicit and searchable.
* Good, because consumer extensions remain small and reviewable.
* Bad, because new UI APIs need a sink declaration.

### Scan all presentation literals

* Good, because detector coverage is broad.
* Bad, because route keys, analytics values, assets, and technical identifiers
  create noise that erodes trust in the lint.

### Match common argument names

* Good, because implementation is small.
* Bad, because `label`, `message`, and `title` have non-UI meanings across the
  codebase.

### Instructions and review only

* Good, because it adds no code.
* Bad, because the observed misses already passed that operating model.

### Whole-program data-flow analysis

* Good, because it can find indirect copy.
* Bad, because its complexity and false-positive surface are not justified by
  the current evidence.

## More Information

* [Localization architecture](../../docs/engineering/localization.md)
* [Localization playbook](../../docs/engineering/localization_playbook.md)
* [Localization enforcement proposal](../../_WIP/2026-08-16_localization-enforcement-and-consumer-adoption-proposal.md)
