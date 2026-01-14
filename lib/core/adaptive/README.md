# Adaptive (Responsive + Adaptive UI)

This module provides an in-house, enterprise-grade responsive + adaptive UI contract for Flutter.

**Import (preferred):**
```dart
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';
```

## What this is
- A single **runtime contract** (`AdaptiveSpec`) derived from local `BoxConstraints` + `MediaQuery` capabilities.
- A root provider (`AdaptiveScope`) implemented with `InheritedModel` so widgets can subscribe to **only the aspects they need**.
- A local subtree provider (`AdaptiveRegion`) so **nested panes** (split views, inspectors) adapt to their own constraints.
- A governed escape hatch (`AdaptiveOverrides`) for rare, per-screen overrides (should be reviewed).
- Policies and token tables to keep behavior **governable** and **testable**.
- Opinionated widgets for the “good path”:
  - `AppPageContainer`
  - `AdaptiveScaffold`
  - `AdaptiveSplitView`
  - `showAdaptiveModal` / `showAdaptiveSideSheet`
  - `AdaptiveGrid`
  - `MinTapTarget`

## Rules (non-negotiable)
1) Feature code must not introduce ad-hoc breakpoints (no `if (width > 600)`).
2) Prefer `context.adaptiveLayout` (or the most specific accessor) over `context.adaptive`.
3) If you need local constraints, use `AdaptiveRegion` (don’t scatter `LayoutBuilder` breakpoints across screens).
4) Never “scale fonts manually” for accessibility. Use `TextScaler` (and the app’s configured `TextScalePolicy`).

## Public API (overview)

| Category | Use |
|---------|-----|
| Context accessors | `context.adaptiveLayout`, `context.adaptiveInsets`, `context.adaptiveText`, `context.adaptiveMotion`, `context.adaptiveInput`, `context.adaptivePlatform`, `context.adaptiveFoldable` |
| Providers | `AdaptiveScope` (root), `AdaptiveRegion` (local constraints), `AdaptiveOverrides` (rare overrides) |
| Policies | `TextScalePolicy`, `NavigationPolicy`, `ModalPolicy`, `MotionPolicy`, `InputPolicy`, `PlatformPolicy` |
| Tokens | `LayoutTokens`, `GridTokens`, `SurfaceTokenTable`, `NavigationTokens` |
| Widgets | `AppPageContainer`, `AdaptiveScaffold`, `AdaptiveSplitView`, `showAdaptiveModal`, `showAdaptiveSideSheet`, `AdaptiveGrid`, `MinTapTarget` |

## Breakpoints (size classes)

Width (dp):
- `compact`: < 600
- `medium`: 600–839
- `expanded`: 840–1199
- `large`: 1200–1599
- `extraLarge`: ≥ 1600

Height (dp):
- `compact`: < 480
- `medium`: 480–899
- `expanded`: ≥ 900

## Where it lives
This module lives under `lib/core/adaptive/` and is intentionally separate from `lib/core/theme/`.

## Root setup (recommended)
Place `AdaptiveScope` once at app root (typically in `MaterialApp.builder`):

```dart
MaterialApp(
  builder: (context, child) {
    return AdaptiveScope(
      navigationPolicy: const NavigationPolicy.standard(),
      textScalePolicy: const TextScalePolicy.clamp(maxScaleFactor: 2.0),
      child: child ?? const SizedBox.shrink(),
    );
  },
)
```

Debug-only tools (optional): `AdaptiveDebugOverlay` / `AdaptiveDebugBanner`.

## Feature usage (canonical)
```dart
final layout = context.adaptiveLayout;
final padding = layout.pagePadding;
final columns = layout.grid.columns;
```

## Visual regression (golden matrix)

This repo includes a small golden matrix covering “settings surface” behavior at:
- compact + 1.0x text
- compact + 2.0x text
- expanded + 1.0x text
- expanded + 2.0x text

See: `test/core/adaptive/goldens/adaptive_settings_matrix_golden_test.dart`
