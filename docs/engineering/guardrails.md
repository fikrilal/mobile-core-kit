# Guardrails

This document explains the mechanical guardrails that keep the codebase consistent and reviewable.

Use this document when the question is:
- what checks exist?
- where do they live?
- when should we add a new guardrail?

Use `docs/engineering/agent_pr_loop.md` for the delivery workflow.

## Principles

Guardrails should make the correct path the easiest path.

Prefer guardrails that are:
- deterministic
- cheap to run locally
- hard to misinterpret
- better than repeating the same review comment

Do not add a new guardrail unless it solves repeated real pain.

## Canonical Commands

Safe auto-fix:

```bash
dart run mobile_core_kit_cli:mobilekit fix --apply
```

Fast inner loop and canonical full gate:

```bash
dart run mobile_core_kit_cli:mobilekit verify --profile fast --env dev
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Targeted checks:

```bash
dart run mobile_core_kit_cli:mobilekit lint
fvm flutter test
dart run mobile_core_kit_cli:mobilekit codegen verify
dart run mobile_core_kit_cli:mobilekit project-map verify
dart run mobile_core_kit_cli:mobilekit knowledge verify
```

When using a globally activated checkout-local CLI, refresh the activation if
the command appears to run stale code:

```bash
dart pub global deactivate mobile_core_kit_cli
dart pub global activate --source path packages/mobile_core_kit_cli
```

## Where Guardrails Live

### Analyzer and lint policy
- `analysis_options.yaml`
- `lint/architecture_lints.yaml`
- `packages/mobile_core_kit_lints/`

### Verification pipeline
- `packages/mobile_core_kit_cli/`
- repository-local policy/configuration data under `lint/`, `duplication/`, and
  the root `.jscpd*.json` files

### Scaffolding
- `mobilekit scaffold feature`

### CI
- `.github/workflows/android.yml`

## What The Guardrails Enforce

### 1. Architecture boundaries

Enforced through custom lints and lint config.

Examples:
- `core` must not import features by default
- feature domain must stay framework- and infra-free
- feature-to-feature imports are restricted
- service locator usage is limited to composition roots

Source of truth:
- `docs/engineering/architecture_linting.md`

### 2. UI/content consistency

Examples:
- no hardcoded user-facing strings in UI contexts
- no route string literals when route constants should be used
- no hardcoded design-token values where linted tokens exist

### 3. Networking policy

Examples:
- feature datasources must use the approved HTTP helper conventions
- explicit request defaults are required where the lint enforces them

### 4. Repo-level verification

Examples:
- localization generation/hygiene
- modal entrypoint checks
- hardcoded color checks
- generated code freshness
- formatting
- tests

## When To Add A New Guardrail

Add a guardrail when:
- the same bug or review comment appears repeatedly
- the rule is objective enough to automate
- the automation is cheaper than future human review effort

Choose the lightest mechanism that solves the problem:
1. config change
2. lint rule
3. CLI workflow
4. scaffold/template update
5. doc or source-local README

## How To Extend The Guardrails

### Lint/config path
Use when the rule is local, structural, or AST-detectable.

Typical path:
- update `lint/architecture_lints.yaml`
- or add/extend a custom lint in `packages/mobile_core_kit_lints/`
- update tests for the lint plugin when needed
- document stable policy in `docs/engineering/architecture_linting.md`

### Verify-workflow path
Use when the rule is repository-wide and better expressed as a command.

Typical path:
- add or update the implementation under `packages/mobile_core_kit_cli/`
- keep repository policy/configuration data under root-owned directories such as
  `lint/` and `duplication/`
- call it from `mobilekit verify` if it belongs in the canonical gate
- ensure local and CI usage stay aligned

### Scaffold/template path
Use when the problem is caused by bad starting structure rather than bad edits.

Typical path:
- update the implementation behind `mobilekit scaffold feature`
- update relevant templates/docs

## Suppressions

Suppress lint rules rarely and narrowly.

If suppressions become common, fix the rule or the boundary instead.

## Related Docs

- `docs/engineering/agent_pr_loop.md`
- `docs/engineering/mobilekit_cli_reference.md`
- `docs/engineering/architecture_linting.md`
- `docs/engineering/project_architecture.md`
