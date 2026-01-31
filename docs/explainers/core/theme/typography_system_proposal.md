# Typography System Proposal (Enterprise-Grade, Phone/Tablet First)

This document proposes what the typography system *should* be for this mobile core kit (phone/tablet, iOS/Android first class). It is written as a forward-looking target architecture and governance model.

## Goals (what “good” means)

1) **Single contract**: one canonical way to pick text styles in product UI.
2) **Accessible by default**:
   - respects system text scaling (including Android 14+ nonlinear scaling)
   - supports bold text preference (where possible) without breaking layout
   - supports high contrast mode without per-widget hacks
3) **Governable**: easy to enforce “don’t invent typography in feature code”.
4) **Stable and predictable**: theme creation is deterministic and context-free; environment adaptation happens in a dedicated layer.
5) **Minimal surface area**: small, opinionated components that cover the 90% case; clear escape hatches for the rest.
6) **Brand-ready**: typography tokens can evolve (typeface swap, ramp tuning, letter spacing tuning) without mass refactors.

## Non-goals (explicitly out of scope)

- Desktop/web typography optimization.
- External packages for typography. (We can use Flutter SDK + our own code only.)
- Automatically “fixing” broken contrast inside text widgets. Contrast is a **color system** contract, enforced via tests.

## Design principles (enterprise-grade defaults)

### 1) ThemeData is context-free; adaptation is context-aware

- `ThemeData` and its `TextTheme` must be constructed without reading `MediaQuery` or breakpoints.
- Environment signals (text scaling, bold text, size classes) are applied via:
  - `AdaptiveScope` (root) + `MediaQuery` policy (text scaler clamp)
  - optional “type ramp selection” layer that is explicitly context-aware.

This prevents non-deterministic theming and makes tests reliable.

### 2) One style source of truth (no parallel pipelines)

We must avoid having multiple public ways to create styles. The system should have:

- **One canonical source**: `Theme.of(context).textTheme` (built from our tokens).
- Optional DS wrappers that forward to `textTheme` (do not reinvent styles).

### 3) No “arbitrary typography” in feature code

Feature code must not define new font sizes/weights/line heights ad hoc. If a new typographic role is needed, add it to the system.

## Proposed contract (what feature code uses)

### Canonical API: `TextTheme` roles

Use:

- `Theme.of(context).textTheme.*` for the type ramp (display/headline/title/body/label)
- `context.textPrimary`, `context.textSecondary`, etc. for colors (roles)

Reason: this is the most widely-adopted Flutter convention in large codebases, easiest to onboard, and easiest to lint for.

### Optional DS wrappers (small surface area)

Provide small, opinionated widgets that cover common cases:

- `AppText` — typed wrapper around `Text`/`SelectableText`, with role selection + safe overrides
- `Heading` — semantic header wrapper (a11y semantics + consistent roles)
- `Paragraph` — multi-line body text with readable line length constraints

Critical constraint: wrappers are convenience only; they must not drift from `TextTheme`.

## Tokens and construction pipeline

### Tokens (owned, versionable)

We keep tokens as pure data:

- `Typefaces` — font family stack
- `TypeScale` — the ramp sizes
- `TypeWeights` — the ramp weights
- `TypeMetrics` — line height + letter spacing + readable line length constants

Optional additions (if we want to mature this beyond “Material baseline”):

- `TypeScalePhone` + `TypeScaleTablet` (two ramps) OR a single ramp with a small number of tablet adjustments.
- `TrackingPolicy` (letter spacing policy for specific roles if designers demand it).
- `TypographyDensity` (compact/comfortable) only if we truly need it (avoid premature complexity).

### Build pipeline (strictly one-way)

1) Tokens → `TextTheme` (pure, context-free)
2) App theme builder installs `TextTheme` into `ThemeData` (context-free)
3) `AdaptiveScope` installs clamped `MediaQuery.textScaler` (context-aware at root)
4) Widgets render text using:
   - `Theme.of(context).textTheme.*`
   - Flutter applies `MediaQuery.textScaler` automatically

### Text scaling (modern, correct)

- Clamp scaling at the root using `TextScaler.clamp(...)` (preserves nonlinear scaling).
- Do not manually multiply font sizes in widgets.
- Do not pass `textScaler:` per text call (except in extremely special cases; should be linted).

## Responsive vs adaptive typography (phone/tablet)

### What we should do (recommended)

Keep **one ramp** as the default. Use layout policies to solve tablet readability:

- On tablet, the *problem* is usually not “font sizes too small”, but “line length too long”.
- Solve with containers/paragraph constraints (`Paragraph.constrainWidth`) and adaptive layout decisions (split view, gutters), not by inflating font sizes.

### When to introduce two ramps

Introduce separate phone/tablet ramps only if:

- the design system explicitly defines separate ramps, and
- we have multiple surfaces where font size differences are required (not just one-off screens).

If we ever do it, implement it as an explicit context-aware selection layer that does **not** mutate `ThemeData`:

- `context.typeRamp.displayLarge` returns a style role mapped to phone/tablet tokens.
- Internally reads `context.adaptiveLayout.widthClass` to choose the token values.

This keeps theme construction deterministic.

## Accessibility policy (beyond text scaling)

### Bold text preference (`MediaQuery.boldText`)

We should decide one of two enterprise-valid approaches:

Option 1 (simplest): ignore bold-text preference for now.
- Pro: fewer regressions, fewer layout shifts.
- Con: some users expect it.

Option 2 (controlled support): apply a “weight bump” policy for specific roles.
- Example: for body/label roles only, bump weight one step (regular→medium, medium→semibold).
- Never bump display sizes (already heavy).

Implementation must be centralized and deterministic (no random `.bolder` in feature code).

### High contrast (`MediaQuery.highContrast`)

Typography should not “fix contrast” itself. Instead:

- high contrast mode should switch theme variants (color roles get stronger separators; text roles are already `on*` roles).
- typography wrappers should avoid hardcoding colors; use roles so high contrast works.

## Component design (strict, minimal)

### `AppText` (proposed surface area)

Provide:

- role constructor (or enum role) that maps to `TextTheme`
- safe overrides:
  - `color` (role colors only)
  - `textAlign`, `maxLines`, `overflow`, `softWrap`
  - `selectable` (optional)
  - `semanticsLabel` (optional)

Do **not** expose by default:

- `fontSize`, `height`, `letterSpacing`, `textScaler`

Those become escape hatches: use `Text` directly with `textTheme`.

### `Heading`

Provide semantics + a limited set of heading roles:

- `Heading.h1/h2/h3` are enough for most apps.
- If we keep h4-h6, ensure the mapping is explicit and documented.

Rules:

- Headings are semantically `header: true`
- Headings should not accept arbitrary font overrides

### `Paragraph`

This is the primary place for “tablet readability”:

- Constrain readable line length for long-form copy.
- Support spacing (e.g., bottom margin) in a controlled way.
- Avoid exotic APIs; prefer composition.

## Governance (how to keep it clean)

### Lints (IDE + CI)

Add custom lint rules (similar to the color system guardrails):

1) `hardcoded_font_sizes`
   - Disallow `TextStyle(fontSize: ...)` in UI layers (feature + shared widgets).
2) `manual_text_scaling`
   - Disallow `TextScaler.linear(...)` usage in widgets (except `AdaptiveScope` / policy code).
3) `typography_style_mutation`
   - Disallow `.copyWith(fontSize: ...)` in feature code (allow limited copyWith for color/weight if needed).

### Contract tests

- Token contract tests for type ramp values (guards accidental edits).
- Theme contract tests ensuring `TypographySystem.applyTypography(...)` binds key components to expected roles (AppBar, TabBar, etc.).

### Documentation

- One usage guide and one “under the hood” doc for typography (mirroring the color docs structure).
- Showcase screen (dev-only) to visualize all roles + scaling behavior.

## Proposed folder structure (target)

This is a recommended organization; actual file names can differ.

```
lib/core/design_system/theme/typography/
  tokens/
    typefaces.dart
    type_scale.dart
    type_weights.dart
    type_metrics.dart
  styles/
    text_theme_builder.dart
    typography_policy.dart           # optional: bold-text policy, future ramp selection
  components/
    app_text.dart                    # slim wrapper
    heading.dart                     # slim wrapper
    paragraph.dart                   # slim wrapper + readable line constraints
  showcase/
    typography_showcase_screen.dart  # dev-only screen
  typography_system.dart             # theme wiring (context-free)
```

## Rules (developer-facing, non-negotiable)

1) Use `Theme.of(context).textTheme.*` (or `AppText` wrappers) — do not invent font sizes.
2) Never manually scale fonts. Text scaling is owned by `AdaptiveScope` + `MediaQuery.textScaler`.
3) Do not pass `textScaler:` to text widgets in feature code.
4) For tablet readability, constrain line length and layout first; do not inflate the ramp by default.
5) If you need a new text role, add it to tokens/builders and document it.

