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
dart run tool/verify.dart --env dev
```

Targeted checks when the full gate is unnecessary or too expensive:

```bash
fvm flutter analyze
dart run custom_lint
fvm flutter test
dart run tool/verify_project_map_drift.dart
./tool/check_duplication.sh
./tool/check_presentation_duplication.sh
```

Use native commands as the source of truth for verification.

Use `./tool/check_duplication.sh` when the change is likely to introduce or
reshape shared logic, for example:
- extraction/consolidation refactors
- new helpers, mappers, formatters, or parsers
- repeated workflow tails
- cleanup work prompted by agent-generated duplication

Treat the duplication report as a self-review signal, not a default hard gate.
The report distinguishes:
- `actionable` duplicate groups: open maintainability debt worth review
- `reviewed acceptable` duplicate groups: explicitly reviewed and recorded in
  `tool/duplication_allowlist.json`

Use `./tool/check_presentation_duplication.sh` for Flutter presentation-heavy
changes such as:
- repeated form pages or settings pages
- repeated cubit validation/failure handling in `presentation/cubit/`
- repeated micro-widgets or page-local display helpers

This presentation check is intentionally separate from the main duplication
check. It focuses on narrow presentation patterns and uses its own allowlist:
- `tool/presentation_duplication_allowlist.json`

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
