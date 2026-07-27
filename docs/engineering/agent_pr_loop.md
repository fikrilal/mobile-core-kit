# Agent PR Loop

This document defines the default delivery loop for agent-authored changes in this repository.

Goal:
- keep PRs predictable
- keep review cost low
- preserve production safety while moving fast

## Scope

Use this loop for any change authored primarily by an AI coding agent.

For non-trivial changes, create an execution plan first:
- `docs/exec-plans/README.md`
- `docs/exec-plans/active/`

## Sources Of Truth

Use these documents together, not interchangeably:
- operating contract: `AGENTS.md`
- architecture rules: `docs/engineering/project_architecture.md`
- mechanical enforcement: `docs/engineering/guardrails.md`
- runtime evidence: `docs/engineering/mobile_runtime_harness.md`
- multi-agent coordination: `docs/engineering/parallel_agent_workflow.md`

## Loop Contract

### 1. Task intake

Before implementation starts:
- write a clear task statement
- define acceptance criteria
- classify risk
- create a plan file for non-trivial work

Risk classes:
- `low`: local UI/refactor/tests/docs with no auth/network/session/runtime/release impact
- `medium`: feature behavior change, navigation change, data mapping/API usage changes
- `high`: auth/session/security, payment/billing, data migration, CI/release/infra changes

### 2. Implement

During implementation:
- keep changes small and reversible
- follow architecture boundaries and existing conventions
- avoid speculative refactors mixed into the requested change
- prefer explicit behavior over hidden coupling

### 3. Mechanical verification

Canonical local gate for non-trivial work:

```bash
dart run mobile_core_kit_cli:mobilekit verify --env dev
```

Targeted checks when the full gate is unnecessary or too expensive:

```bash
fvm flutter analyze
dart run custom_lint
fvm flutter test
dart run mobile_core_kit_cli:mobilekit project-map verify
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
```

Use native commands as the source of truth for verification.

Use `dart run mobile_core_kit_cli:mobilekit duplication check --profile core` when the change is likely to introduce or
reshape shared logic, for example:
- extraction/consolidation refactors
- new helpers, mappers, formatters, or parsers
- repeated workflow tails
- cleanup work prompted by agent-generated duplication

Treat duplication detection as a self-review signal, not a default hard gate.
See `docs/engineering/duplication_harness.md` for:
- when to run the core vs small-helper vs presentation profile
- how to interpret actionable vs reviewed acceptable groups
- how to record allowlist entries

### 4. Runtime evidence (when required)

Runtime evidence is expected for:
- medium/high-risk mobile UI changes
- runtime/session/navigation changes
- changes where static checks do not prove behavior sufficiently

Collect runtime evidence using:
- `docs/engineering/mobile_runtime_harness.md`

Typical evidence includes:
- device/emulator ID
- flavor
- executed integration target(s)
- artifact paths
- relevant log snippets

### 5. Self-review

Before opening or updating the PR, verify:
- acceptance criteria are fully met
- architecture boundaries are respected
- tests were added/updated where behavior changed
- failure paths are explicit and observable
- no speculative work is bundled into the PR
- runtime evidence is attached when risk warrants it
- duplication was checked when the change touched shared logic or repeated helper
  patterns, and any acceptable duplicates were reviewed explicitly rather than
  ignored informally

### 6. Open PR with evidence

Use:
- `.github/pull_request_template.md`

Include:
- risk class and impact notes
- exact checks executed and outcomes
- runtime evidence when relevant
- known follow-ups or deferred debt
- reviewer focus areas

### 7. Review iteration loop

For substantive follow-up changes:
- address comments in small deltas
- rerun the relevant checks
- rerun the full gate if the change materially affects behavior or risk
- refresh runtime evidence when the reviewed behavior changed

### 8. Merge policy

- `low`: merge after required checks pass
- `medium`: human review strongly recommended
- `high`: human review required

## Failure -> Harness Upgrade Rule

If the same class of failure appears 2+ times, do not rely on repeated manual fixes.
Promote it into one of:
- lint rule
- verify script
- scaffolder/template update
- engineering doc update
- source-local `README.md`

## Definition Of Done

A PR is done only when:
1. acceptance criteria are met
2. required checks pass
3. risk-class review expectations are satisfied
4. evidence is present when the change needs runtime proof
