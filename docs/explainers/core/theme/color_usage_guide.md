# Color Usage Guide (Roles, Rules, and Examples)

This document is the day-to-day guide for using colors in UI code.

## Canonical API (what to use)

Use semantic roles:

- `context.cs.*` (`ColorScheme`) — primary source for UI colors.
- `context.semanticColors.*` (`SemanticColors`) — success/info/warning roles.
- `context.textPrimary`, `context.textSecondary`, `context.border`, `context.hairline`, etc. — convenience aliases in `ThemeRoleColors`.

In this repo, the roles are generated from seeds in:
- `lib/core/theme/system/app_color_seeds.dart:1`

Design/engineering handoff for seeds:
- `docs/explainers/core/theme/color_seed_intake.md`

## Prohibited (what not to use)

- Do not use palette-step colors (e.g. `neutral/200`, `green/500`) in app UI.
  - If design hands off palette ramps, translate the intent to roles (see rules below).
- Do not hardcode brand/status hex values in widgets (`Color(0xFF...)`, `Colors.*`) unless you are building a debug-only tool.

## Rules (enterprise defaults)

### 1) Roles are the contract

Feature code should treat `ColorScheme` + `SemanticColors` as the public API.

If a design asks for a palette step (e.g. “neutral/200”), translate it to a role:
- “divider/hairline” → `context.hairline`
- “control border” → `context.border`
- “surface background” → `context.bgSurface` / `context.bgContainer*`

### 2) Borders: `outline` vs `outlineVariant`

This is a common source of accessibility regressions. Use the right one:

- `context.border` (`ColorScheme.outline`) is a **control boundary**.
  - Examples: TextField border, Chip border, focus ring base, checkbox outline.
  - Must meet **WCAG 1.4.11 non-text contrast** (≥ **3.0:1**) against the surface.

- `context.borderSubtle` (`ColorScheme.outlineVariant`) is **decorative**.
  - Examples: subtle separators inside already-bounded containers.
  - It is *not* guaranteed to hit 3.0:1; do not use it as the only indicator of state.

- `context.hairline` is for **very subtle** dividers (purely decorative).

### 2.1) Shadows and scrims

- Shadows: prefer `context.cs.shadow` (optionally with alpha) over hardcoded blacks.
- Scrims / modal barriers: prefer `context.cs.scrim` (optionally with alpha) over hardcoded overlays.

### 3) Contrast policy (enforced)

Automated tests enforce:

- Text-bearing pairs: **≥ 4.5:1** (WCAG AA normal text)
  - e.g. `onPrimary/primary`, `onSurface/surface`, container pairs, status pairs.
- Non-text UI controls: **≥ 3.0:1** (WCAG 1.4.11)
  - e.g. `outline/surface`

See: `test/core/theme/color_contrast_test.dart:1`

High contrast mode:
- When the OS requests increased contrast (`MediaQuery.highContrastOf(context)`), the app shell can
  switch to a high-contrast theme variant that strengthens subtle borders (e.g. `outlineVariant`).

### 4) Status colors (success/info/warning)

Use `context.semanticColors.*`:

- `success`, `onSuccess`, `successContainer`, `onSuccessContainer`
- `info`, `onInfo`, `infoContainer`, `onInfoContainer`
- `warning`, `onWarning`, `warningContainer`, `onWarningContainer`

Do not “borrow” random greens/yellows from palettes; those will drift and are hard to police.

## “Which surface should I use?”

Quick mapping:

- Screen background: `context.bgSurface`
- Standard card/container: `context.bgContainer`
- Subtle inset container: `context.bgContainerLow`
- More prominent/elevated container: `context.bgContainerHigh` / `context.bgContainerHighest`

Prefer changing surface roles over inventing new colors.

## Code snippets

### Container + text + divider

```dart
return Container(
  color: context.bgSurface,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Title', style: TextStyle(color: context.textPrimary)),
      const SizedBox(height: 8),
      Text('Subtitle', style: TextStyle(color: context.textSecondary)),
      const Divider(height: 24, thickness: 1, color: Colors.transparent),
      Container(height: 1, color: context.hairline),
    ],
  ),
);
```

### Control border vs decorative border

```dart
// Control boundary (must be 3:1 on surface):
final controlBorder = BorderSide(color: context.border);

// Decorative separator (not guaranteed to be 3:1):
final decorativeBorder = BorderSide(color: context.borderSubtle);
```

### Status badge

```dart
final semantic = context.semanticColors;

return DecoratedBox(
  decoration: BoxDecoration(
    color: semantic.successContainer,
    borderRadius: BorderRadius.circular(999),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Text(
      'Saved',
      style: TextStyle(color: semantic.onSuccessContainer),
    ),
  ),
);
```

## Changing colors safely

1) Update seed values in `lib/core/theme/system/app_color_seeds.dart:1`
2) Run the contrast gate:
   - `tool/agent/flutterw --no-stdin test test/core/theme/color_contrast_test.dart`
3) If the gate fails, do not “pick prettier `on*` colors” in widgets; adjust seeds (or discuss a move to a custom tonal mapping strategy).

## Guardrails (so the system stays clean)

### 1) Lint: `hardcoded_ui_colors` (IDE + CI)

We enforce “no hardcoded UI colors” in shared widgets + feature layers:

- Disallowed: `Color(...)`, `Color.fromARGB(...)`, `Colors.*`, `CupertinoColors.*`
- Allowed (sentinel): `Colors.transparent`

If you truly must use a hardcoded value, add a suppression with a justification:

- File: `// ignore_for_file: hardcoded_ui_colors`
- Line: `// ignore: hardcoded_ui_colors`

### 2) CI verify tool

CI also runs:
- `tool/verify_hardcoded_ui_colors.dart`

### 3) QA helper

In dev builds, the Profile page exposes:
- **Developer → Theme roles** (visualizes `ColorScheme` + `SemanticColors`).
