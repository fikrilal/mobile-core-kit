# Typography System Review (Current State + Recommendations)

This is a deep review of the current typography system under `lib/core/design_system/theme/typography/`, with an “enterprise standard” lens: clarity of contract, accessibility correctness, governance/guardrails, and long-term maintainability.

## Executive summary

What’s already strong:

- The type ramp is tokenized (`TypeScale`, `TypeWeights`, `TypeMetrics`, `Typefaces`) and produces a deterministic `TextTheme` via `TextThemeBuilder.buildTextThemeStatic(...)`.
- Theme construction is **context-free** (no `MediaQuery` reads) which is the right architectural constraint for a reusable core kit.
- Modern text scaling is handled in the correct place: **once at the app root** via `AdaptiveScope` (using `TextScaler.clamp(...)`, preserving Android 14+ nonlinear scaling).

What’s not yet enterprise-grade:

- The type ramp is currently **static** (no breakpoint-derived ramp). That’s an acceptable enterprise default, but it must be documented as such.
- `MediaQuery.boldText` is captured by `AdaptiveSpec`, but typography does not apply a bold-text policy yet (intentional; needs an explicit decision).
- `TextThemeBuilder` is an internal implementation detail; feature code should not bypass the theme by constructing styles directly.

If you do one thing next: pick a **single canonical API** and demote everything else to either “thin wrapper” or “advanced escape hatch”.

## Current architecture (as implemented)

### Tokens → Theme

- Tokens:
  - `lib/core/design_system/theme/typography/tokens/typefaces.dart` (font families)
  - `lib/core/design_system/theme/typography/tokens/type_scale.dart` (size ramp)
  - `lib/core/design_system/theme/typography/tokens/type_weights.dart` (weight ramp)
  - `lib/core/design_system/theme/typography/tokens/type_metrics.dart` (line height, letter spacing, paragraph width heuristics)
- Theme builder:
  - `lib/core/design_system/theme/typography/styles/text_theme_builder.dart` → builds a full `TextTheme` (currently static sizes; color derived from `ColorScheme.onSurface`)
- Theme wiring:
  - `lib/core/design_system/theme/typography/typography_system.dart` → applies `textTheme` + a few component styles (AppBar/BottomNav/TabBar)
  - `lib/core/design_system/theme/theme.dart` → `AppTheme.light()/dark()` calls `TypographySystem.applyTypography(...)`

### Tokens → Components

There are some compatibility helpers around typography, but the intent is a single source of truth:

- Canonical: `Theme.of(context).textTheme.*` (from `TextThemeBuilder`)
- Components:
  - `lib/core/design_system/theme/typography/components/text.dart` (`AppText.*`)
  - `lib/core/design_system/theme/typography/components/heading.dart` (`Heading.h1` … `Heading.h6`)
  - `lib/core/design_system/theme/typography/components/paragraph.dart` (`Paragraph`, with optional width constraining)

Compatibility helpers that bypassed theme access (e.g., `ResponsiveTextStyles`, `TypographyExtensions`, and large legacy wrappers) have been removed as part of the v2 rollout. Governance is now enforced via custom lints (see `packages/mobile_core_kit_lints`).

## What already aligns with enterprise best practice

### 1) Theme creation is context-free (good constraint)

Creating `ThemeData` without reading environment is the right call for:

- deterministic builds (no “theme depends on current screen width” surprises)
- easier testing
- predictable theming across nested trees

If you want adaptive typography later, it should be a separate “context-aware selection layer” (see recommendations), not `ThemeData` itself.

### 2) Text scaling is handled correctly (root-level `TextScaler` clamp)

Enterprise apps that care about accessibility and regression prevention typically:

- clamp text scaling once at the app root (layout stability + predictable QA)
- never apply “manual” font scaling in widgets (to avoid double scaling)
- preserve nonlinear scaling behavior where supported by the OS

This repo’s approach matches that.

### 3) Tokenized hierarchy is a solid base

The `TypeScale` values match a well-known ramp shape (close to Material 3’s baseline). This is a legitimate “enterprise default” because it’s familiar, well tested, and works with typical UI density constraints.

## Where the system is not yet enterprise-grade

### 1) “Responsive” is currently a misnomer (implementation vs docs)

The type ramp is static today (no breakpoint-derived ramp). This repo treats “responsive typography” as:

- root-level text scaling clamp (accessibility correctness)
- layout-level constraints (paragraph max width) for readability

Consequences:

- Developers should not expect breakpoint-driven typography changes.
- Docs must not claim behavior that isn’t implemented.

Enterprise standard here is: **either implement the behavior, or rename and document the truth**.

Status: fixed by removing misleading compatibility APIs and aligning docs with the current static ramp + adaptive layout approach.

### 2) Too many public entrypoints (governance risk)

Right now, teams can pick any of:

- `Theme.of(context).textTheme.*`
- `AppText.*` / `Heading.*` / `Paragraph.*`

This is how typography “drifts” in large orgs: different teams take different paths and assumptions.

Enterprise standard is to have a **single canonical API** and make other APIs either private, deprecated, or explicitly documented as “escape hatch”.

Status: largely fixed. Remaining risk is accidental direct usage of internal style builders (treat `TextThemeBuilder` as internal; prefer the theme and thin wrappers).

### 3) Wrapper widgets are too large (maintenance + policy escape)

Status: fixed. `AppText`, `Heading`, and `Paragraph` are now intentionally thin and do not expose font-size/scaling overrides.

### 4) Accessibility responsibilities are blurred

Contrast is primarily a **color system concern** (roles + contrast gates/tests), not a per-Text widget concern.

In enterprise systems, “automatic contrast fixes in widgets” often become a trap:

- it hides token/role regressions
- it produces inconsistent UI color decisions at runtime

Status: fixed by removing widget-level contrast helpers and enforcing contrast at the color role layer.

### 5) `TextStyleExtensions` are powerful but dangerous

Helpers like `.larger`, `.smaller`, `.tight`, `.wide`, `.compact`, `.relaxed` can be useful in prototypes, but at scale they cause:

- unreviewable typography drift (“why is this 1.2x here?”)
- inconsistent vertical rhythm and layout behavior

Status: fixed by removing these extensions from the public API surface.

## Recommendations (ordered, practical)

### Recommendation A — Declare one canonical API

Pick one of these and document it as “the contract”:

Option A1 (most common in Flutter orgs):
- Canonical styles: `Theme.of(context).textTheme.*`
- Canonical colors: `context.textPrimary` / `context.textSecondary` / role-based colors
- DS components (`AppText`, etc.) are thin convenience wrappers over the theme.

Option A2 (if you want a design-system-first API):
- Canonical components: `AppText` / `Heading` / `Paragraph` (but *with a small surface area*)
- Access to raw `TextTheme` is still allowed, but treated as “advanced”.

Right now you have a hybrid. Hybrids don’t scale.

Status: implemented. Canonical typography is `Theme.of(context).textTheme.*` with slim wrappers for the common path.

### Recommendation B — Rename or implement “responsive typography”

If the intent is “static ramp + root text scaling + layout adaptation”, then:

- Keep `ThemeData.textTheme` static.
- Clamp text scaling once at the app root (`AdaptiveScope`) and avoid per-widget scaling.
- Avoid “responsive” naming in public typography APIs (it implies breakpoint ramps).
- Solve tablet readability via layout constraints (e.g., paragraph max width), not a second ramp.

If the intent is real device-class-aware typography, then implement it in a way that preserves context-free theme:

- Keep `ThemeData.textTheme` static.
- Provide a context-aware selection layer that chooses between ramps based on `context.adaptiveLayout` (phone vs tablet).
  - Example: `context.typeRamp.displayLarge` selects from `TypeScalePhone` vs `TypeScaleTablet`.
- This selection layer can live in `core/adaptive` or `core/theme/typography` as an adapter.

Status: implemented for the current scope by removing misleading naming and documenting the static ramp. Multi-ramp typography remains an optional future feature.

### Recommendation C — Reduce DS widget surface area

Enterprise-friendly target: small constructors + a strict override policy.

For example, “golden path” parameters for `AppText` could be limited to:

- `text`
- `styleRole` (or constructor like `AppText.bodyMedium`)
- `color` (roles only; no hardcoded colors)
- `textAlign`, `maxLines`, `overflow`
- `selectable` (rare)

Avoid exposing:

- `textScaler` (bypasses root policy)
- arbitrary `fontSize`, `letterSpacing`, `height` unless you have a strict governance story

Keep an explicit escape hatch: “use Flutter `Text` directly with `Theme.of(context).textTheme.*`”.

Status: implemented. Wrappers are small and predictable; advanced cases should use `Text`/`SelectableText` directly.

### Recommendation D — Decide how to handle `MediaQuery.boldText`

`AdaptiveSpec` already captures `boldText`. Decide if you want to:

1) Ignore it (many apps do; simplest), or
2) Respect it in a controlled way (e.g., bump weights by one step for body/label only).

If you choose (2), do it via a controlled policy layer (not ad-hoc `.bolder` calls in feature code).

Status: not implemented (by design). Needs an explicit decision when you want to respect bold-text across the app.

### Recommendation E — Fix and consolidate docs

`lib/core/design_system/theme/typography/typography-guide.md` currently over-promises breakpoint behavior. Options:

- Move it to `docs/explainers/core/theme/` and align it with the actual implementation.
- Or delete it and keep one canonical typography doc under `docs/explainers/`.

In a starter kit, duplicated/contradictory docs are worse than missing docs.

Status: implemented. The guide and explainer docs now align with the static-ramp + root clamp strategy.

## Usage rules (so devs don’t get lost)

If you keep the current implementation for now, the least confusing ruleset is:

1) Prefer `AppText` / `Heading` / `Paragraph` for common UI.
2) If you need something `AppText` can’t do cleanly, use `Text` / `SelectableText` with `Theme.of(context).textTheme.*`.
3) Do not pass `textScaler` to DS widgets; scaling is controlled at `AdaptiveScope`.
4) Never hardcode font sizes in feature code (`TextStyle(fontSize: ...)`). If a new role is needed, add it to the ramp/tokens and document it.

## Suggested follow-up work (optional, but high leverage)

- Decide whether to support `MediaQuery.boldText` via a centralized policy (do not allow ad-hoc weight bumps).
- Treat internal style builders as internal API (keep feature code on `textTheme`/wrappers).
