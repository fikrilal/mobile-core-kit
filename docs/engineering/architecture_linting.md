# Architecture Linting

This document explains the lint-enforced architecture boundaries in this template.

Use this document when the question is:
- what architectural imports are allowed?
- where is the source of truth for those rules?
- how should a boundary be updated when the architecture evolves?

## Purpose

Architecture lints exist to make boundary violations:
- hard to introduce accidentally
- easy to detect locally
- cheap to review

The goal is not folder symmetry. The goal is explicit dependency direction.

## Where The Rules Live

Primary sources of truth:
- `tool/lints/architecture_lints.yaml`
- `analysis_options.yaml`
- `packages/mobile_core_kit_lints/`

Run locally with:

```bash
dart run custom_lint
```

The canonical gate also runs them:

```bash
dart run tool/verify.dart --env dev
```

## What Is Enforced

### 1. Core -> feature boundaries

Default rule:
- `lib/core/**` must not import `lib/features/**`

Exceptions must be explicit and rare.
Use them only when the architecture intentionally allows a composition boundary.

Examples of acceptable exceptions:
- feature DI composition
- temporary migration seams that are documented and scheduled for removal

### 2. Feature domain purity

Feature `domain/` code must stay framework- and infra-free.

Feature domain should not import:
- feature `data/`
- feature `presentation/`
- navigation
- network/storage/database implementations
- UI/theme/design-system code
- DI
- localization generators

This keeps the domain layer portable and easy to test.

### 3. Feature -> feature boundaries

Default rule:
- features do not import other feature code directly

If something is genuinely shared, it should move to:
- `lib/core/**`
- or a dedicated shared package if the codebase grows to that point

This rule matters even when features use different internal shapes.
A feature may be:
- flat
- presentation-first subfeatures
- full vertical subfeatures

The lint should enforce dependency boundaries, not force all features to look identical.

### 4. Service locator boundaries

Only composition roots should import the service locator directly.

Typical allowed scopes:
- core DI/bootstrap
- feature DI modules
- navigation route builders
- app entrypoints

Typical disallowed scopes:
- feature presentation widgets
- feature repositories/datasources
- design system code
- low-level infrastructure code

Rule:
- resolve dependencies in composition
- pass them down via constructors or providers

### 5. Restricted low-level dependencies

Some low-level packages should only appear in approved scopes.

Typical examples:
- networking packages in networking infrastructure only
- secure storage packages in secure-storage infrastructure only
- analytics/crash-reporting SDKs in dedicated runtime/platform adapters only

This keeps future migrations cheaper and prevents vendor spread.

### 6. UI/content/navigation guardrails

Related custom lints also enforce adjacent policy such as:
- no hardcoded user-facing strings in UI contexts
- no route string literals when route constants should be used
- no hardcoded tokenized design values where project policy already defines tokens

These are not architecture boundaries in the strict sense, but they serve the same review goal: reduce drift and ambiguity.

## How To Change A Boundary Safely

When a lint starts fighting the architecture, do not suppress it by default.

Instead ask:
1. Is the code in the wrong layer?
2. Is the architecture rule too strict for a valid pattern?
3. Is this a temporary migration seam that should be allowlisted with a removal plan?

Preferred order of action:
1. move the code to the correct boundary
2. refine config in `tool/lints/architecture_lints.yaml`
3. add a temporary documented exception
4. only then consider a tightly-scoped suppression

## Temporary Exceptions

Temporary exceptions are acceptable only when all are true:
- there is a real migration in progress
- the boundary is intentionally transitional
- the exception is documented
- there is a plan to remove it

Do not normalize temporary allowlists into permanent architecture.

## Adding Or Extending Rules

### Config-first

Prefer config changes when the rule is about import boundaries.

Typical path:
- update `tool/lints/architecture_lints.yaml`
- verify locally with `dart run custom_lint`
- document the stable policy here if the rule changes conceptually

### Custom lint path

Use a custom lint implementation when the rule needs AST-level analysis beyond import globs.

Typical path:
- add or extend the lint in `packages/mobile_core_kit_lints/`
- add tests for the lint package
- expose/configure it in `analysis_options.yaml`
- document the stable behavior in the relevant engineering guide

## Troubleshooting

- `flutter analyze` does not run custom lints. Use `dart run custom_lint` or the full verify gate.
- If the IDE is not showing custom-lint diagnostics:
  - confirm `custom_lint` is in `dev_dependencies`
  - confirm `analysis_options.yaml` enables the plugin
  - run dependency install
  - restart the Dart/Flutter analysis server

## Related Docs

- `docs/engineering/project_architecture.md`
- `docs/engineering/guardrails.md`
- `docs/engineering/data_domain_guide.md`
