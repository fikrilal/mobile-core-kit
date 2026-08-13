---
status: accepted
date: 2026-08-12
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [harness, loop-engineering, evidence, governance]
tracking: _WIP/2026-08-10_mobile-loop-engineering-proposal.md
---

# Make harness hill climbing deterministic and human-terminal

## Context and Problem Statement

Reviewed operating outcomes can reveal recurring harness friction, but a
self-modifying agent loop could optimize metrics by weakening authority,
verification, risk classification, privacy, or publication controls. Evidence
must enable falsifiable experiments without granting the harness control over
its own policy.

## Decision Drivers

* Trend aggregation must be reproducible without model interpretation.
* Experiments need baseline and later evidence that cannot be cherry-picked.
* Safety invariants must be immutable and mechanically checked.
* Attribution requires one isolated experiment at a time.
* Humans must own approval, implementation authority, and terminal decisions.

## Considered Options

* Strict source-reviewed hypotheses with read-only shadow evaluation.
* Automatic policy tuning from local or hosted task metrics.
* Narrative recommendations without a checked schema.
* No improvement loop.

## Decision Outcome

Chosen option: "Strict source-reviewed hypotheses with read-only shadow
evaluation", because it makes learning falsifiable while keeping authority and
policy decisions outside the controller.

### Consequences

* Good, because trends are stable categorical counts and basis-point rates.
* Good, because an experiment requires eligible evidence, a separate high-risk
  edit/verify-only plan, distinct human owner/approver, and exact rollback paths.
* Good, because shadow windows are later, disjoint, ordered, and fixed-size.
* Good, because terminal records must match deterministic recomputation and an
  explicit human decision.
* Neutral, because the loop remains disabled while operating evidence is empty.
* Bad, because the protocol cannot automatically account for qualitative costs;
  human review must examine those before accepting `keep`.

### Confirmation

Repository knowledge runs `improve check`. Fixtures cover disabled, aggregate,
inconclusive, keep, revert, privacy-field, invariant, approval-separation,
publication-action, path, risk, and concurrency boundaries. Controller-owned
full verification remains the implementation gate.

## Pros and Cons of the Options

### Strict reviewed hypotheses

* Good, because each claim is bounded, reviewable, reversible, and testable.
* Good, because no command writes policy or grants authority.
* Bad, because collecting enough independent evidence takes real operating time.

### Automatic tuning

* Good, because it could react quickly.
* Bad, because the optimizer controls the definition of success and can weaken
  the guardrails it is supposed to improve.

### Narrative-only recommendations

* Good, because they are easy to write.
* Bad, because baselines, windows, invariants, and outcomes drift into prose.

### No improvement loop

* Good, because it has no implementation complexity.
* Bad, because recurring friction remains anecdotal and repeated failures are
  less likely to become durable harness improvements.

## More Information

* [Controlled harness improvement](../../docs/engineering/controlled_harness_improvement.md)
* [Harness operating evidence](../../docs/engineering/harness_operating_evidence.md)
* [Controlled verification loop](../../docs/engineering/controlled_verification_loop.md)
* [Agent-first harness decision](0011-agent-first-harness-and-loop-engineering.md)
