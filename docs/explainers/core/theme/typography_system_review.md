# Typography System Review (Current State + Recommendations)

This is a deep review of the current typography system under `lib/core/theme/typography/`, with an “enterprise standard” lens: clarity of contract, accessibility correctness, governance/guardrails, and long-term maintainability.

## Executive summary

What’s already strong:

- The type ramp is tokenized (`TypeScale`, `TypeWeights`, `TypeMetrics`, `Typefaces`) and produces a deterministic `TextTheme` via `TextThemeBuilder.buildTextThemeStatic(...)`.
- Theme construction is **context-free** (no `MediaQuery` reads) which is the right architectural constraint for a reusable core kit.
- Modern text scaling is handled in the correct place: **once at the app root** via `AdaptiveScope` (using `TextScaler.clamp(...)`, preserving Android 14+ nonlinear scaling).

What’s not yet enterprise-grade:

- “Responsive” naming suggests breakpoint-driven typography, but the ramp is currently **static** (no breakpoint logic). That’s fine for now, but the naming should not over-promise.
- Legacy entrypoints still exist, but the system should continue converging on **one canonical API** (`Theme.of(context).textTheme.*`) with everything else as thin wrappers or deprecated compatibility.
- The “design system widgets” (`AppText`, `Heading`, `Paragraph`) have an extremely large API surface (nearly mirroring `Text`/`SelectableText`), which is high-maintenance and weakens governance.

If you do one thing next: pick a **single canonical API** and demote everything else to either “thin wrapper” or “advanced escape hatch”.

## Current architecture (as implemented)

### Tokens → Theme

- Tokens:
  - `lib/core/theme/typography/tokens/typefaces.dart` (font families)
  - `lib/core/theme/typography/tokens/type_scale.dart` (size ramp)
  - `lib/core/theme/typography/tokens/type_weights.dart` (weight ramp)
  - `lib/core/theme/typography/tokens/type_metrics.dart` (line height, letter spacing, paragraph width heuristics)
- Theme builder:
  - `lib/core/theme/typography/styles/text_theme_builder.dart` → builds a full `TextTheme` (currently static sizes; color derived from `ColorScheme.onSurface`)
- Theme wiring:
  - `lib/core/theme/typography/typography_system.dart` → applies `textTheme` + a few component styles (AppBar/BottomNav/TabBar)
  - `lib/core/theme/theme.dart` → `AppTheme.light()/dark()` calls `TypographySystem.applyTypography(...)`

### Tokens → Components

There are some compatibility helpers around typography, but the intent is a single source of truth:

- Canonical: `Theme.of(context).textTheme.*` (from `TextThemeBuilder`)
- Compatibility:
  - `lib/core/theme/typography/styles/responsive_text_styles.dart` → deprecated proxy to `Theme.of(context).textTheme.*`
  - `lib/core/theme/typography/utils/typography_extensions.dart` → deprecated convenience getters that proxy to `textTheme`
- `lib/core/theme/typography/styles/accessible_text_style.dart` → currently a pass-through (correct, because scaling is handled at root)
- Components:
  - `lib/core/theme/typography/components/text.dart` (`AppText.*`)
  - `lib/core/theme/typography/components/heading.dart` (`Heading.h1` … `Heading.h6`)
  - `lib/core/theme/typography/components/paragraph.dart` (`Paragraph`, with optional width constraining)

The remaining work is not “style drift” (the styles already flow through `textTheme`), but governance + maintainability: reduce wrapper surface area and keep one obvious path for developers.

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

The type ramp is static today (no breakpoint-derived ramp). The deprecated `ResponsiveTextStyles` name is a leftover from the earlier direction.

Consequences:

- Developers read “responsive” and assume typography changes with device class; it does not.
- Docs must not claim breakpoint behavior that isn’t implemented.

Enterprise standard here is: **either implement the behavior, or rename and document the truth**.

### 2) Too many public entrypoints (governance risk)

Right now, teams can pick any of:

- `Theme.of(context).textTheme.*`
- `TextThemeBuilder` (bypasses theme)
- `ResponsiveTextStyles` (bypasses theme)
- `context.bodyMedium` etc (bypasses theme)
- `AppText.*` / `Heading.*` / `Paragraph.*`

This is how typography “drifts” in large orgs: different teams take different paths and assumptions.

Enterprise standard is to have a **single canonical API** and make other APIs either private, deprecated, or explicitly documented as “escape hatch”.

### 3) Wrapper widgets are too large (maintenance + policy escape)

`AppText`, `Heading`, and `Paragraph` expose a very large parameter surface (almost a 1:1 mirror of `Text` / `SelectableText`).

Risks:

- High maintenance (Flutter’s text APIs evolve; wrappers must track them).
- Inconsistent forwarding (easy to forget a parameter; behavior subtly differs from `Text`).
- Governance failure: allowing per-call overrides like `letterSpacing`, `lineHeight`, and `textScaler` makes it easy to bypass the design system and accessibility policy.

Enterprise standard tends to do the opposite:

- provide **small** DS components that cover the common 90% cases
- allow direct `Text`/`SelectableText` for advanced cases
- limit the DS surface area so it can be reviewed and policed

### 4) Accessibility responsibilities are blurred

- `AccessibleTextStyles.ensureContrast(...)` exists but is not used by the canonical component path.
- Contrast is primarily a **color system concern** (roles + contrast gates/tests), not a per-Text widget concern.

In enterprise systems, “automatic contrast fixes in widgets” often become a trap:

- it hides token/role regressions
- it produces inconsistent UI color decisions at runtime

### 5) `TextStyleExtensions` are powerful but dangerous

Helpers like `.larger`, `.smaller`, `.tight`, `.wide`, `.compact`, `.relaxed` can be useful in prototypes, but at scale they cause:

- unreviewable typography drift (“why is this 1.2x here?”)
- inconsistent vertical rhythm and layout behavior

If you keep them, they need explicit rules for when they are allowed.

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

### Recommendation B — Rename or implement “responsive typography”

If the intent is “static ramp + root text scaling + layout adaptation”, then:

- Rename `ResponsiveTextStyles` → `AppTextStyles` (or similar)
- Update docs to remove breakpoint claims

If the intent is real device-class-aware typography, then implement it in a way that preserves context-free theme:

- Keep `ThemeData.textTheme` static.
- Provide a context-aware selection layer that chooses between ramps based on `context.adaptiveLayout` (phone vs tablet).
  - Example: `context.typeRamp.displayLarge` selects from `TypeScalePhone` vs `TypeScaleTablet`.
  - This selection layer can live in `core/adaptive` or `core/theme/typography` as an adapter.

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

### Recommendation D — Decide how to handle `MediaQuery.boldText`

`AdaptiveSpec` already captures `boldText`. Decide if you want to:

1) Ignore it (many apps do; simplest), or
2) Respect it in a controlled way (e.g., bump weights by one step for body/label only).

If you choose (2), do it via a controlled policy layer (not ad-hoc `.bolder` calls in feature code).

### Recommendation E — Fix and consolidate docs

`lib/core/theme/typography/typography-guide.md` currently over-promises breakpoint behavior. Options:

- Move it to `docs/explainers/core/theme/` and align it with the actual implementation.
- Or delete it and keep one canonical typography doc under `docs/explainers/`.

In a starter kit, duplicated/contradictory docs are worse than missing docs.

## Usage rules (so devs don’t get lost)

If you keep the current implementation for now, the least confusing ruleset is:

1) Prefer `AppText` / `Heading` / `Paragraph` for common UI.
2) If you need something `AppText` can’t do cleanly, use `Text` / `SelectableText` with `Theme.of(context).textTheme.*`.
3) Do not pass `textScaler` to DS widgets; scaling is controlled at `AdaptiveScope`.
4) Avoid `TextStyleExtensions` that change size/spacing (`.larger`, `.smaller`, `.tight`, `.wide`, `.compact`, `.relaxed`) unless you have an explicit UI spec to justify them.
5) Never hardcode font sizes in feature code (`TextStyle(fontSize: ...)`). If a new role is needed, add it to the ramp/tokens and document it.

## Suggested follow-up work (optional, but high leverage)

- Add a typography “contract test”:
  - verifies the ramp values are what you expect (guard against accidental edits)
  - verifies key theme bindings (AppBar/TabBar) use intended styles
- Add a dev-only typography roles showcase route (already exists: `TypographyShowcaseScreen`) and document how to reach it.
- Add a custom lint rule to discourage:
  - `TextStyle(fontSize: ...)` in UI layers
  - `TextScaler.linear(...)` usage in widgets
  - large-scale use of `TextStyleExtensions.larger/smaller`
