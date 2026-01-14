# Implementation Guide: Enterprise Responsive + Adaptive System (Flutter)
**Drop-in replacement implementation guide (v2)**  
**Last updated:** 2026-01-13  
**Companion to:** `enterprise_responsive_adaptive_proposal.md`

---

## 0) What you are building

You are building an in-house module that provides:

1) A **runtime adaptive contract** (`AdaptiveSpec`) computed from constraints + capabilities
2) An **app root scope** (`AdaptiveScope`) that provides the contract via `InheritedModel`
3) A **local region scope** (`AdaptiveRegion`) for nested constraints (panes, split views)
4) A set of **policies** and **token tables**
5) A set of **opinionated widgets** that are the “good path” for 90% of screens
6) A **debug overlay** and a **testing matrix** to keep the contract reliable over time

> The point is not “lots of breakpoints.”  
> The point is **consistent outcomes** and **governable adaptation**.

---

## 1) Folder tree (recommended)

```
lib/
└── core/
    └── adaptive/
        ├── README.md
        ├── adaptive_aspect.dart
        ├── adaptive_scope.dart
        ├── adaptive_region.dart
        ├── adaptive_context.dart
        ├── adaptive_spec.dart
        ├── adaptive_spec_builder.dart
        ├── size_classes.dart
        ├── policies/
        │   ├── text_scale_policy.dart
        │   ├── motion_policy.dart
        │   ├── input_policy.dart
        │   ├── platform_policy.dart
        │   └── navigation_policy.dart
        ├── tokens/
        │   ├── layout_tokens.dart
        │   ├── surface_tokens.dart
        │   ├── grid_tokens.dart
        │   └── navigation_tokens.dart
        ├── foldables/
        │   ├── foldable_spec.dart
        │   ├── display_posture.dart
        │   └── display_feature_utils.dart
        ├── widgets/
        │   ├── app_page_container.dart
        │   ├── adaptive_scaffold.dart
        │   ├── adaptive_split_view.dart
        │   ├── adaptive_modal.dart
        │   ├── adaptive_side_sheet.dart
        │   ├── adaptive_grid.dart
        │   └── min_tap_target.dart
        └── debug/
            ├── adaptive_debug_overlay.dart
            └── adaptive_debug_banner.dart
```

---

## 2) Core public API (to prevent “slop”)

### 2.1 Context accessors (preferred)

- `context.adaptiveLayout` → subscribe only to layout changes
- `context.adaptiveText` → subscribe only to text scaling changes
- `context.adaptiveInsets` → subscribe only to safe area / keyboard insets changes
- `context.adaptiveMotion`, `context.adaptiveInput`, `context.adaptivePlatform`, `context.adaptiveFoldable`

Convenience (rebuilds on any spec change):
- `context.adaptive` → full spec

### 2.2 Primary building blocks

- `AdaptiveScope` (root)
- `AdaptiveRegion` (local subtree)
- `AppPageContainer` (padding + centering + max width)
- `AdaptiveScaffold` (navigation adaptation)
- `AdaptiveSplitView` (master/detail)
- `showAdaptiveModal` (sheet vs dialog)
- `showAdaptiveSideSheet` (medium+ side sheet)
- `AdaptiveGrid` helper
- `MinTapTarget` wrapper (optional enforcement)

### 2.3 Escape hatches (governed)
- `SurfaceKind` and `SurfaceTokens`: define layout differences by surface type
- `AdaptiveOverrides`: temporary per-screen overrides (rare; must be reviewed)
- `AdaptiveSelector`: optional “select” rebuild pattern without external deps (if you choose to implement it)

**Rule:** If a team needs something that isn’t covered, add a token/policy/widget in this module with tests. Don’t invent one-off breakpoints in features.

---

## 3) Size classes (`size_classes.dart`)

```dart
enum WindowWidthClass { compact, medium, expanded, large, extraLarge }
enum WindowHeightClass { compact, medium, expanded }

class AdaptiveBreakpoints {
  static const double widthCompactMax = 600;
  static const double widthMediumMax = 840;
  static const double widthExpandedMax = 1200;
  static const double widthLargeMax = 1600;

  static const double heightCompactMax = 480;
  static const double heightMediumMax = 900;
}

WindowWidthClass widthClassFor(double width) { ... }
WindowHeightClass heightClassFor(double height) { ... }
```

Notes:
- Use **logical pixels (dp)** from constraints, not physical pixels.
- Keep these constants stable; changing them is a contract-breaking change.

---

## 4) Policies (product decisions)

### 4.1 Text scale policy (modern and correct)

**Do not convert TextScaler to a single linear factor.**  
Use `TextScaler.clamp` (preserves nonlinear scaling) or `MediaQuery.withClampedTextScaling`.

`policies/text_scale_policy.dart`:

```dart
import 'package:flutter/painting.dart';

sealed class TextScalePolicy {
  const TextScalePolicy();
  TextScaler apply(TextScaler incoming);

  const factory TextScalePolicy.unclamped() = _UnclampedPolicy;

  /// Clamp scaled text sizes to [minScaleFactor * fontSize, maxScaleFactor * fontSize].
  const factory TextScalePolicy.clamp({
    double minScaleFactor,
    double maxScaleFactor,
  }) = _ClampedPolicy;
}

class _UnclampedPolicy extends TextScalePolicy {
  const _UnclampedPolicy();
  @override
  TextScaler apply(TextScaler incoming) => incoming;
}

class _ClampedPolicy extends TextScalePolicy {
  const _ClampedPolicy({
    this.minScaleFactor = 0.0,
    this.maxScaleFactor = double.infinity,
  }) : assert(maxScaleFactor >= minScaleFactor);

  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  TextScaler apply(TextScaler incoming) =>
      incoming.clamp(minScaleFactor: minScaleFactor, maxScaleFactor: maxScaleFactor);
}
```

**Recommendation:** default to `unclamped` unless product requires clamping; if clamping is required, start with `maxScaleFactor: 2.0`.

Optional per-surface override:
- reading surfaces may allow larger
- dense dashboards may clamp tighter (with accessibility sign-off)

### 4.2 Motion policy
`MotionPolicy` should map `MediaQueryData.disableAnimations` / `accessibleNavigation` to:
- reduced durations
- removing non-essential motion
- disabling parallax/hero transitions if needed

### 4.3 Input policy (touch vs pointer vs mixed)
Derive from:
- Flutter does not currently expose pointer-hover capability via `MediaQueryData`.
- Use `RendererBinding.instance.mouseTracker.mouseIsConnected` (and rebuild the scope when it changes) as a best-effort signal.
- platform signals (desktop/web more likely pointer-first)

### 4.4 Platform policy
Decide explicitly:
- when to use `.adaptive()` constructors (Switch/Slider/etc.)
- how dialogs/modals should look on iOS vs Android
- keyboard shortcuts on desktop

### 4.5 Navigation policy
Choose nav components based on width class:
- compact → navigation bar
- medium/expanded → navigation rail (optionally extended rail)
- large/extraLarge → extended rail or standard drawer

Keep this in one policy file; do not spread across the app.

---

## 5) Tokens (tables)

### 5.1 Layout tokens
`tokens/layout_tokens.dart` should provide stepwise values by width/height class.

Example:

```dart
class LayoutTokens {
  static EdgeInsets pagePadding(WindowWidthClass w) => switch (w) {
    WindowWidthClass.compact => const EdgeInsets.symmetric(horizontal: 16),
    WindowWidthClass.medium => const EdgeInsets.symmetric(horizontal: 24),
    WindowWidthClass.expanded => const EdgeInsets.symmetric(horizontal: 32),
    WindowWidthClass.large => const EdgeInsets.symmetric(horizontal: 40),
    WindowWidthClass.extraLarge => const EdgeInsets.symmetric(horizontal: 48),
  };

  static double gutter(WindowWidthClass w) => switch (w) {
    WindowWidthClass.compact => 12,
    WindowWidthClass.medium => 16,
    _ => 20,
  };

  static double minTapTarget(InputMode mode) =>
      mode == InputMode.touch ? 48 : 44;
}
```

### 5.2 Surface tokens
Different screens need different max widths.

Define:

```dart
enum SurfaceKind { reading, form, settings, dashboard, media, fullBleed }

class SurfaceTokens {
  const SurfaceTokens({required this.contentMaxWidth});
  final double? contentMaxWidth; // null == unconstrained
}

class SurfaceTokenTable {
  static SurfaceTokens resolve({
    required SurfaceKind kind,
    required WindowWidthClass widthClass,
  }) { ... }
}
```

Keep `SurfaceKind` small and meaningful. Avoid “one kind per screen.”

### 5.3 Grid tokens
Provide:
- min tile width
- max columns by size class (guardrail)
- a function to compute columns from content width

---

## 6) The spec model (`adaptive_spec.dart`)

### 6.1 Sub-specs (value types)

Create value objects and implement equality to avoid rebuild storms.

Example structure:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AdaptiveSpec {
  const AdaptiveSpec({
    required this.layout,
    required this.insets,
    required this.text,
    required this.motion,
    required this.input,
    required this.platform,
    required this.foldable,
  });

  final LayoutSpec layout;
  final InsetsSpec insets;
  final TextSpec text;
  final MotionSpec motion;
  final InputSpec input;
  final PlatformSpec platform;
  final FoldableSpec foldable;

  AdaptiveSpec copyWith({
    LayoutSpec? layout,
    InsetsSpec? insets,
    TextSpec? text,
    MotionSpec? motion,
    InputSpec? input,
    PlatformSpec? platform,
    FoldableSpec? foldable,
  }) => AdaptiveSpec(
    layout: layout ?? this.layout,
    insets: insets ?? this.insets,
    text: text ?? this.text,
    motion: motion ?? this.motion,
    input: input ?? this.input,
    platform: platform ?? this.platform,
    foldable: foldable ?? this.foldable,
  );

  @override
  bool operator ==(Object other) =>
      other is AdaptiveSpec &&
      layout == other.layout &&
      insets == other.insets &&
      text == other.text &&
      motion == other.motion &&
      input == other.input &&
      platform == other.platform &&
      foldable == other.foldable;

  @override
  int get hashCode => Object.hash(layout, insets, text, motion, input, platform, foldable);
}
```

Each sub-spec also implements value equality and hashCode.

### 6.2 LayoutSpec example

```dart
@immutable
class LayoutSpec {
  const LayoutSpec({
    required this.size,
    required this.widthClass,
    required this.heightClass,
    required this.orientation,
    required this.density,
    required this.pagePadding,
    required this.gutter,
    required this.minTapTarget,
    required this.surfaceTokens,
    required this.grid,
    required this.navigation,
  });

  final Size size;
  final WindowWidthClass widthClass;
  final WindowHeightClass heightClass;
  final Orientation orientation;

  final LayoutDensity density;
  final EdgeInsets pagePadding;
  final double gutter;
  final double minTapTarget;

  /// Surface tokens are resolved by SurfaceKind.
  final Map<SurfaceKind, SurfaceTokens> surfaceTokens;

  final GridSpec grid;
  final NavigationSpec navigation;

  SurfaceTokens surface(SurfaceKind kind) =>
      surfaceTokens[kind] ?? const SurfaceTokens(contentMaxWidth: null);

  // value equality: compare fields + map content (keep map small; use stable keys)
}
```

> If you prefer simpler equality, replace the map with a small struct containing the few surface tokens you actually use.

### 6.3 InsetsSpec example (volatile)
```dart
@immutable
class InsetsSpec {
  const InsetsSpec({
    required this.safePadding,
    required this.viewInsets,
  });

  final EdgeInsets safePadding;
  final EdgeInsets viewInsets;
}
```

Widgets should subscribe to InsetsSpec only when needed.

---

## 7) The builder (`adaptive_spec_builder.dart`)

**Rule:** This file is the only place where:
- size classes are computed
- tokens are selected
- navigation/modal policies are resolved

Keep it **pure and testable**.

Suggested structure:

```dart
class AdaptiveSpecBuilder {
  static AdaptiveSpec build({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required TargetPlatform platform,
    required TextScalePolicy textScalePolicy,
    required NavigationPolicy navigationPolicy,
    required MotionPolicy motionPolicy,
    required InputPolicy inputPolicy,
  }) {
    final size = Size(
      constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
      constraints.maxHeight.isFinite ? constraints.maxHeight : 0,
    );

    final widthClass = widthClassFor(size.width);
    final heightClass = heightClassFor(size.height);
    final orientation = size.width >= size.height ? Orientation.landscape : Orientation.portrait;

    final input = inputPolicy.derive(media: media, platform: platform);
    final motion = motionPolicy.derive(media: media);
    final text = TextSpec(textScaler: textScalePolicy.apply(media.textScaler));

    final insets = InsetsSpec(
      safePadding: media.padding, // or viewPadding depending on your choice
      viewInsets: media.viewInsets,
    );

    final layout = LayoutSpec(
      size: size,
      widthClass: widthClass,
      heightClass: heightClass,
      orientation: orientation,
      density: _densityFor(input, widthClass),
      pagePadding: LayoutTokens.pagePadding(widthClass),
      gutter: LayoutTokens.gutter(widthClass),
      minTapTarget: LayoutTokens.minTapTarget(input.mode),
      surfaceTokens: _resolveSurfaceTokens(widthClass),
      grid: _buildGrid(widthClass, size),
      navigation: navigationPolicy.resolve(widthClass: widthClass),
    );

    final foldable = FoldableSpec.fromDisplayFeatures(media.displayFeatures);

    return AdaptiveSpec(
      layout: layout,
      insets: insets,
      text: text,
      motion: motion,
      input: input,
      platform: PlatformSpec(platform: platform),
      foldable: foldable,
    );
  }
}
```

**Important:** the `TextScalePolicy` should be applied either here or (preferably) via a `MediaQuery` wrapper above the app. Do not apply it in both places unless you intentionally stack clamps.

---

## 8) The scope (`adaptive_scope.dart`) — using InheritedModel

### 8.1 Aspects
`adaptive_aspect.dart`:

```dart
enum AdaptiveAspect { layout, insets, text, motion, input, platform, foldable }
```

### 8.2 Scope widget
`adaptive_scope.dart`:

```dart
class AdaptiveScope extends StatelessWidget {
  const AdaptiveScope({
    super.key,
    required this.child,
    this.textScalePolicy = const TextScalePolicy.unclamped(),
    required this.navigationPolicy,
    this.motionPolicy = const MotionPolicy.standard(),
    this.inputPolicy = const InputPolicy.standard(),
  });

  final Widget child;
  final TextScalePolicy textScalePolicy;
  final NavigationPolicy navigationPolicy;
  final MotionPolicy motionPolicy;
  final InputPolicy inputPolicy;

  @override
  Widget build(BuildContext context) {
    // Must be below MediaQuery (MaterialApp provides it).
    final media = MediaQuery.of(context);

    // Apply text scaling policy at the MediaQuery level.
    // This preserves nonlinear scaling (TextScaler.clamp) and makes the policy
    // automatically visible to all Text widgets that read MediaQuery.
    final appliedTextScaler = textScalePolicy.apply(media.textScaler);

    return MediaQuery(
      data: media.copyWith(textScaler: appliedTextScaler),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spec = AdaptiveSpecBuilder.build(
            constraints: constraints,
            media: MediaQuery.of(context), // now includes appliedTextScaler
            platform: Theme.of(context).platform,
            textScalePolicy: const TextScalePolicy.unclamped(), // already applied above
            navigationPolicy: navigationPolicy,
            motionPolicy: motionPolicy,
            inputPolicy: inputPolicy,
          );
          return _AdaptiveModel(spec: spec, child: child);
        },
      ),
    );
  }
}
```

### 8.3 InheritedModel provider
`_AdaptiveModel` should:
- notify only on value changes (`spec != old.spec`)
- rebuild dependents only if the aspect they depend on changed

```dart
class _AdaptiveModel extends InheritedModel<AdaptiveAspect> {
  const _AdaptiveModel({required this.spec, required super.child});
  final AdaptiveSpec spec;

  static AdaptiveSpec of(BuildContext context, {AdaptiveAspect? aspect}) {
    final _AdaptiveModel? model =
        InheritedModel.inheritFrom<_AdaptiveModel>(context, aspect: aspect);
    assert(model != null, 'No AdaptiveScope found in context');
    return model!.spec;
  }

  /// Non-listening read (use sparingly).
  static AdaptiveSpec read(BuildContext context) {
    final widget =
        context.getElementForInheritedWidgetOfExactType<_AdaptiveModel>()?.widget as _AdaptiveModel?;
    assert(widget != null, 'No AdaptiveScope found in context');
    return widget!.spec;
  }

  @override
  bool updateShouldNotify(_AdaptiveModel oldWidget) => spec != oldWidget.spec;

  @override
  bool updateShouldNotifyDependent(
    _AdaptiveModel oldWidget,
    Set<AdaptiveAspect> dependencies,
  ) {
    if (dependencies.contains(AdaptiveAspect.layout) &&
        spec.layout != oldWidget.spec.layout) return true;

    if (dependencies.contains(AdaptiveAspect.insets) &&
        spec.insets != oldWidget.spec.insets) return true;

    if (dependencies.contains(AdaptiveAspect.text) &&
        spec.text != oldWidget.spec.text) return true;

    if (dependencies.contains(AdaptiveAspect.motion) &&
        spec.motion != oldWidget.spec.motion) return true;

    if (dependencies.contains(AdaptiveAspect.input) &&
        spec.input != oldWidget.spec.input) return true;

    if (dependencies.contains(AdaptiveAspect.platform) &&
        spec.platform != oldWidget.spec.platform) return true;

    if (dependencies.contains(AdaptiveAspect.foldable) &&
        spec.foldable != oldWidget.spec.foldable) return true;

    return false;
  }
}
```

---

## 9) Context extensions (`adaptive_context.dart`)

```dart
extension AdaptiveContextX on BuildContext {
  AdaptiveSpec get adaptive => _AdaptiveModel.of(this);

  LayoutSpec get adaptiveLayout =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.layout).layout;

  InsetsSpec get adaptiveInsets =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.insets).insets;

  TextSpec get adaptiveText =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.text).text;

  MotionSpec get adaptiveMotion =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.motion).motion;

  InputSpec get adaptiveInput =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.input).input;

  PlatformSpec get adaptivePlatform =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.platform).platform;

  FoldableSpec get adaptiveFoldable =>
      _AdaptiveModel.of(this, aspect: AdaptiveAspect.foldable).foldable;
}
```

**Guideline for teams:** Prefer `adaptiveLayout` for layout decisions.  
Use `adaptiveInsets` only when you actually need safe area or keyboard insets.

---

## 10) Local adaptation (`adaptive_region.dart`)

### 10.1 Why you need this
A global window spec is not enough for:
- two-pane layouts where the detail pane has different constraints
- side sheets / inspectors
- resizable panels on desktop

### 10.2 Implementation concept
`AdaptiveRegion` recomputes **layout** from local constraints but reuses the environment specs from the nearest scope.

```dart
class AdaptiveRegion extends StatelessWidget {
  const AdaptiveRegion({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Non-listening read: we want environment values but layout will be local.
    final parent = _AdaptiveModel.read(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final localLayout = AdaptiveSpecBuilder.build(
          constraints: constraints,
          media: MediaQuery.of(context),
          platform: parent.platform.platform,
          textScalePolicy: const TextScalePolicy.unclamped(),
          navigationPolicy: const NavigationPolicy.none(), // regions generally don't own nav
          motionPolicy: const MotionPolicy.standard(),
          inputPolicy: const InputPolicy.standard(),
        ).layout;

        final localSpec = parent.copyWith(layout: localLayout);

        return _AdaptiveModel(spec: localSpec, child: child);
      },
    );
  }
}
```

> Real implementation: don’t rebuild `navigation` inside regions; treat it as a root concern.  
> You can add a builder method `deriveLayout(...)` to avoid re-deriving env specs.

---

## 11) Opinionated widgets (the good path)

### 11.1 `AppPageContainer`
Responsibilities:
- apply page padding and centering
- clamp content width based on surface tokens
- optionally apply SafeArea

Public API:
- `surface: SurfaceKind` (required, default `SurfaceKind.settings` or `SurfaceKind.dashboard`)
- `safeArea: bool` (default true)
- `child`

### 11.2 `AdaptiveScaffold`
Responsibilities:
- choose navigation model based on `context.adaptiveLayout.navigation`
- render NavigationBar / NavigationRail / ExtendedRail / Drawer variant
- host the routed body

Public API:
- destinations
- selected index
- onDestinationSelected
- body builder

### 11.3 `AdaptiveSplitView`
Responsibilities:
- compact: single-pane (route or conditional)
- expanded+: two-pane
- foldables: avoid hinge area

Public API:
- master widget
- detail widget
- selection state
- min pane widths
- optional divider width

### 11.4 `showAdaptiveModal` + `showAdaptiveSideSheet`
Responsibilities:
- choose sheet vs dialog vs side sheet based on layout width class
- enforce max width + insets

---

## 12) Root setup (where to put AdaptiveScope)

Recommended:

```dart
MaterialApp(
  builder: (context, child) {
    final app = AdaptiveScope(
      navigationPolicy: const NavigationPolicy.standard(),
      textScalePolicy: const TextScalePolicy.clamp(maxScaleFactor: 2.0),
      child: child ?? const SizedBox.shrink(),
    );

    return Stack(
      children: [
        app,
        if (kDebugMode) const AdaptiveDebugOverlay(),
      ],
    );
  },
);
```

Notes:
- Put `AdaptiveScope` **below** the `MediaQuery` created by `MaterialApp`.
- If using `MaterialApp.router`, wrap the router output similarly.

---

## 13) Rules of use (non-negotiable)

1) **Do not** use ad-hoc `MediaQuery.of(context).size.width` in feature code.
2) **Do** use `context.adaptiveLayout` tokens and adaptive widgets.
3) Any new responsive behavior must be added to:
   - token tables (`tokens/`)
   - policies (`policies/`)
   - builder (`adaptive_spec_builder.dart`)
4) If you need local constraints: use `AdaptiveRegion`, not ad-hoc `LayoutBuilder` logic scattered across screens.
5) No “scale everything” helper APIs.
6) For text scaling: never multiply font sizes for accessibility; rely on `TextScaler` and layout that can grow.

---

## 14) Testing strategy

### 14.1 Unit tests
- width/height class boundaries
- token outputs per class
- navigation policy selection
- modal policy selection
- grid math
- TextScalePolicy apply/clamp

### 14.2 Widget tests / golden tests
Run a small matrix per key page:
- compact + 1.0x text
- compact + 2.0x text
- expanded + 1.0x text
- expanded + 2.0x text

### 14.3 Accessibility regression checks
- verify tappable controls meet `minTapTarget`
- no clipped text at max scaling policy
- verify focus traversal on desktop/web

---

## 15) Migration notes (from v1 proposal/guide)

Key changes from the earlier v1 documents:

- **TextScaler clamping is corrected**: use `TextScaler.clamp` / `MediaQuery.withClampedTextScaling` (no linearization).
- **Performance is improved**: spec is provided via `InheritedModel` with aspect-based subscriptions.
- **Local constraints are supported**: `AdaptiveRegion` enables nested adaptive layouts.
- **Navigation is policy-driven** and supports evolving Material guidance (rail, extended rail, drawer variants).
- **Insets are isolated** so keyboard changes don’t rebuild the whole app.

---

## 16) References (primary sources)

- Flutter `MediaQuery.withClampedTextScaling` API: https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html  
- Flutter `TextScaler` and `TextScaler.clamp`: https://api.flutter.dev/flutter/painting/TextScaler-class.html  
- Flutter breaking change: deprecate `textScaleFactor` in favor of `TextScaler`: https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor  
- Flutter `MediaQuery` property-specific accessors (`sizeOf`, `paddingOf`, etc.): https://api.flutter.dev/flutter/widgets/MediaQuery-class.html  
- Flutter `InheritedModel` API: https://api.flutter.dev/flutter/widgets/InheritedModel-class.html  
- Material Design window size classes: https://m3.material.io/foundations/layout/applying-layout/window-size-classes  

---
