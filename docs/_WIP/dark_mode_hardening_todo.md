# Dark Mode Hardening — Implementation TODO

This checklist implements `docs/_WIP/dark_mode_hardening_proposal.md` in a low-risk, non-overengineered way.

## Definition of done

- Dark mode is reachable in real usage (not hard-locked to light).
- Dark mode has an explicit surface hierarchy for cards + overlays.
- Core roles remain contrast-gated (existing tests stay green).
- New component defaults are guarded by a small “theme contract” test set.
- Minimal docs exist so developers don’t misuse roles (outline vs outlineVariant).

## Status

- P0: done
- P1: done
- P2: pending

## P0 — Ship dark mode safely (must-do)

### 0.1 Enable dark mode at the app shell

- Update `MaterialApp.router` to stop hard-locking:
  - Replace `themeMode: ThemeMode.light` with `ThemeMode.system` (starter-kit default).
- Confirm high-contrast theme selection still works when the system switches brightness.

Why: if dark mode is never enabled, it cannot be QA’d and will regress silently.

### 0.2 Define surface hierarchy defaults in `AppThemeBuilder`

Implement consistent layering defaults (applies to light + dark, but driven by dark-mode needs):

- Cards:
  - Set `CardThemeData.color` to `colorScheme.surfaceContainerLow` (preferred) or `surfaceContainer`.
- Dialogs:
  - Add `DialogTheme` with background `surfaceContainerHigh` (or `surfaceContainerHighest`).
  - Ensure title/body styles use `textTheme` roles (do not hardcode).
- Bottom sheets:
  - Add `BottomSheetThemeData`:
    - modal background `surfaceContainerHigh` (or Highest)
    - set `showDragHandle` policy if you want consistency (optional).
- Dividers:
  - Add `DividerThemeData` and pick one:
    - decorative separators use `outlineVariant`
    - hairline separators use `outlineVariant` with a low alpha (only if you standardize it)

### 0.3 Optional safety: neutralize background roles

If you find legacy code reading deprecated `ColorScheme.background` roles:

- Migrate it to `surface` / `onSurface` instead of trying to “fix it in the theme”.

### 0.4 Add “theme contract” tests (small, high value)

Create a new test file under `test/core/theme/` that asserts the intended role pairings for:

- Card background vs `onSurface`
- Dialog background vs `onSurface`
- Bottom sheet background vs `onSurface`
- Divider color vs surface (non-text, 3.0:1)

Run the same assertions for:

- `lightTheme`
- `darkTheme`
- `lightHighContrastTheme`
- `darkHighContrastTheme`

Use the existing contrast helper (`wcagContrastRatio`) so the policy stays centralized.

## P1 — Reduce drift for common components (nice-to-have)

Add explicit theming for the highest “drift risk” components (only set a few properties each):

- `SnackBarThemeData`
- `AppBarTheme` (background/foreground/scrolled-under)
- `ListTileThemeData`
- `IconThemeData`
- `CheckboxThemeData` / `RadioThemeData` / `SwitchThemeData`
- `NavigationBarThemeData` / `NavigationRailThemeData` (only if used in-app)

Principle: set the role-consistent defaults and stop there. Avoid bespoke shapes/animations unless required.

## P2 — Docs and developer rules (small, strict)

Document “rules of the road” in one place:

- Which surface role to use for which layer (surface vs container vs overlay).
- Borders:
  - `outline` = interactive boundary
  - `outlineVariant` = decorative separator
- Never hardcode colors; always use `ColorScheme` + `SemanticColors`.

Link this doc from `lib/core/theme/theme-system-doc.md` (or the explainer README).

## Verification checklist (manual QA)

- Toggle device dark mode:
  - surfaces still feel neutral (no green tint)
  - borders are perceivable (inputs, cards, dividers)
  - dialogs/bottom sheets read as “raised layers”
- Toggle high-contrast:
  - separators/borders become stronger without recoloring the entire UI
- Spot-check status colors (success/info/warning) in dark mode:
  - container roles remain readable
