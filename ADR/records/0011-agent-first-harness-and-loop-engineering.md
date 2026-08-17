---
status: accepted
date: 2026-08-10
decision-makers: Dante
consulted: Codex
informed: future maintainers and coding agents
scope: template
tags: [agents, harness, verification, clean-architecture, loop-engineering]
tracking: _WIP/2026-08-10_mobile-loop-engineering-proposal.md
---

# Adopt a Repository-Owned Agent Harness and Controlled Engineering Loops

## Context and Problem Statement

AI coding agents are expected to perform most implementation work in this
template while humans retain product direction, architecture, risk acceptance,
and sensitive external actions. The repository already has strong lints,
tests, CI, runtime evidence, and engineering guidance, but scope, authority,
verification, repair, handoff, and learning are not connected into one
auditable operating loop.

How should the repository make agent execution reliable without building a
second coding agent or weakening its Clean Architecture?

## Decision Drivers

* Keep product meaning, architecture, and sensitive authority human-owned.
* Make constraints and feedback directly legible to a fresh agent context.
* Preserve Clean Architecture as an executable invariant.
* Provide deterministic, risk-aware evidence before accepting agent claims.
* Protect user-owned work and make recovery bounded and reversible.
* Improve the harness only from reviewed, sanitized operating evidence.
* Keep tooling repository-local, simple, and removable.

## Considered Options

* Continue with documented conventions and disconnected checks.
* Build or adopt a separate agent-orchestration platform.
* Copy another core kit's controller implementation.
* Extend the repository-owned `mobilekit` harness in independently useful
  phases.

## Decision Outcome

Chosen option: "Extend the repository-owned `mobilekit` harness in phases",
because it lets Codex, Claude Code, and other repository agents use the same
visible controls through normal conversation while keeping intent and
authority outside the coding model.

The accepted direction is:

1. truthful fast/full/runtime/CI verification profiles;
2. machine-checkable task authority and conservative risk classification;
3. bounded verification and repair with stable failure identities;
4. isolated current-agent worktrees;
5. independent behavioral oracles and sanitized mobile evidence;
6. one-shot event intake, maintenance, and verified handoff;
7. reviewed operating evidence; and
8. disabled-by-default, controlled harness hill climbing.

The repository MUST NOT launch nested coding agents, infer publication
authority, or allow task tooling to bypass architecture, security, runtime, or
human-review constraints. Clean Architecture dependency rules remain immutable
safety invariants for this loop.

### Consequences

* Good, because any compatible coding agent can use the same repository-owned
  workflow without a new chat or orchestration product.
* Good, because local claims can be reproduced independently by CI.
* Good, because recurring failures can become tested repository improvements
  instead of prompt folklore.
* Good, because each phase is independently disableable and reversible.
* Neutral, because agent work gains explicit planning and evidence overhead.
* Bad, because the CLI becomes safety-critical and requires its own strong
  tests, documentation, and maintenance budget.
* Bad, because device evidence and full Flutter verification remain expensive.

### Confirmation

Confirm this decision through the acceptance conditions in the approved
proposal, phase-specific execution plans, focused CLI negative tests,
independent CI, and periodic review that the harness remains smaller than a
separate agent platform. Architecture lints must stay enabled in every
canonical full/CI profile.

## Pros and Cons of the Options

### Continue with documented conventions and disconnected checks

* Good, because it adds no tooling.
* Bad, because authority, failure recovery, and handoff still depend on agent
  memory.
* Bad, because recurring outcomes cannot be evaluated safely.

### Build or adopt a separate agent-orchestration platform

* Good, because it could schedule and coordinate many agent processes.
* Bad, because this repository needs a harness, not another coding agent.
* Bad, because conversational and repository authority would split across
  systems.

### Copy another core kit's controller implementation

* Good, because several control concepts are already proven elsewhere.
* Bad, because backend and web runtimes do not model Flutter devices, flavors,
  goldens, lifecycle behavior, or platform configuration.
* Neutral, because shared vocabulary and schemas should still align where they
  represent the same policy.

### Extend the repository-owned `mobilekit` harness in phases

* Good, because existing agents already discover and invoke it.
* Good, because Dart tests can prove the controller alongside the app.
* Good, because each control can be introduced after its prerequisite evidence.
* Bad, because careful sequencing is required to avoid automating ambiguity.

## More Information

* `_WIP/2026-08-10_mobile-harness-loop-engineering-research.md`
* `_WIP/2026-08-10_mobile-loop-engineering-proposal.md`
* `docs/engineering/project_architecture.md`
* `docs/engineering/agent_pr_loop.md`
* `docs/engineering/mobile_runtime_harness.md`
* `ADR/records/0002-clean-architecture-vertical-slices.md`
