# Color System Rewrite Plan (Start Here)

This document turns `docs/explainers/core/theme/color_system_review.md` into an actionable rewrite plan.

## Goal (hard reset)

Rebuild the theme color system so it is:

- **Role-first**: `ColorScheme` (Material roles) is the canonical UI API.
- **Accessible by construction**: enforce WCAG contrast for `on*` roles and semantic status roles.
- **Deterministic and scalable**: no “mystery defaults”, no drift between components, predictable light/dark behavior.
- **No external dependencies**: use Flutter/Dart only (no third-party color packages).

Non-goals:
- Backward compatibility for token names/usages.
- Supporting desktop/web (phone/tablet is first-class).
- Material Dynamic Color (requires external plumbing; revisit later if needed).

## Inputs we need (before writing code)

1) **Brand seeds**
   - `brandPrimarySeed` (required)
   - optionally `brandSecondarySeed`, `brandTertiarySeed` (only if you truly need explicit brand hues there)

2) **Semantic seeds**
   - `successSeed`, `warningSeed`, `infoSeed` (required if you want semantic colors as first-class)

3) **Accessibility policy**
   - Minimum contrast for normal text: **4.5:1** (WCAG AA)
   - Minimum contrast for large text/icons: **3.0:1** (WCAG AA large)
   - Decide whether we gate *all* roles at 4.5:1, or allow some container/disabled roles at 3.0:1.

If you don’t provide seeds yet: we can still build the architecture using placeholder seeds, but it’s wasted churn because the palette will change again.

## Decision: pick the generation strategy

### Option A (recommended): `ColorScheme.fromSeed` (Material 3)

Use Flutter’s built-in Material 3 color system to generate complete light/dark schemes:

- `ColorScheme.fromSeed(seedColor: brandPrimarySeed, brightness: Brightness.light)`
- `ColorScheme.fromSeed(seedColor: brandPrimarySeed, brightness: Brightness.dark)`

Then derive semantic role sets (`success/*`, `info/*`, `warning/*`) from their own seeds using the same mechanism.

Why this is the best “enterprise default”:
- Produces a **complete** scheme (reduces drift).
- Has sane defaults for surfaces/containers/outline roles.
- Keeps us on the same “semantic contract” as Flutter Material components.

### Option B (only if you have strict brand constraints): in-house tonal palettes + mapping

Implement our own tonal palette model (tone 0–100) + mapping tables for all `ColorScheme` roles.

Reality check (without external deps):
- Doing this *correctly* requires owning perceptual color math (HCT/OKLCH-like) and validation tooling.
- This is **weeks of work** and easy to get wrong.

Recommendation: start with Option A; move to Option B only if design explicitly rejects M3 output.

## Where to start (practical sequence)

### Phase 0 — Guardrails (do this first)

1) **Declare the contract**
   - “Feature UI must consume semantic roles (`ColorScheme` + `SemanticColors`).”
   - “Raw palettes are non-UI primitives (charts/illustrations only).”

2) **Add a contrast gate**
   - A test or tool that fails if any required role pair falls below thresholds.
   - This is what prevents regressions and “silent” accessibility failures.

### Phase 1 — Build the new color system (isolated, minimal blast radius)

Create a small set of new files that can be used by `light_theme.dart` / `dark_theme.dart` without touching feature UI yet.

Proposed folder tree (new files only):

```text
lib/core/theme/
  system/
    app_color_seeds.dart            # single source of truth for seed colors
    app_color_scheme_builder.dart   # builds ColorScheme + SemanticColors (light/dark)
    color_contrast.dart             # WCAG contrast utilities (shared by tests/tools)
```

Notes:
- Keep this independent of the rest of theme tokens so we can swap implementations later.
- The output of the builder is *role objects*, not palettes.

### Phase 2 — Wire theme to the builder

Update:
- `lib/core/theme/light_theme.dart`
- `lib/core/theme/dark_theme.dart`

So both themes are built from:
- `AppColorSchemeBuilder.build(brightness: ...)`

Rules:
- **Do not** leave `ColorScheme` fields implicit; use the generated full scheme (Option A) or set every role explicitly (Option B).
- Keep `SemanticColors` derived from the same seed philosophy (do not hand-pick “pretty” pairs that fail contrast).

### Phase 3 — Validate

Add a test that instantiates both themes and checks:
- all required `ColorScheme` role pairs meet thresholds
- all `SemanticColors` role pairs meet thresholds

Suggested location:

```text
test/core/theme/color_contrast_test.dart
```

### Phase 4 — Migrate feature code (later sprint)

Once the new system is stable and validated:
- migrate feature-level usage off raw tokens/palettes to semantic roles
- delete legacy palette ThemeExtensions when no longer referenced

## “Must-fix now” vs “safe to wait”

If the app is shipping/used today, fix these immediately even before the full rewrite:

- **Dark neutrals inversion** in `lib/core/theme/dark_theme.dart` (surface is currently white).
- **Surface container ramp** in light theme (`surfaceContainerHighest` is far too dark).

If this repo is still internal-only, we can roll those fixes into the rewrite PR instead.

## Implementation rules (non-negotiable)

- `ColorScheme` is the **only** allowed source for component colors (buttons, inputs, cards, scaffold, text).
- `SemanticColors` is the only allowed source for status UI (success/info/warning/error-like surfaces), not raw greens/yellows.
- Any “brand palette token” that is directly consumed by UI must be treated as a bug.
- No role mapping is accepted without the contrast gate passing.

## Example snippet (Option A approach)

Conceptual example (final names may differ):

```dart
final scheme = ColorScheme.fromSeed(
  seedColor: AppColorSeeds.brandPrimarySeed,
  brightness: brightness,
);

final successScheme = ColorScheme.fromSeed(
  seedColor: AppColorSeeds.successSeed,
  brightness: brightness,
);

final semantic = SemanticColors.fromSchemes(
  success: successScheme,
  info: ColorScheme.fromSeed(seedColor: AppColorSeeds.infoSeed, brightness: brightness),
  warning: ColorScheme.fromSeed(seedColor: AppColorSeeds.warningSeed, brightness: brightness),
);
```

## Definition of Done (for the rewrite PR)

- `lightTheme` + `darkTheme` use the new builder.
- Contrast gate passes for the agreed role pairs.
- No `ColorScheme` roles are left to defaults unintentionally.
- Docs updated:
  - `docs/explainers/core/theme/color_system_review.md` points to the new architecture.

