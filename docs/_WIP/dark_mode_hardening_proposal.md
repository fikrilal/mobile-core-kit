# Dark Mode Hardening Proposal (Enterprise-Grade, Low Risk)

This proposal strengthens dark mode consistency and stability without changing the current architecture (seed → role colors) and without introducing platform splits (iOS/Android remain first-class together).

## Goals

- Keep the current seed → `ColorScheme` + `SemanticColors` model.
- Make dark mode feel “intentional”: clear surface hierarchy, readable borders, predictable overlays.
- Reduce theme drift across Flutter/Material updates by explicitly theming a small set of high-impact widgets.
- Keep the changes additive and reversible.

## Non-goals

- No custom palette ramps (`grey100`, `red200`, etc.).
- No dependency on external packages.
- No full component sweep for every widget in the SDK (do the highest impact first).
- No per-platform theme divergence.

## Current state (what’s already good)

- Dark theme is deterministic: `AppThemeBuilder.build(brightness: Brightness.dark)` (`lib/core/theme/dark_theme.dart`).
- Core contrast is gated by tests for both light/dark and high-contrast (`test/core/theme/color_contrast_test.dart`).
- “Neutral elevation” policy prevents brand-tinted surfaces by sourcing surfaces + `surfaceTint` from a neutral seed (`lib/core/theme/system/app_color_scheme_builder.dart`).

These are strong foundations; the hardening work is mostly about “surface layering defaults” + “component theming completeness”.

## Production readiness blocker (must fix to actually ship dark mode)

The theme system supports dark mode, but the **app shell must actually allow it**.

- Ensure the app does not hard-lock `themeMode: ThemeMode.light`.
- Recommended default for a starter kit: `ThemeMode.system` (or user setting if you have one).

Without this, dark mode correctness isn’t exercised in real usage/QA, which is the most common way dark theme bugs ship.

## Proposal

### 1) Make surface hierarchy explicit (the biggest dark-mode UX lever)

Define a small, consistent mapping for where UI content lives (applies in light + dark, but dark mode benefits most).

Recommended mapping (conservative):

- App background: `colorScheme.surface`
- Default containers (sections/cards): `colorScheme.surfaceContainerLow` (or `surfaceContainer` if you want more contrast)
- Elevated overlays (dialogs/bottom sheets/menus): `colorScheme.surfaceContainerHigh` or `surfaceContainerHighest`

Optional safety (low risk):

- If you find legacy code reading deprecated `ColorScheme.background` roles, migrate it to
  `surface` / `onSurface` instead of trying to “fix it in the theme”.

Border rules (explicit, strict):

- Interactive control boundaries: `colorScheme.outline`
- Decorative separators: `colorScheme.outlineVariant` (or `context.hairline` if you provide a derived role)

Why:

- Dark mode becomes “layer readable” even without heavy shadows.
- Prevents the most common failure mode: everything uses `surface`, so cards/dialogs look flat.

### 2) Explicitly theme the “top 10” components to reduce drift

Today, `AppThemeBuilder` themes a subset (buttons/inputs/chips/cards). That’s good, but the highest-impact overlays and navigation primitives can still vary by Flutter version.

Implement explicit themes for:

1. `AppBarTheme` (background/foreground, scrolled-under behavior)
2. `DialogTheme` (background = container-high, title/body colors)
3. `BottomSheetThemeData` (modal/persistent backgrounds)
4. `DividerThemeData` (hairline vs outline)
5. `SnackBarThemeData` (background + content contrast)
6. `NavigationBarThemeData` / `NavigationRailThemeData` (if used)
7. `ListTileThemeData` (text/icon defaults)
8. `IconThemeData` (avoid surprise inherited colors)
9. `CheckboxThemeData` / `RadioThemeData` / `SwitchThemeData` (states + disabled clarity)
10. `CardThemeData` (prefer container surface for “raised” cards)

Policy:

- Keep it minimal: set only the role-consistent properties that matter.
- Don’t over-style; avoid bespoke sizing/animations here.

### 3) High-contrast policy: keep it minimal but documented

Current high-contrast handling:

- `outlineVariant` is strengthened to `outline` (`AppColorSchemeBuilder`, `highContrast: true`).

Proposal:

- Keep this as the default minimal policy.
- Only add 1–2 additional HC tweaks if QA reveals real accessibility issues:
  - inputs in HC use `outline` for enabled borders
  - dividers in HC use `outline`

### 4) Expand automated gates with a small “component contract” test set

You already gate color role contrast. Add a small set of contract tests that assert the intended background/foreground pairing for key components under both light + dark.

Examples to gate (AA normal text 4.5:1 where applicable):

- dialog background vs `onSurface`
- bottom sheet background vs `onSurface`
- card background vs `onSurface`
- snackbar background vs snackbar foreground role

These tests catch regressions when:

- seed inputs change
- Flutter changes default component theming
- we adjust surface mapping

### 5) Developer usage rules (prevent accidental dark-mode regressions)

Add/extend a short “rules of the road” section:

- Never hardcode colors; always use role colors (`ColorScheme` + `SemanticColors`).
- Use `outline` for interactive control boundaries (inputs, enabled toggles).
- Use `outlineVariant` only for decorative separators.
- Use container surfaces for raised UI; don’t fake elevation with arbitrary opacity overlays.

## Implementation plan (phased)

### P0 (single PR, low risk)

- Enable dark mode at the app shell:
  - default to `ThemeMode.system` (or a user preference, if present)
- Implement surface hierarchy defaults:
  - `CardThemeData.color` = `surfaceContainerLow`
  - `DialogTheme` background = `surfaceContainerHigh` (or Highest)
  - `BottomSheetThemeData` background = `surfaceContainerHigh` (or Highest)
  - `DividerThemeData.color` = hairline role (`outlineVariant` with alpha) or `outlineVariant`
- Add contract tests for the component backgrounds vs foreground roles.
- Update docs to reflect the new defaults and rules.

### P1 (follow-up)

- Add remaining explicit themes (navigation, snackbars, switches/checkboxes/radios, list tiles, icons).

### P2 (QA + polish)

- Use the dev-only `ThemeRolesShowcaseScreen` to validate role pairings in dark mode.
- Validate representative screens in dark mode (settings/auth/home) for layering + borders.

## Decisions needed from product/design (minimal)

Confirm the intended surface mapping levels:

1. Cards use `surfaceContainerLow` vs `surfaceContainer`
2. Dialogs use `surfaceContainerHigh` vs `surfaceContainerHighest`
3. Bottom sheets use `surfaceContainerHigh` vs `surfaceContainerHighest`

If uncertain, default to:

- cards: `surfaceContainerLow`
- dialogs/bottom sheets: `surfaceContainerHigh`

These defaults usually look good in dark mode without being overly “contrasty”.
