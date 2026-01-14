# Adaptive (Responsive + Adaptive UI)

This module provides an in-house, enterprise-grade responsive + adaptive UI contract for Flutter.

## What this is
- A single **runtime contract** (`AdaptiveSpec`) derived from local `BoxConstraints` + `MediaQuery` capabilities.
- A root provider (`AdaptiveScope`) implemented with `InheritedModel` so widgets can subscribe to **only the aspects they need**.
- A local subtree provider (`AdaptiveRegion`) so **nested panes** (split views, inspectors) adapt to their own constraints.
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

## Where it lives
This module lives under `lib/core/adaptive/` and is intentionally separate from `lib/core/theme/`.

## Root setup (recommended)
Place `AdaptiveScope` once at app root (typically in `MaterialApp.builder`):

```dart
MaterialApp(
  builder: (context, child) {
    return Stack(
      children: [
        AdaptiveScope(
          navigationPolicy: const NavigationPolicy.standard(),
          textScalePolicy: const TextScalePolicy.clamp(maxScaleFactor: 2.0),
          child: child ?? const SizedBox.shrink(),
        ),
        if (kDebugMode) const AdaptiveDebugOverlay(),
      ],
    );
  },
)
```

## Feature usage (canonical)
```dart
final layout = context.adaptiveLayout;
final padding = layout.pagePadding;
final columns = layout.grid.columns;
```

