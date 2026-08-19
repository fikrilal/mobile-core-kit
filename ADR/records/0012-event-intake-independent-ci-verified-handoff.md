---
status: accepted
date: 2026-08-12
decision-makers: [Core kit maintainer]
consulted: [Codex]
informed: []
scope: template
tags: [harness, loop-engineering, ci, handoff]
tracking: _WIP/2026-08-10_mobile-loop-engineering-proposal.md
---

# One-shot event intake, independent CI, and verified handoff

## Context and Problem Statement

The harness can authorize, isolate, verify, and collect candidate-bound mobile
evidence, but it previously depended on a human/agent remembering how queued
work is activated, had no safe scheduled entropy check, exposed no single
clean-checkout required result, and did not mechanically separate local
verification from commit or publication authority.

## Decision Drivers

* Events must select existing authority and never create it.
* Scheduled maintenance must observe entropy without changing source.
* CI evidence must be independent from controller-local state.
* Publication must require both fresh evidence and a separate action grant.
* Ambiguous external outcomes must never be replayed automatically.
* The harness must remain repository-local and smaller than an agent platform.

## Considered Options

* One-shot repository commands with bounded local receipts and narrow adapters.
* A long-running webhook/agent orchestration service.
* Documentation-only event, CI, and publication conventions.

## Decision Outcome

Chosen option: "One-shot repository commands with bounded local receipts and
narrow adapters", because it makes authority and evidence enforceable while
keeping the current conversational agent as the implementation entity.

### Consequences

* Good, because queued work is selected deterministically from a complete V2
  plan and interrupted activation has one recoverable claim.
* Good, because maintenance owns a fixed registry and proves repository source
  did not change; codegen uses a disposable checkout.
* Good, because `CI Required` composes risk, full, selected runtime, and
  governance evidence from a clean checkout.
* Good, because commit, push, and draft PR each require an exact fresh
  candidate and an expiring one-time challenge.
* Good, because force push, merge, deploy, signing, migrations, release, and
  arbitrary event commands are absent.
* Bad, because hosted CI correctness cannot be demonstrated before an
  separately authorized push.
* Bad, because the repository cannot authenticate the human identity behind a
  shell invocation; AGENTS therefore still requires explicit user authority
  before the mutating command.

### Confirmation

CLI fixtures cover event recovery/deduplication, strict private receipts,
read-only maintenance, base/head plan classification, workflow security
policy, handoff freshness/path/branch/remote/approval behavior, and uncertain
external outcomes. `mobilekit task verify` remains the completion gate.

## Pros and Cons of the Options

### One-shot commands and narrow adapters

* Good, because it composes with Codex or Claude Code in normal chat.
* Good, because every mutating boundary is small, searchable, and testable.
* Neutral, because external schedulers and GitHub still provide invocation.
* Bad, because users must manage a deliberate approval step per action.

### Long-running orchestration service

* Good, because it could ingest more event types and coordinate workers.
* Bad, because it creates another agent tool, service lifecycle, credential
  surface, and authority system before evidence shows that complexity is
  needed.

### Documentation-only conventions

* Good, because it has minimal implementation cost.
* Bad, because deduplication, source non-mutation, evidence freshness, and
  separate publication authority remain dependent on agent memory.

## More Information

* [Event, maintenance, CI, and handoff guide](../../docs/engineering/event_maintenance_handoff.md)
* [Structured task authority](../../docs/engineering/task_authority.md)
* [Controlled verification loop](../../docs/engineering/controlled_verification_loop.md)
* [Behavioral oracles](../../docs/engineering/behavioral_oracles.md)
