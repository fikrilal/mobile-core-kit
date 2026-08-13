---
status: accepted
date: 2026-08-12
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [harness, loop-engineering, evidence, privacy]
tracking: _WIP/2026-08-10_mobile-loop-engineering-proposal.md
---

# Keep operating evidence as a strict reviewed source ledger

## Context and Problem Statement

The harness now produces bounded task and verification outcomes, but local
episodes alone cannot justify tuning policy. Agents also must not gain a new
telemetry channel that stores prompts, reasoning, logs, diffs, credentials, or
user data merely to optimize their own workflow.

## Decision Drivers

* Improvement proposals need evidence across real tasks and risk classes.
* Independent human review and hosted CI must remain distinct trust boundaries.
* Evidence must be understandable, diffable, private-data-resistant, and
  portable across conversational coding agents.
* Metrics must not automatically grant work or publication authority.
* The solution should reuse `mobilekit` rather than introduce an agent service.

## Considered Options

* A strict checked-in sanitized ledger with deterministic validation/reporting.
* Automatic promotion from local task episodes.
* An external agent telemetry and optimization service.
* Documentation-only evidence collection.

## Decision Outcome

Chosen option: "A strict checked-in sanitized ledger with deterministic
validation/reporting", because normal source review can establish the missing
human boundary while schema validation prevents unrestricted telemetry.

### Consequences

* Good, because every record binds an existing completed plan, its content
  hash, exact hosted-CI revision, stable categories, and bounded durations.
* Good, because the initial empty ledger truthfully reports insufficient proof.
* Good, because full and CI profiles reject malformed or privacy-expanding
  fields before the evidence can influence later analysis.
* Good, because a narrow mutation pilot tests representative policy weakening
  without adding a framework or default-lane cost.
* Neutral, because record promotion remains a deliberate reviewed source edit.
* Bad, because independent review and hosted CI cannot be proven from a local
  checkout alone; humans must confirm those attestations during source review.

### Confirmation

`mobilekit evidence verify` validates schema, completed-plan identity/hash,
effective-risk bounds, declared-impact coverage, review and CI markers, bounded data, sorting,
uniqueness, and calibration integrity. Repository knowledge validation includes
that policy in fast/full/CI. Negative fixtures and `evidence mutation-pilot` exercise false-green
boundaries.

## Pros and Cons of the Options

### Strict reviewed source ledger

* Good, because Git review is the existing independent approval mechanism.
* Good, because stable structured fields are searchable and aggregatable.
* Bad, because promotion is intentionally slower than automatic ingestion.

### Automatic local promotion

* Good, because it reduces data-entry effort.
* Bad, because a local agent can self-assert review and CI evidence.
* Bad, because ignored task state is not clean-checkout evidence.

### External telemetry service

* Good, because it could aggregate more signals continuously.
* Bad, because it adds credentials, retention, privacy, operations, and another
  agent-adjacent product before the repository has evidence it is necessary.

### Documentation-only collection

* Good, because it adds no code.
* Bad, because schema drift and unsafe fields remain dependent on memory.

## More Information

* [Harness operating evidence](../../docs/engineering/harness_operating_evidence.md)
* [Harness baseline](../../docs/engineering/harness_baseline.md)
* [Controlled verification loop](../../docs/engineering/controlled_verification_loop.md)
* [Agent-first harness decision](0011-agent-first-harness-and-loop-engineering.md)
