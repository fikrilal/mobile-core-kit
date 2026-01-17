# Dark Mode + High Contrast — Usage Guide

This template ships with **light**, **dark**, and **high-contrast** theme variants derived from a small set of color seeds (brand + neutral + status).

The theme system is designed to keep iOS and Android as **equal first-class targets** (no platform split). “Dark mode quality” comes from **role usage discipline** (surfaces, borders, semantics), not from platform-specific palettes.

## What you should do in UI code

### 1) Use surfaces intentionally (layering rules)

Dark mode fails when everything is painted with a single background color. Use a small, consistent “layer model”:

- App background: `colorScheme.surface`
  - Default for `Scaffold`/page background.
- Default containers: `colorScheme.surfaceContainerLow`
  - Cards, sections, group boxes, container backgrounds.
- Elevated overlays: `colorScheme.surfaceContainerHigh`
  - Dialogs, bottom sheets, side sheets, menus/popovers.

In this repo, those defaults are wired at the theme level:
- `CardThemeData.color` → `surfaceContainerLow`
- `DialogThemeData.backgroundColor` → `surfaceContainerHigh`
- `BottomSheetThemeData.(modal)BackgroundColor` → `surfaceContainerHigh`

If you need to override backgrounds, override them with **these same roles**. Avoid hand-rolled opacity overlays.

### 2) Borders and separators: `outline` vs `outlineVariant`

This is the most common source of dark-mode regressions.

- **Interactive boundaries** (input borders, focus rings, enabled controls): use `colorScheme.outline`
- **Decorative separators** (list dividers, subtle section separators): use `colorScheme.outlineVariant`

Why: decorative lines must not compete with controls, and controls must remain perceivable in dark mode.

### 3) Text colors: prefer `onSurface` and keep it boring

For standard content:

- Title/body text on any surface/container: `colorScheme.onSurface`
- Secondary/supporting text: `colorScheme.onSurfaceVariant`

Avoid mixing brand colors into body text in dark mode unless it’s a deliberate affordance (link/CTA).

### 4) Status colors: use `SemanticColors`, not ad-hoc ramps

Use `context.semanticColors` for success/info/warning roles and their container variants.

Do not use palette ramps like `green200`/`red700`. We intentionally do not expose them in code.

### 5) Avoid deprecated `ColorScheme.background` / `onBackground`

Flutter/Material has deprecated these roles. In this template, treat them as “legacy”.

Use:

- background → `surface`
- onBackground → `onSurface`

## High contrast: how it’s expected to behave

High-contrast is supported without “repainting the app”:

- It strengthens boundaries (e.g., `outlineVariant` becomes `outline` via the builder policy).
- It should not introduce new hues or tinted surfaces.

Rule: keep high-contrast policies **minimal**, then add targeted adjustments only when QA finds real accessibility issues (inputs, dividers, navigation).

## QA / debugging (dev-only)

Use the role showcase screen to verify pairings quickly:

- `lib/core/dev_tools/theme/theme_roles_showcase_screen.dart`

Automated gates:

- Surface + component contract: `test/core/theme/theme_surface_hierarchy_test.dart`
- Role contrast policy (AA text + non-text controls): `test/core/theme/color_contrast_test.dart`

What to look for:

- Cards/containers read as “raised” relative to the page background.
- Dialogs/bottom sheets read as “above” cards/containers.
- Input borders are visible but not louder than content.
- Decorative dividers are present but subtle.
- Status containers remain readable in both light/dark.

## Quick examples

### Card-like container (preferred)

```dart
final cs = Theme.of(context).colorScheme;

DecoratedBox(
  decoration: BoxDecoration(
    color: cs.surfaceContainerLow,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: cs.outlineVariant),
  ),
  child: ...
)
```

### Input boundary (interactive)

```dart
final cs = Theme.of(context).colorScheme;

OutlineInputBorder(
  borderSide: BorderSide(color: cs.outline),
)
```
