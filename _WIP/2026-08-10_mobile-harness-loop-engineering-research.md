# Mobile Harness And Loop Engineering Research

**Date:** 2026-08-10

**Status:** exploratory research and repository audit; no implementation is authorized

**Target repository:** `mobile-core-kit`

**Reference repositories:**

- `/home/fikrilal/devs/core/backend-core-kit`
- `/home/fikrilal/devs/core/frontend-core-kit`

## Executive Summary

`mobile-core-kit` already has a strong **verification harness**. It has a
repository-local CLI, custom architectural lints, a canonical verification
command, execution plans, runtime evidence tooling, CI, duplication sensors,
and an explicit rule that repeated failures should become guardrails.

It does not yet have a complete **engineering loop**. The missing layer is a
small control system that connects human intent to bounded agent work,
risk-selected verification, independent evidence, and measured harness
improvement:

```text
human intent and authority
        -> scoped task state
        -> agent implementation
        -> deterministic verification and repair
        -> independent runtime/CI evidence
        -> reviewed operating record
        -> evidence-based harness improvement
```

The most important conclusion is that loop engineering is not an invitation to
add more agent frameworks. The repository should keep one simple agent-facing
surface (`mobilekit`), preserve Clean Architecture as a mechanically enforced
invariant, and add only the control and evidence capabilities that the current
harness lacks.

The recommended next investment is **truthful task and verification control**,
not autonomous merge or self-modifying policy. Event-driven maintenance and
hill climbing should remain read-only and advisory until enough independently
reviewed task outcomes exist.

## Research Question

How should a mobile Clean Architecture template be engineered when:

- humans own product direction, acceptance meaning, architecture decisions,
  risk acceptance, and sensitive external actions;
- AI agents perform most implementation, testing, documentation, and repair;
- the code must remain simple and legible while scaling to larger products;
- mobile runtime behavior cannot be proven by static checks alone;
- increasing agent throughput must not weaken auth, session, API, release, or
  platform safety?

## What Harness Engineering Means

OpenAI's harness-engineering report describes a repository in which humans
steer and agents execute. The important mechanism is not a special prompt. It
is an environment where repository-local knowledge, tools, architectural
boundaries, tests, application observability, and review feedback let an agent
make progress and correct itself.

Key findings from the OpenAI report:

- `AGENTS.md` works best as a concise map into a structured repository-local
  system of record, not as a monolithic manual.
- Agent legibility is an engineering property. Knowledge outside the running
  agent's accessible repository context is effectively absent.
- Strict architectural boundaries and predictable structures are early
  prerequisites for agent speed, not late enterprise ceremony.
- Custom lint messages should explain remediation because diagnostics become
  agent input.
- Human taste and recurring review feedback should be captured as docs,
  tools, structural tests, or lints.
- Agent-generated entropy requires recurring garbage collection rather than a
  periodic manual cleanup day.
- Higher autonomy emerges only after testing, validation, review, feedback,
  recovery, and application observability have been encoded into the system.

Source: [OpenAI, “Harness engineering: leveraging Codex in an agent-first world”](https://openai.com/index/harness-engineering/).

Birgitta Bockeler's harness model adds a useful vocabulary:

| Dimension | Meaning | Examples in this repository |
| --- | --- | --- |
| Feed-forward guide | Steers the agent before it changes code | `AGENTS.md`, architecture docs, ADRs, templates |
| Feedback sensor | Observes an outcome and enables correction | analyzer, custom lints, tests, runtime evidence |
| Computational control | Deterministic, fast, reproducible | Dart analysis, structural rules, test assertions |
| Inferential control | Semantic but probabilistic | agent review, architecture critique, visual-taste review |

Guides without sensors rot. Sensors without guides make agents rediscover the
same constraints through failure. The repository needs both, with
computational controls as the authoritative baseline and inferential controls
used where semantic judgment adds value.

The same article separates three regulated qualities:

1. **Maintainability:** duplication, dead code, complexity, naming, locality.
2. **Architecture fitness:** dependency direction, runtime boundaries,
   performance, reliability, observability.
3. **Behavior:** whether the product actually does what was intended.

The behavior harness is the hardest. A green test suite written by the same
agent that interpreted the requirement is not an independent oracle.

Source: [Martin Fowler site, “Harness engineering for coding agent users”](https://martinfowler.com/articles/harness-engineering.html).

## What Loop Engineering Adds

LangChain describes four nested loops:

| Loop | Purpose | Repository interpretation |
| --- | --- | --- |
| Agent loop | Model calls tools until work is complete | inspect, edit, run commands, observe results |
| Verification loop | Grade output and feed failures back | lint/test/runtime checks followed by bounded repair |
| Event-driven loop | Trigger work from events or schedules | queued plans, CI feedback, scheduled maintenance |
| Hill-climbing loop | Improve the harness from observed runs | aggregate reviewed outcomes, propose and evaluate one harness change |

The fourth loop is the compounding one: its return arrow modifies the prompts,
tools, graders, or context used by the inner loops. That is also the dangerous
loop. If it learns from noisy traces, self-authored claims, or unreviewed
failures, it can optimize the grader instead of the product.

Source: [LangChain, “The Art of Loop Engineering”](https://www.langchain.com/blog/the-art-of-loop-engineering).

For this repository, an additional outer boundary is required:

- **Intent and authority loop:** a human defines observable outcomes,
  constraints, non-goals, maximum risk, and allowed actions before a
  non-trivial agent task begins.

Without that loop, faster implementation only accelerates ambiguous work.

## Long-Running Agents And Context Handoffs

Anthropic's long-running agent research identifies two recurring failures:

- agents try to complete too much in one pass and leave half-finished state;
- later sessions see partial progress and declare the larger task complete.

Their effective pattern is incremental work plus durable, structured handoff
artifacts. A new context should be able to reconstruct current intent, completed
work, remaining acceptance conditions, and the last verified state without
guessing from conversational history.

Their newer generator/evaluator work also reports that agents are overly
positive when judging their own output. A separate evaluator with explicit,
testable criteria is more useful than asking the implementation agent to praise
or critique itself. The evaluator is not always worth its cost; it should be
used near the boundary of what the current model can reliably do alone.

Sources:

- [Anthropic, “Effective harnesses for long-running agents”](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic, “Harness design for long-running application development”](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Anthropic, “Building effective agents”](https://www.anthropic.com/engineering/building-effective-agents)

The practical implications are:

- checked-in execution plans should carry durable decisions and progress;
- ignored controller state may carry hashes, attempts, and transient evidence;
- work should advance in small, independently verifiable increments;
- a separate review pass should use an explicit rubric and environmental
  evidence;
- harness complexity should be removed when model capability makes it
  unnecessary.

## Evals And Operating Evidence

Agent evaluation needs to distinguish the transcript from the outcome. An
agent saying “done” is transcript data; the app state, passing contract, or
device-observed behavior is the outcome.

Useful grader types are complementary:

- code-based: tests, lint, types, architecture rules, exact outcome checks;
- model-based: rubric review, semantic scope review, product or visual critique;
- human: acceptance meaning, taste, risk, and sensitive-action approval.

Regression suites should protect capabilities already demonstrated. Capability
evals may be noisier and measure progress on harder tasks. Multiple trials are
needed before making claims about a non-deterministic agent or a harness change.

Source: [Anthropic, “Demystifying evals for AI agents”](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents).

For `mobile-core-kit`, ordinary application tests are product sensors, not an
evaluation of whether the **agent harness** is improving. A future operating
ledger should record sanitized task outcomes such as risk, selected lanes,
first-pass result, repair count, duration, independent CI reproduction, and
human review. It should never store prompts, hidden reasoning, credentials,
environment values, raw logs, or unrestricted diffs.

## Robert C. Martin's Agent Guidance

Recent public discussion attributed to Robert C. Martin makes two related
points:

1. Traditional micro-step TDD techniques are inefficient for agents, even
   though testing remains essential. Techniques should adapt to the different
   strengths and failure modes of an agent.
2. Human attention should move from line-by-line implementation review toward
   strict constraints, acceptance behavior, QA procedures, and
   criticality-weighted checks.

X did not expose the relevant thread contents to the research tooling, so the
exact wording could not be independently verified from the primary page. These
ideas are supporting context, not normative evidence. Secondary
reconstructions include:

- [“The Idiot Savant Needs Guardrails”](https://paddo.dev/blog/idiot-savant-needs-guardrails/)
- [“Uncle Bob Doesn't Review AI Code. He Builds a Gauntlet Instead”](https://www.explainx.ai/blog/uncle-bob-ai-coding-gauntlet-tests-not-reviews-july-2026)

The safe interpretation is not “tests pass, therefore do not review.” It is:

- implementation throughput makes exhaustive human diff review a scaling
  bottleneck;
- humans should spend more attention on independent acceptance oracles and
  architecture constraints;
- agent-authored unit tests alone can confirm the agent's misunderstanding;
- review rigor must increase with consequence;
- periodic manual/runtime validation remains valuable;
- clean architecture makes the system easier to constrain and test, so it
  becomes more important rather than less.

## Current Mobile Harness Map

### Knowledge and intent

Current strengths:

- `AGENTS.md` defines simplicity, architecture, verification, risk, and agent
  workflow expectations.
- `docs/README.md` provides a useful documentation taxonomy.
- `docs/engineering/` contains architecture, UI state, testing, guardrail,
  runtime, and delivery sources of truth.
- `ADR/records/` captures durable template decisions.
- `docs/exec-plans/` separates active plans, completed plans, and technical
  debt.

Current weakness:

- plan fields are prose, not a machine-checkable authority contract;
- lifecycle consistency is not validated;
- five plans remain under `active/`, four marked “implementation complete,
  awaiting review,” and one lacks the normal status field;
- `AGENTS.md` contains no parseable core map, so `mobilekit project-map verify`
  exits successfully after skipping its check;
- `docs/_WIP/openai_harness_gap_analysis.md` still describes execution plans as
  missing even though that workflow has since been implemented, demonstrating
  why draft and reference-document lifecycle need mechanical visibility.

### Architecture and maintainability sensors

Current strengths:

- Clean Architecture dependency direction is configured in
  `lint/architecture_lints.yaml` and implemented by custom lints.
- service-locator imports are restricted to composition edges;
- Dio, Firebase, secure storage, shared preferences, and developer logging are
  constrained to approved adapters;
- API datasource calls must explicitly declare authentication behavior;
- route strings, localized UI text, modal entrypoints, colors, spacing,
  radii, font sizes, opacity, motion, and icon sizes are guarded;
- core, small-helper, and presentation duplication profiles exist with
  reviewed allowlists.

Current weaknesses:

- stale `lib/features/user/**` exceptions remain in architecture policy even
  though that feature no longer exists;
- the service-locator source comment says it is available “anywhere,” which
  contradicts the enforced composition-edge policy;
- ADR 0004 calls `app_router.dart` a thin composer, while it now owns account
  page effect handling and provider wiring;
- no gate-honesty fixtures prove that representative forbidden changes make
  each important sensor fail;
- there is no calibrated dead-code, complexity, or size baseline. Adding hard
  thresholds without measurement would be premature.

### Verification orchestration

Current strengths:

- `mobilekit` is already the correct repository-local command surface;
- `verify` owns an explicit fail-fast sequence;
- lint runs both Flutter analysis and custom lints;
- environment, config generation, localization, optional codegen, duplication,
  tests, and format checks are integrated;
- CLI and lint implementations have focused package tests.

Current weaknesses:

- the roughly 8,525-line CLI is safety-critical harness software, but
  `mobilekit verify` does not run the CLI package's own 16 test files;
- it also does not run the lint package's two test files. Android CI runs lint
  package tests separately, but no CI command was found for CLI package tests;
- `--check-codegen` is optional locally and enabled in Android/iOS CI, so the
  command called “canonical” has different strength by invocation;
- runtime evidence is separate from risk selection and is not run by normal CI;
- duplication is described as a self-review signal rather than a default hard
  gate, but the default `verify` workflow executes core and small-helper
  profiles as blocking steps;
- workflow definitions name `flutter`, and `CommandRunner` resolves it to the
  checkout-local FVM SDK when present before falling back to `PATH`; CI pins
  Flutter from `.fvmrc`, but a fallback run is not surfaced as weaker or
  different evidence;
- no stable failure taxonomy, task fingerprint, repair budget, or structured
  episode connects a failed gate to later repair.

### Runtime and behavior evidence

Current strengths:

- `mobilekit runtime evidence` discovers and runs integration tests on a named
  device;
- it captures summaries and logs under `_artifacts/mobile/`;
- auth happy path and startup/deep-link resume flows exist;
- golden tests and a 55% repository coverage floor run in governance CI;
- startup metrics, logs, screenshots, and trace IDs are available to agents.

Current weaknesses:

- only two device integration targets exist;
- device/runtime evidence is not selected from changed paths or task risk;
- the evidence workflow is not bound to a plan hash, base revision, changed
  paths, or exact verified source fingerprint;
- runtime logs are copied verbatim, and trace-ID lines are copied into the
  summary without an explicit redaction contract;
- metadata includes the absolute repository path;
- the workflow may copy example environment files and a supplied Firebase
  configuration into the primary worktree;
- there is no retention, content-size, secret-shape, or PII negative test for
  evidence artifacts;
- there is no device single-flight or isolated-worktree policy;
- the backend OpenAPI source of truth is an external absolute filesystem path,
  which is not available to clean CI or cloned product repositories.

### CI and delivery

Current strengths:

- GitHub workflows cover Android, iOS no-codesign build, coverage, goldens,
  dependency review, and secret scanning;
- CI permissions are read-only by default;
- the Flutter version is read from `.fvmrc`;
- platform configuration is restored or checked before builds;
- release publishing is deliberately disabled by default.

Current weaknesses:

- workflows duplicate bootstrap and verification decisions outside a typed
  profile registry;
- there is no path/risk classifier selecting required lanes;
- there is no stable aggregate required job;
- third-party actions use mutable major tags rather than immutable commit SHAs;
- integration tests are not independently reproduced on an emulator/simulator
  in normal CI;
- local runtime evidence is not independent integration proof;
- verification output is not captured as a sanitized machine-readable result.

### Event and learning loops

Current state:

- the two-strike “promote repeated failure into the harness” rule is documented;
- duplication and architecture reports support manual gardening;
- no scheduled workflow, queued task intake, reviewed operating ledger,
  recurring trend analysis, shadow evaluation, or controlled improvement
  lifecycle exists.

This means the repository has the policy for learning but not the evidence
system required to learn safely.

## Cross-Core-Kit Comparison

The other core kits show that the desired direction can remain
repository-local and simple.

| Capability | Mobile | Frontend | Backend | Mobile opportunity |
| --- | --- | --- | --- | --- |
| Canonical command | `mobilekit verify` | pnpm profiles | typed `backendkit` profiles | retain `mobilekit`; add explicit profiles/parity |
| Architecture sensor | strong custom lints | structural scripts | dependency-cruiser + smells | preserve custom lints as immutable invariant |
| Task authority | prose plans | V2 boundaries/actions | V2 plans + fingerprints | adopt a mobile V2 plan contract |
| Risk selection | manual | changed-path classifier | changed paths + impact lanes | add conservative mobile path/impact rules |
| Repair loop | manual reruns | bounded task verification | stable failures + bounded repair | add stable failure categories and stop conditions |
| Workspace isolation | guidance only | task baseline, no full parity | owned worktrees for current agent | use worktrees; serialize physical-device lanes |
| Runtime proof | device CLI artifacts | Playwright fixture/browser | Docker integration/E2E | bind device evidence to task fingerprint and sanitize |
| Independent CI | broad but fragmented | risk/full/runtime/aggregate | risk/full/runtime/governance/aggregate | canonical mobile CI profiles and aggregate status |
| Operating evidence | none | reviewed sanitized ledger | stricter reviewed ledger | adopt schema only after task controller is stable |
| Hill climbing | informal two-strike rule | queued proposal | read-only controlled implementation | defer until reviewed mobile evidence is eligible |

The backend implementation is the most complete local reference, but copying
its TypeScript controller would be wrong. Mobile already owns an 8.5k-line Dart
CLI and different runtime constraints. Reuse the contracts and safety
decisions, not the code.

## Prioritized Opportunities

### P0 — Make existing claims truthful

1. Replace the no-op project-map check with a broader knowledge check that
   validates document links, plan lifecycle, required plan fields, and a real
   architecture map.
2. Define explicit `fast`, `full`, `runtime`, and `ci` profiles in `mobilekit`.
3. Make local/CI profile parity testable.
4. Include CLI and lint package tests in the appropriate canonical profile.
5. Resolve whether codegen and duplication are mandatory gates or advisory
   lanes; commands and docs must agree.
6. Record a baseline of profile duration, test inventory, coverage, and known
   missing sensors before adding more thresholds.

### P1 — Turn plans into task contracts

1. Add V2 plan metadata: stable task ID, status, owner, risk, allowed paths,
   allowed actions, maximum risk, repair limit, timeout, and impact areas.
2. Capture base revision and pre-existing dirty paths in ignored local task
   state.
3. Classify changed paths conservatively; automation may raise risk and never
   lower human-declared risk.
4. Select verification lanes from effective risk and impacts such as auth,
   session, navigation, API contracts, database, platform, CI, and harness.
5. Add stable failure categories, task fingerprints, bounded repair, and
   deterministic escalation.

### P1 — Strengthen behavioral independence

1. Require human-approved acceptance scenarios for medium/high-risk behavior.
2. Map critical mobile scenarios to independent evidence: existing regression
   tests, backend contract, golden baseline, integration target, or manual
   device procedure.
3. Establish a repository-owned or pinned OpenAPI artifact for clean-checkout
   contract verification; do not rely on an absolute sibling-repository path.
4. Add negative gate fixtures for architecture, risk selection, evidence
   redaction, and critical session/navigation behavior.
5. Pilot mutation testing only on a small pure policy module after baseline
   measurement; do not add repository-wide mutation testing by default.

### P2 — Isolate and observe agent work

1. Let the current conversational agent prepare and rediscover an owned Git
   worktree; repository code should not launch another model or agent.
2. Keep controller state in ignored, atomic, schema-versioned files.
3. Bind successful verification and runtime artifacts to the exact plan,
   authority, base revision, and changed-source fingerprint.
4. Redact and cap logs before durable storage; store stable categories and
   hashes rather than raw output.
5. Serialize device lanes initially. Per-worktree emulator/app-ID multiplexing
   is unnecessary until real concurrency pressure proves it useful.

### P3 — Add event-driven maintenance

Start with one-shot, read-only operations:

- validate queued plans;
- check knowledge and plan drift;
- refresh architecture and duplication observations;
- inspect dependency and generated-code drift;
- report stale plans and runtime evidence;
- never create authorized work from an untrusted event.

An external scheduler may invoke these commands. The repository does not need a
daemon, queue, or agent platform.

### P4 — Add controlled hill climbing only from reviewed outcomes

Before any improvement recommendation is enabled, require a small but diverse
set of real tasks with:

- independent human review;
- clean-checkout CI reproduction;
- at least two risk classes;
- at least one repair or escalation;
- valid sanitized evidence;
- no unresolved privacy or schema issue.

Each proposed harness change should name a recurring failure, affected task
IDs, target component, predicted improvement, evaluation window, immutable
invariants, rollback files, and human owner. Evaluate it in shadow mode and
keep or revert it from later outcomes. The harness must not approve, edit,
publish, or merge its own improvement.

## Invariants For Mobile-Core-Kit

The following should remain true through every harness phase:

1. Clean Architecture dependency direction remains mechanically enforced.
2. Core stays feature-agnostic except explicit composition boundaries.
3. Features do not gain cross-feature imports to make an agent task easier.
4. Service location remains restricted to composition edges.
5. External data is validated or mapped at boundaries; DTOs do not leak into
   domain or presentation.
6. The harness may raise risk, add verification, or stop work; it may not
   silently lower risk or weaken required evidence.
7. Human intent owns acceptance meaning and architecture decisions.
8. Agent output, logs, issue text, comments, and external responses are
   untrusted input.
9. Commit, push, PR, merge, deployment, signing, migration, and external
   mutation authority are distinct actions.
10. Harness changes are high risk and require tests, independent verification,
    and rollback.
11. Simplicity is a control: no agent framework, database, queue, or dynamic
    orchestration service is added without operating evidence.

## What Not To Do

- Do not replace Clean Architecture with a looser “agents can navigate it”
  structure. Predictable boundaries are a major source of agent leverage.
- Do not trust agent-authored unit tests as the only behavioral oracle.
- Do not make every expensive test run on every edit.
- Do not introduce a second CLI or nested coding-agent runtime.
- Do not store raw agent traces, prompts, reasoning, credentials, or full logs
  in a durable ledger.
- Do not schedule automatic source edits before read-only maintenance has
  produced useful evidence.
- Do not auto-merge merely because throughput increases.
- Do not add generic complexity, file-size, or coverage targets without a
  measured baseline and a demonstrated failure they prevent.
- Do not copy the backend/frontend implementations wholesale; align contracts
  across core kits while preserving platform-specific tooling.

## Research Conclusion

The mobile repository is not starting from zero. Its strongest differentiator
is already the right one: architecture and product conventions are encoded as
repository-local software. The next step is to connect those sensors to a
task-aware, risk-aware, evidence-producing loop.

The safest path is progressive:

1. make current gates and knowledge claims truthful;
2. bind human intent and authority to a structured task;
3. select and repeat verification based on risk;
4. isolate work and sanitize evidence;
5. add event-driven observation;
6. learn from independently reviewed outcomes;
7. keep humans at product, architecture, risk, and external-action boundaries.

This moves human effort upward without pretending that tests, agents, or
automation can define the product's meaning on their own.
