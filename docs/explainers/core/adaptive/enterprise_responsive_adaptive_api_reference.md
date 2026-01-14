# Responsive + Adaptive UI API Reference (Flutter)
**Enterprise adaptive module (v2)**  
**Last updated:** 2026-01-13  

This document is the **public contract** for the in-house adaptive system.  
If you change anything here, treat it like changing an API: document it, version it, and provide migration notes.

---

## 1) Top-level concepts

### 1.1 What you should do in feature code
- Read **tokens** from `context.adaptiveLayout`
- Use provided **adaptive widgets** for common patterns
- If you need new behavior: extend the module (tokens/policies/widgets), don’t invent per-screen breakpoints

### 1.2 What you should not do
- Don’t read `MediaQuery.of(context).size.width` as a breakpoint in feature code
- Don’t create `if (width > 600)` branches in features
- Don’t manually multiply `fontSize` for accessibility scaling

---

## 2) Context API

### 2.1 Rebuild-scope guidance
Use the most specific accessor possible:

| Accessor | Rebuilds when | Use for |
|---|---|---|
| `context.adaptiveLayout` | layout size classes / tokens change | padding, columns, nav decisions, density |
| `context.adaptiveInsets` | safe padding / keyboard insets change | bottom padding above keyboard, safe area |
| `context.adaptiveText` | text scaler changes | widgets that must react to text scaling |
| `context.adaptiveMotion` | reduce motion changes | animations |
| `context.adaptiveInput` | pointer/touch mode changes | hover UI, density |
| `context.adaptiveFoldable` | display features/posture change | hinge-aware layouts |
| `context.adaptive` | anything changes | debugging or rare cases |

### 2.2 Types

```dart
AdaptiveSpec spec = context.adaptive;
LayoutSpec layout = context.adaptiveLayout;
InsetsSpec insets = context.adaptiveInsets;
TextSpec text = context.adaptiveText;
```

---

## 3) Size classes

```dart
enum WindowWidthClass { compact, medium, expanded, large, extraLarge }
enum WindowHeightClass { compact, medium, expanded }
```

Thresholds must be stable and documented.

---

## 4) Spec types (recommended)

### 4.1 AdaptiveSpec
Contains:
- `layout: LayoutSpec`
- `insets: InsetsSpec`
- `text: TextSpec`
- `motion: MotionSpec`
- `input: InputSpec`
- `platform: PlatformSpec`
- `foldable: FoldableSpec`

### 4.2 LayoutSpec
Must include:
- `Size size`
- `WindowWidthClass widthClass`
- `WindowHeightClass heightClass`
- `Orientation orientation`
- `LayoutDensity density`
- `EdgeInsets pagePadding`
- `double gutter`
- `double minTapTarget`
- `GridSpec grid`
- `NavigationSpec navigation`
- surface tokens resolution: `SurfaceTokens surface(SurfaceKind kind)`

### 4.3 InsetsSpec
- `EdgeInsets safePadding`
- `EdgeInsets viewInsets`

### 4.4 TextSpec
- `TextScaler textScaler`
- optional signals: `bool boldText`, etc.

### 4.5 FoldableSpec
- normalized display features
- `DisplayPosture posture`
- `Rect? hingeRect`
- `Axis? hingeAxis`
- `bool isSpanned`

---

## 5) Policies

### 5.1 TextScalePolicy
- `unclamped()` (default recommended)
- `clamp(minScaleFactor, maxScaleFactor)` (product decision)

Implementation must use `TextScaler.clamp` (preserves nonlinear scaling).

### 5.2 NavigationPolicy
Policy maps width class → navigation kind.

Recommend supporting:
- `NavigationKind.bar` (bottom)
- `NavigationKind.rail`
- `NavigationKind.extendedRail`
- `NavigationKind.modalDrawer`
- `NavigationKind.standardDrawer` (persistent/standard)
- `NavigationKind.none` (for regions or special flows)

### 5.3 MotionPolicy / InputPolicy / PlatformPolicy
Keep these explicit and testable; do not hide them in widget code.

Notes:
- `AdaptiveScope.platformPolicy` governs the `PlatformSpec` produced in `AdaptiveSpec`.

### 5.4 ModalPolicy
Centralizes modal presentation decisions (sheet vs dialog vs side sheet).

Notes:
- Configure once via `AdaptiveScope.modalPolicy`.
- Feature code should call `showAdaptiveModal(...)` / `showAdaptiveSideSheet(...)` and never decide “sheet vs dialog” locally.

---

## 6) Tokens

### 6.1 Layout tokens
- `pagePadding`
- `gutter`
- `minTapTarget`
- density mapping

### 6.2 Surface tokens
Define a small set:

```dart
enum SurfaceKind { reading, form, settings, dashboard, media, fullBleed }
```

Surface tokens should at minimum include:
- `contentMaxWidth`
Optional:
- `minBodyLineLength`, `maxBodyLineLength`
- `preferredPaneWidths`

### 6.3 Grid tokens
Grid should expose:
- min tile width
- computed columns from content width
- guardrails (min/max columns)

---

## 7) Widgets

Only `AdaptiveScope` is mandatory (app root). Everything else is either a recommended default, a use-case widget, or an optional helper. See: `enterprise_responsive_adaptive_usage_guide.md`.

### 7.1 AdaptiveScope
Place exactly once at app root (MaterialApp builder is ideal).

### 7.2 AdaptiveRegion
Use inside split panes / resizable panels. It recomputes local **layout**.

### 7.3 AdaptiveOverrides
Governed escape hatch for rare, per-screen overrides.

Notes:
- Prefer adding tokens/policies/widgets in `lib/core/adaptive/` instead.
- Intended for exceptional flows (e.g., force `NavigationPolicy.none()` for a subtree).

### 7.4 AppPageContainer
The default screen wrapper.
Responsibilities:
- applies page padding
- centers content
- clamps max width by surface kind
- optional safe area handling

### 7.5 AdaptiveScaffold
Shell scaffold that chooses nav component based on `layout.navigation.kind`.

### 7.6 AdaptiveSplitView
List/detail wrapper.
Responsibilities:
- compact: single-pane
- expanded+: two-pane
- hinge-aware when spanned

### 7.7 showAdaptiveModal / showAdaptiveSideSheet
Single entrypoints for modality adaptation:
- compact: bottom sheet
- medium+: dialog or side sheet

Notes:
- Modal selection is driven by `ModalPolicy` from `AdaptiveScope`.
- Use `showDialog` + `AlertDialog` for blocking confirmations/alerts (dialog is correct even on phones).

### 7.8 Optional helpers
- AdaptiveGrid
- MinTapTarget
- AdaptiveDebugOverlay

---

## 8) Extension points (how to add new capabilities cleanly)

### 8.1 Add a new token
1) Add value to token table
2) Add field to `LayoutSpec` (or `SurfaceTokens`)
3) Compute it in `AdaptiveSpecBuilder`
4) Add unit tests + docs

### 8.2 Add a new pattern widget
- Build it on top of `context.adaptiveLayout` tokens
- Keep feature routing/business logic outside the widget
- Provide guardrails (min widths, max panes, etc.)

### 8.3 Add a new capability
Example: “high contrast mode” or “reduce transparency”
- Add to environment sub-spec
- Add new `AdaptiveAspect` entry
- Implement `updateShouldNotifyDependent` for it
- Document it in this API reference

---

## 9) Recipes (canonical usage)

### 9.1 A settings screen
- Use `AppPageContainer(surface: SurfaceKind.settings)`
- Use `context.adaptiveLayout.pagePadding` and `contentMaxWidth`

### 9.2 A grid screen
- Use `AdaptiveGrid(columns: layout.grid.columns, gutter: layout.gutter)`

### 9.3 A list/detail flow
- Use `AdaptiveSplitView(master: ..., detail: ...)`
- Use `AdaptiveRegion` inside each pane if they have independent adaptation needs

### 9.4 A modal action
- Use `showAdaptiveModal(...)` and never decide “sheet vs dialog” in feature code

---

## 10) Primary references (official)

- Flutter `TextScaler` and clamp: https://api.flutter.dev/flutter/painting/TextScaler-class.html  
- Flutter `MediaQuery.withClampedTextScaling`: https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html  
- Flutter `InheritedModel`: https://api.flutter.dev/flutter/widgets/InheritedModel-class.html  
- Material window size classes: https://m3.material.io/foundations/layout/applying-layout/window-size-classes  

---
