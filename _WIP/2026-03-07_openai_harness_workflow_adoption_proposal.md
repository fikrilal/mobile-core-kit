# Engineering Proposal: Adopt Harness-Engineering Principles Without Copying OpenAI's Merge Philosophy

Date: 2026-03-07
Status: Draft proposal
Reference: https://openai.com/index/harness-engineering/

## 1. Decision Summary

We should adopt the core harness-engineering principles from OpenAI's workflow, but not copy their full operating model wholesale.

Adopt:
- repository-local agent instructions and architecture docs as first-class engineering assets
- mechanical enforcement over prose-only guidance
- explicit execution plans for non-trivial work
- runtime evidence capture for medium/high-risk changes
- recurring failure -> harness upgrade feedback loops
- codebase legibility as an engineering goal

Do not adopt blindly:
- low-friction merge policy for risky work
- minimal blocking gates as a default
- ideology around zero human-written code
- broad permission for agent-authored changes without explicit evidence
- replacing primary human ownership with agent-only review

Recommended stance for this repository:
- `agent-first execution`
- `human-reviewed merge policy for medium/high-risk changes`
- `strict mechanical verification before merge`

This matches the repository's risk profile better than a pure OpenAI-style high-throughput internal loop.

## 2. Why This Proposal Exists

The OpenAI article is directionally correct about one thing: the highest leverage is not the coding model itself, but the harness around it.

For this repository, the relevant question is not:
- "Should we copy OpenAI's workflow?"

The relevant question is:
- "Which harness practices increase quality and throughput here without reducing production safety?"

This repository already has several strong harness elements:
- `AGENTS.md`
- architecture lints
- `mobilekit verify`
- execution-plan docs
- runtime harness docs
- source-local boundary READMEs

So the right move is not a greenfield workflow rewrite. The right move is to tighten and complete the harness we already started.

## 3. Current State Assessment

### 3.1 What We Already Have

Strong existing pieces:
- repository-local operating rules in `AGENTS.md`
- architecture guidance in `docs/engineering/`
- custom lints enforcing boundaries and UI conventions
- a full verify pipeline in `mobilekit verify`
- execution-plan workflow in `docs/exec-plans/`
- agent PR loop doc in `docs/engineering/agent_pr_loop.md`
- mobile runtime harness doc in `docs/engineering/mobile_runtime_harness.md`
- source-local boundary docs such as:
  - `lib/core/domain/README.md`
  - `lib/core/runtime/session/README.md`
  - `lib/features/auth/README.md`

This means the repo is already partially operating in a harness-engineering model.

### 3.2 What Is Missing

The harness is still uneven in a few places:
- PR evidence and risk discipline are documented, but not fully enforced by a single stable gate
- runtime evidence exists as a workflow, but not as a universal expectation for medium/high-risk mobile changes
- repeated review lessons are still partly captured ad hoc instead of consistently promoted into lint/check/template/doc updates
- some agent-related docs and scripts still feel additive rather than opinionated and minimal
- codebase legibility for agents is improving, but not yet consistently treated as a repo-level design objective

### 3.3 What Would Be a Mistake

The wrong adoption path would be:
- making merge gates lighter because agents are "usually right"
- accepting large agent-authored PRs with weak evidence
- adding more scripts/docs without clear enforcement value
- optimizing for agent speed while increasing human review ambiguity

## 4. Proposed Operating Model

### 4.1 Core Principle

Use the OpenAI workflow as a harness-design reference, not as a merge-policy template.

For this repository, the operating model should be:
- agents can implement most changes end-to-end
- the repository must make correct behavior easy to prove
- high-risk changes still require strong evidence and human accountability

### 4.2 Target Workflow

1. Task intake
- classify risk up front
- create an execution plan for non-trivial work

2. Implementation
- prefer small, focused, reversible changes
- keep architecture boundaries explicit
- improve legibility when touching a confusing area

3. Machine verification
- run `dart run mobile_core_kit_cli:mobilekit verify --env dev` for non-trivial changes
- collect targeted evidence for risky flows when needed

4. Runtime evidence for medium/high-risk mobile changes
- use the mobile runtime harness for device-level evidence
- attach machine-checkable evidence to the PR

5. Self-review
- confirm acceptance criteria
- confirm architecture compliance
- confirm no speculative refactors are mixed in

6. Human merge review by risk class
- low: may merge with passing checks
- medium: human review strongly recommended
- high: human review required

This preserves the useful parts of agent-first execution without weakening release safety.

## 5. What We Should Adopt From OpenAI's Workflow

### 5.1 Repository-Local Knowledge As System Of Record

Adopt fully.

Implication for this repo:
- important architectural rules should live in repo docs or source-local READMEs
- if an area is repeatedly misunderstood, write down the boundary close to the code
- agent-operable knowledge should be discoverable by search, not held implicitly by one maintainer

Concrete rule:
- if an engineer must explain the same placement or ownership rule twice, promote it into docs, lint, or a local README

### 5.2 Mechanical Enforcement Over Prose-Only Guidance

Adopt aggressively.

Implication for this repo:
- prefer lints, verify checks, and deterministic scripts over long review comments
- if a failure class repeats, upgrade the harness

Concrete examples already aligned with this:
- architecture import linting
- modal entrypoint lint
- hardcoded style token lints
- project-map drift verification

### 5.3 Execution Plans As First-Class Artifacts

Adopt and keep.

This repo already moved in the right direction with `docs/exec-plans/`.

The rule should be:
- any multi-phase or risky refactor gets a plan before implementation
- plan files should record assumptions, checkpoints, and rollback-safe phases

### 5.4 Runtime Evidence As Part Of Engineering, Not Optional Polish

Adopt more consistently.

The repo already has `docs/engineering/mobile_runtime_harness.md`.

What should change:
- medium/high-risk mobile changes should routinely attach runtime evidence
- this should stop being a nice-to-have and become part of the expected delivery contract

### 5.5 Legibility As A Design Goal

Adopt explicitly.

Meaning:
- clear module boundaries
- stable naming
- discoverable documentation
- minimal hidden coupling
- avoid cleverness that saves lines but hurts future reasoning

This is the most important conceptual takeaway from the OpenAI article.

## 6. What We Should Not Adopt

### 6.1 Low-Friction Merge Policy For Risky Work

Do not adopt.

Why:
- this repository touches auth, session, navigation, API contracts, and mobile runtime behavior
- the cost of a subtle regression is materially higher than the cost of an extra review pass

Policy recommendation:
- keep strict merge discipline for medium/high-risk changes
- require explicit evidence, not confidence language

### 6.2 "0 Human-Written Code" As A Goal

Do not adopt.

Reason:
- the goal is leverage and correctness, not workflow purity
- manual intervention is acceptable when it is the simplest correct action

### 6.3 Harness Sprawl

Do not adopt.

Meaning:
- do not add scripts, docs, and checkers unless they address repeated real pain
- every harness component must justify its maintenance cost

## 7. Concrete Proposal For This Repository

### 7.1 Adopt A Three-Level Harness Model

Level 1: Repository rules
- `AGENTS.md`
- architecture docs
- ADRs for durable repo-level decisions

Level 2: Mechanical gates
- `mobilekit verify`
- custom lints
- drift checks
- codegen checks

Level 3: Runtime evidence
- device/emulator evidence for medium/high-risk changes
- machine-readable logs and summaries attached to PRs

This gives a clean model:
- docs explain intent
- checks enforce rules
- runtime evidence proves behavior

### 7.2 Make Risk Classification Operational

Current docs discuss risk, but the workflow should treat it as a real input.

Recommendation:
- low-risk: code checks are enough
- medium-risk: code checks + targeted runtime evidence
- high-risk: code checks + runtime evidence + mandatory human review

This is the correct compromise between speed and safety.

### 7.3 Standardize The Failure -> Harness Upgrade Loop

Recommendation:
- when a bug/review failure repeats twice, promote it deliberately into one of:
  - lint rule
  - CLI verification workflow
  - template/scaffold update
  - source-local README
  - engineering doc

This is one of the strongest ideas in the OpenAI workflow and should become more explicit in daily practice here.

### 7.4 Optimize For Smaller Agent PRs

Recommendation:
- prefer smaller, reviewable PRs with focused evidence
- avoid long-lived large divergence branches when possible

Why:
- this repo already showed the downside: large agent-heavy branches become expensive to merge and reason about
- harness quality is highest when deltas are small and evidence is fresh

## 8. Recommended Changes To Implement

### Phase 1: Tighten Existing Workflow

Do first.

1. Update `docs/engineering/agent_pr_loop.md`
- align it to the current native command policy
- explicitly tie risk class to runtime evidence expectations
- reduce ambiguity around when runtime evidence is required

2. Review runtime CLI commands
- keep only commands that provide clear, repeated value
- remove or consolidate any that are additive but not essential

3. Add a short section to `docs/engineering/project_architecture.md`
- state that agent legibility is a repo-level design goal
- connect this to docs, boundaries, and mechanical enforcement

### Phase 2: Strengthen PR Evidence Discipline

1. Update `.github/pull_request_template.md`
- require risk class
- require checks executed
- require runtime evidence section for medium/high-risk changes
- require explicit follow-ups if the change is intentionally partial

2. Make the expected evidence examples concrete
- include sample artifact paths
- include sample log evidence
- include example runtime-harness commands

### Phase 3: Close The Feedback Loop

1. Add a lightweight rule to execution plans
- repeated review comments must be considered for harness promotion

2. Periodically clean agent-generated drift
- docs that no longer reflect actual commands
- scripts with overlapping purpose
- outdated examples

## 9. Success Criteria

This proposal is successful if, after adoption:
- non-trivial agent changes consistently arrive with plan + checks + evidence
- repeated review comments decrease because rules are promoted into the harness
- PRs become easier to review because risk and evidence are explicit
- docs become more useful to agents and humans instead of becoming generic volume
- high-risk changes remain conservative even while implementation throughput improves

## 10. Decision

Adopt OpenAI's harness-engineering principles selectively.

Use them to strengthen:
- legibility
- enforcement
- execution planning
- runtime proof
- feedback-loop discipline

Do not use them to justify:
- weaker merge controls
- larger ambiguous PRs
- agent autonomy without evidence
- harness complexity without proven need

## 11. Immediate Recommendation

Approve this direction and implement only the Phase 1 changes first.

Reason:
- the repository already has the right foundations
- the highest-leverage next step is tightening the current harness, not expanding it dramatically
- this keeps the workflow pragmatic, conservative, and maintainable
