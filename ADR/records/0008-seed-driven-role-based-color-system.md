---
status: accepted
date: 2026-01-16
decision-makers: Dante
consulted: design
informed: engineering
scope: template
tags: [theme, design-system, accessibility, colors]
tracking:
---

# Seed-driven, role-based color system (neutral elevation + contrast gates)

## Context and Problem Statement

Template projects tend to accumulate “palette drift”: screens hardcode hex values or use palette-step ramps
directly, leading to inconsistent UI, accessibility regressions, and painful rebrands.

We need an enterprise-grade color system where:

- UI consumes a stable **semantic contract** (roles), not palette steps.
- A small set of inputs (seeds) can update the entire theme deterministically.
- Accessibility (contrast) is enforced automatically, not by convention.

## Decision Drivers

* Accessibility: WCAG contrast must be enforceable and hard to bypass.
* Consistency: the same color role should mean the same thing everywhere.
* Low maintenance: minimal custom color math; no third-party color packages.
* Scalability: new components should work by consuming roles, not inventing new colors.
* Mobile-first parity: works well on both Android and iOS (Material widgets on iOS are acceptable).
* Governed escape hatches: rare exceptions are explicit and reviewable.

## Considered Options

* Option A: `ColorScheme.fromSeed` + role contract (`ColorScheme` + `SemanticColors`) + automated gates
* Option B: In-house tonal palettes (tone 0–100) + mapping tables for all roles
* Option C: Palette-step tokens (e.g. neutral/100..900) used directly by UI

## Decision Outcome

Chosen option: **Option A**, because it produces complete role sets with minimal custom logic, keeps the
public API role-based, and allows us to enforce accessibility and consistency with tests + linting.

### Consequences

* Good, because UI code consumes stable roles:
  - `Theme.of(context).colorScheme` / `context.cs.*`
  - `context.semanticColors.*` for success/info/warning
* Good, because theme changes are governed via a small seed surface:
  - `lib/core/theme/system/app_color_seeds.dart`
* Good, because accessibility is gated:
  - `test/core/theme/color_contrast_test.dart` enforces WCAG thresholds
* Good, because we can choose policy-level composition:
  - **Neutral elevation** is implemented by sourcing `surfaceTint` from the neutral scheme.
* Bad, because derived secondary/tertiary hues may not match strict brand palettes without overrides.
* Bad, because the role mapping is tied to Flutter’s Material 3 algorithm (which can shift between Flutter versions).

### Confirmation

Compliance is validated by:

1) Automated WCAG contrast gate:
   - `test/core/theme/color_contrast_test.dart`
2) Policy invariant test (neutral elevation):
   - `test/core/theme/color_builder_policy_test.dart`
3) Guardrails against hardcoded UI colors:
   - Lint: `hardcoded_ui_colors` (configured in `analysis_options.yaml`)
   - CI tool: `tool/verify_hardcoded_ui_colors.dart` (wired into `tool/verify.dart`)
4) Visual QA:
   - Dev-only screen: `lib/core/dev_tools/theme/theme_roles_showcase_screen.dart`

## Pros and Cons of the Options

### Option A: `ColorScheme.fromSeed` + role contract + automated gates

* Good, because it is complete-by-default (reduces drift when new components use `ColorScheme` roles).
* Good, because it avoids owning perceptual color math.
* Good, because it stays aligned with Flutter Material component expectations.
* Neutral, because a few roles may need policy overrides (e.g. neutral surfaces).
* Bad, because it may not satisfy strict brand palette requirements without controlled overrides.

### Option B: In-house tonal palettes + mapping tables

* Good, because it allows maximum brand control.
* Bad, because it requires implementing/owning perceptual color math + validation tooling (high risk and maintenance cost).

### Option C: Palette-step tokens used directly by UI

* Good, because it is easy to start and matches common design tooling ramps.
* Bad, because it scales poorly: drift, inconsistent semantics across light/dark, and hard-to-enforce accessibility.

## More Information

Implementation entry points:

- Seeds: `lib/core/theme/system/app_color_seeds.dart`
- Builder: `lib/core/theme/system/app_color_scheme_builder.dart`
- Status roles: `lib/core/theme/extensions/semantic_colors.dart`
- Usage rules: `docs/explainers/core/theme/color_usage_guide.md`
- Under the hood: `docs/explainers/core/theme/color_system_under_the_hood.md`

