# Usage Guide: Enterprise Responsive + Adaptive UI (Flutter)
**Start here (day-to-day guide)**  
**Last updated:** 2026-01-14

This is the “how to build screens” guide for the in-house responsive + adaptive system under `lib/core/adaptive/`.

If you are new to this module: read this doc end-to-end once, then use it as a cookbook.

---

## 0) What problem this solves (in one paragraph)

Feature code should not implement “responsive UI” by scattering ad-hoc breakpoints and `MediaQuery` reads across screens.  
Instead, we derive a **single, testable runtime contract** (`AdaptiveSpec`) from **constraints + capabilities**, and feature code consumes that contract via `context.adaptiveLayout` (and other aspect accessors). This keeps behavior consistent across the app and governable over time.

---

## 1) Quick start (5 minutes)

### 1.1 Wire `AdaptiveScope` at app root (exactly once)

Recommended: install it in `MaterialApp.builder`.

```dart
import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';

MaterialApp(
  builder: (context, child) {
    return AdaptiveScope(
      navigationPolicy: const NavigationPolicy.standard(),
      // Product decision: clamp a11y text scaling to a safe range.
      textScalePolicy: const TextScalePolicy.clamp(
        minScaleFactor: 1.0,
        maxScaleFactor: 2.0,
      ),
      // Centralized modal decisions (sheet vs dialog vs side sheet).
      modalPolicy: const ModalPolicy.standard(),
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

That’s it. Everything below assumes this exists.

### 1.2 Build screens using “good path” widgets

- Default wrapper: `AppPageContainer(surface: ...)`
- Default shell/nav: `AdaptiveScaffold(...)`
- Default list/detail: `AdaptiveSplitView(...)`
- Default modals: `showAdaptiveModal(...)` / `showAdaptiveSideSheet(...)`

### 1.3 Use aspect accessors (not `MediaQuery`)

Prefer the most specific accessor:

- layout: `context.adaptiveLayout`
- insets: `context.adaptiveInsets`
- text: `context.adaptiveText`
- motion: `context.adaptiveMotion`
- input: `context.adaptiveInput`
- foldable: `context.adaptiveFoldable`

---

## 2) Golden rules (non-negotiable)

1) **No ad-hoc breakpoints in features** (`if (width > 600)` is banned).
2) **Don’t use `MediaQuery.size` for layout decisions** in feature code.
3) Use `AdaptiveRegion` for nested panes instead of more `LayoutBuilder` branches.
4) Never “scale fonts manually.” Let `TextScaler` do its job; the app’s clamping policy is applied at the root.
5) If the system doesn’t cover a need, **extend `lib/core/adaptive/`** (token/policy/widget) with tests and docs.

---

## 3) The mental model (what to reach for)

### 3.1 Responsive vs adaptive (practical definition)

- **Responsive**: layout changes due to **available space** (constraints) — width class, height class, columns, padding, navigation kind.
- **Adaptive**: behavior changes due to **capabilities/preferences** — text scaling, reduce motion, input mode, foldable posture, platform conventions.

This module covers both by publishing a single contract.

### 3.2 “Size classes” are the stable branch points

In feature code, branch on:
- `layout.widthClass` / `layout.heightClass`
- `layout.navigation.kind`
- `layout.grid.columns`

Not raw numbers.

---

## 4) Building a standard screen

### 4.1 Use `AppPageContainer` + a surface kind

Surface kinds provide sensible width clamping and page layout rules.

```dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      surface: SurfaceKind.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // Page content...
        ],
      ),
    );
  }
}
```

Guideline:
- Choose the closest surface: `settings`, `form`, `reading`, `dashboard`, `media`, `fullBleed`.
- If none match, add a new surface kind + tokens in `lib/core/adaptive/tokens/`.

### 4.2 Use layout tokens instead of hard-coded page padding

```dart
final layout = context.adaptiveLayout;
final padding = layout.pagePadding;
final gutter = layout.gutter;
```

Use:
- `layout.pagePadding` for page-level horizontal padding and dialog inset padding.
- `layout.gutter` for grid/list spacing between cards/tiles at the page level.

For small internal spacing (between controls), prefer theme spacing tokens (e.g. `core/theme/tokens/spacing.dart`) unless you have a proven need for width-class-dependent spacing.

---

## 5) Navigation: `AdaptiveScaffold`

Use `AdaptiveScaffold` for shell navigation. It consumes `layout.navigation.kind` and chooses the right pattern.

Rule:
- Feature screens should not decide “bottom bar vs rail vs drawer.”
- They provide the content and nav destinations; the scaffold adapts.

If a flow must disable navigation (rare), wrap the subtree:

```dart
AdaptiveOverrides(
  navigationPolicy: const NavigationPolicy.none(),
  child: YourFlow(),
);
```

This is intentionally narrow and should be reviewed.

---

## 6) Lists, grids, and dashboards

Use `layout.grid` and/or `AdaptiveGrid` (depending on your UI):

```dart
final layout = context.adaptiveLayout;
return AdaptiveGrid(
  columns: layout.grid.columns,
  gutter: layout.gutter,
  children: items.map((it) => YourTile(it)).toList(),
);
```

Guidelines:
- Treat `layout.grid.columns` as the “global safe default” columns for the current surface width.
- If a specific component needs its own grid rules, that belongs in adaptive tokens (or the component) with a clear reason.

---

## 7) Modals and side sheets (single entrypoints)

### 7.1 Use `showAdaptiveModal` for “sheet on phone, dialog on tablet”

```dart
await showAdaptiveModal<void>(
  context: context,
  builder: (_) => const YourModalContent(),
);
```

Do not decide “sheet vs dialog” in feature code; that’s driven by `ModalPolicy` installed at the root.

### 7.2 Use `showAdaptiveSideSheet` for “side sheet on tablet, fallback on phone”

```dart
await showAdaptiveSideSheet<void>(
  context: context,
  builder: (_) => const YourSheetContent(),
);
```

---

## 8) Forms and keyboards (insets)

Use `context.adaptiveInsets.viewInsets` to react to the keyboard and avoid “submit button hidden under keyboard.”

Typical pattern:
- Your page content scrolls.
- The bottom CTA is padded by `max(viewInsets.bottom, safePadding.bottom)`.

If you find repeated patterns, add a small core widget (e.g., a `KeyboardInsetPadding` wrapper) under `lib/core/adaptive/widgets/` or `lib/core/widgets/`.

---

## 9) Nested constraints: split views and panes

Use `AdaptiveSplitView` for list/detail.

Inside each pane, if it should adapt to its own width, wrap the pane body with `AdaptiveRegion`:

- `AdaptiveRegion` re-derives the local `LayoutSpec` from pane constraints
- it inherits the rest of the environment (text/motion/input/platform/foldable/insets)
- it forces `NavigationKind.none` in the region (no nested nav shells)

---

## 10) Accessibility and motion

### 10.1 Text scaling

- Root applies `TextScalePolicy` using `TextScaler.clamp(...)`.
- Feature code must not multiply font sizes based on text scale.

### 10.2 Reduce motion

If you implement animations/transitions in a feature:

- Check `context.adaptiveMotion.reduceMotion`
- Prefer shortening durations, reducing movement, or using fades

If a pattern repeats, implement a core helper (e.g., `adaptiveDuration(...)`) inside `lib/core/adaptive/`.

---

## 11) Pointer vs touch (density and hover)

If you need hover affordances (tooltips, hover highlights), consult:
- `context.adaptiveInput.mode`
- `context.adaptiveInput.pointerHoverEnabled`

Guideline:
- Don’t hide essential actions behind hover.
- Pointer mode can use denser layouts; touch mode must respect min tap target.

---

## 12) Foldables (optional, but supported)

If you are building a two-pane UI:
- Prefer `AdaptiveSplitView` (hinge-aware when spanned).
- If you implement hinge-aware layouts manually, use `context.adaptiveFoldable`.

---

## 13) Testing and stability

This module is only “enterprise-grade” if it stays stable over time.

Minimum expectations for changes to `lib/core/adaptive/`:
- unit tests for policy/token boundary behavior
- at least one golden matrix update for visible layout changes

Reference: `test/core/adaptive/goldens/adaptive_settings_matrix_golden_test.dart`

---

## 14) Where to go deeper (when needed)

- Public contract + rules: `enterprise_responsive_adaptive_api_reference.md`
- Mechanics/pipeline/rebuilds: `adaptive_system_under_the_hood.md`
- Extending the module: `enterprise_responsive_adaptive_implementation_guide.md`
- Height class usage: `height_class_adaptation.md`

