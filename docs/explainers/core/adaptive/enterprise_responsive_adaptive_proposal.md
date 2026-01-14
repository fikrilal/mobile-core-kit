# Enterprise Responsive + Adaptive UI System for Flutter
**Drop-in replacement proposal (v2)**  
**Last updated:** 2026-01-13  
**Audience:** Mobile engineers, design system team, tech leads, QA  
**Scope:** Flutter app UI (mobile-first) with **enterprise-grade** responsiveness and adaptability across phones, tablets, foldables, desktop/web windows.

---

## 0) Executive summary

This document proposes an in-house, enterprise-grade **responsive + adaptive** UI system for Flutter that is:

- **Constraint-first** (works in split-screen, multi-window, desktop resizing, nested panes)
- **Accessible by default** (supports dynamic text scaling including Android 14+ nonlinear scaling)
- **Performance-aware** (avoids rebuild storms by design)
- **Governable** (single decision engine, token tables, testable contract)
- **Hard to misuse** (opinionated building blocks + clear extension points)

The system defines a single **runtime contract** (`AdaptiveSpec`) computed from:
- **Constraints** (actual available width/height for the current subtree)
- **Capabilities** (text scaling, reduced motion, pointer/touch, platform conventions, foldable features)

…and provides that contract via an `InheritedModel`-based scope, plus a **local-region** mechanism so nested panes can adapt independently.

---

## 1) Goals and non-goals

### 1.1 Goals

1) **Enterprise-grade consistency**
- One source of truth for breakpoints and layout tokens
- Predictable outcomes across feature teams

2) **Responsive and adaptive correctness**
- Responsive: reflow same content across constraints
- Adaptive: change patterns (navigation, panes, modality) based on constraints/capabilities

3) **Accessibility correctness**
- Support system text scaling without layout collapse
- Correctly support **nonlinear** text scaling (Android 14+), avoiding “linearizing” `TextScaler`

4) **Performance**
- No “global rebuild” on keyboard open/close unless you depend on insets
- No constant rebuilds from `InheritedWidget` identity churn

5) **Constraint-first everywhere**
- Root window adapts
- **Nested panes** adapt to their own local constraints

6) **No external adaptive packages required**
- We can adopt community packages later, but the proposal does not depend on them
- Rationale: governance + stability (e.g., `flutter_adaptive_scaffold` is discontinued on pub.dev as of early 2026)

### 1.2 Non-goals

- Replacing your visual design system (colors/typography) — this system focuses on layout/pattern adaptation
- Building a full design token pipeline
- Mandating Material vs Cupertino — this system supports a product-defined platform policy

---

## 2) Definitions (use these precisely)

### Responsive UI
Reflows **the same information architecture** to fit constraints:
- wrapping, columns, max widths, padding, spacing
- same destinations and hierarchy

Examples:
- 1 → 2 → 3 column grid
- larger page padding on wider windows
- centered form with max width

### Adaptive UI
Changes **patterns** based on constraints/capabilities:
- navigation type (bar/rail/drawer/extended rail)
- split views (single → two-pane)
- modality (bottom sheet → dialog/side sheet)
- density (touch-first → pointer-friendly)

### Window-, constraints-, capability-first
We do not “design for devices.”
We design for:
- **available size** (constraints)
- **capabilities** (input, accessibility, posture/foldables, platform conventions)

This matches modern platform guidance on adaptive layouts and window size classes.

---

## 3) Design inputs (what drives adaptation)

### 3.1 Hard constraints
- `BoxConstraints` from `LayoutBuilder` for the **actual available size** of the subtree
- safe areas: `MediaQueryData.padding` / `viewPadding`
- insets: `MediaQueryData.viewInsets` (keyboard, system overlays)

> Rule: responsiveness is driven by *constraints first*. Capabilities refine decisions.

### 3.2 Accessibility + motion
- `MediaQueryData.textScaler` (**not** `textScaleFactor`)
- `MediaQueryData.boldText` (optional signal)
- `MediaQueryData.disableAnimations` / `accessibleNavigation`

### 3.3 Input + platform conventions
- Flutter does not currently expose pointer-hover capability via `MediaQueryData`.
- Use `RendererBinding.instance.mouseTracker.mouseIsConnected` (and rebuild the scope when it changes) as a best-effort pointer capability signal.
- `defaultTargetPlatform` (or theme platform) for conventions and polish
- keyboard navigation considerations on desktop/web

### 3.4 Foldables + display features
- `MediaQueryData.displayFeatures` (hinges/cutouts/folds)
- posture inference (spanned/tabletop/flat) from display features

---

## 4) Window size classes (industry-aligned)

We use Material Design window size class thresholds (dp) and extend them for large/extra-large desktop contexts:

### 4.1 Width classes

- `compact`: `< 600`
- `medium`: `600–839`
- `expanded`: `840–1199`
- `large`: `1200–1599`
- `extraLarge`: `>= 1600`

### 4.2 Height classes

- `compact`: `< 480`
- `medium`: `480–899`
- `expanded`: `>= 900`

**Why two-axis classes?**  
Width-only systems fail in short-height scenarios (landscape phones, split-screen).

---

## 5) The contract: `AdaptiveSpec` (single source of truth)

Top-tier systems avoid scattered `if (width > …)` branches by centralizing decisions into one immutable, testable model.

### 5.1 What UI code consumes

Feature code should mostly consume:
- **Layout tokens**: padding, max widths, gutters, columns, density, min tap target
- **Pattern decisions**: suggested navigation model, pane strategy, modal strategy
- **Capabilities**: text scaler, reduce motion, pointer/touch, fold posture
- **Insets**: safe padding + keyboard insets (only where needed)

### 5.2 Split the spec to improve performance

Enterprise apps suffer when “everything rebuilds” due to one changing value (e.g., keyboard insets).  
We therefore model the spec in sub-sections and expose them via an `InheritedModel` so widgets can subscribe only to what they need.

**Core sub-specs:**
- `LayoutSpec` (size classes + layout tokens)
- `InsetsSpec` (safe areas + viewInsets)
- `TextSpec` (TextScaler + text policy signals)
- `MotionSpec`
- `InputSpec`
- `PlatformSpec`
- `FoldableSpec`

---

## 6) Architecture overview

### 6.1 The components

1) **`AdaptiveSpecBuilder`**  
Pure decision engine: constraints + media + platform → spec.

2) **`AdaptiveScope`**  
Computes and provides the spec at the app root.

3) **`AdaptiveRegion`**  
Computes a **local layout spec** for a subtree (nested pane), reusing the same environment/capability spec.

4) **Tokens + policies**  
- tokens: tables mapping size classes → values
- policies: product decisions (text scale clamp, motion reduction, density, platform conventions)

5) **Opinionated building blocks**  
To prevent ad-hoc “slop,” we provide default widgets for common patterns:
- `AppPageContainer` (max width + padding + centering)
- `AdaptiveScaffold` (nav adaptation)
- `AdaptiveSplitView` (list/detail)
- `showAdaptiveModal` + `showAdaptiveSideSheet` (modal strategy)
- `AdaptiveGrid` helper
- optional: `AdaptiveToolbar`, `AdaptiveEmptyState`, etc.

### 6.2 “Minimal API surface” vs enterprise reality

A too-minimal API pushes teams to invent one-off hacks.

This proposal intentionally includes:
- A **complete baseline API** for the 90% cases
- **Extension points** (surface kinds, overrides, regions, selectors) for the 10%
- Governance rules: if you need something new, add it to the adaptive module with tests — do not branch ad-hoc in features.

---

## 7) Correct text scaling (must be modern)

### 7.1 Why this matters
Flutter’s `TextScaler` exists to support **nonlinear** font scaling (Android 14+).  
Any approach that converts `TextScaler` into a single linear factor (e.g., `textScaler.scale(1.0)`) is not future-proof and can produce incorrect results.

### 7.2 Policy-based clamping (optional, product decision)
Some enterprise apps choose to clamp text scaling to preserve layout stability.

If you clamp:
- Do it via `TextScaler.clamp` (preserves nonlinear scaling)  
- Or `MediaQuery.withClampedTextScaling` (which uses `TextScaler.clamp` internally)

> Important: clamping is a UX/accessibility policy decision. Prefer **no clamp** unless product requires it, and involve accessibility stakeholders.

---

## 8) Responsive tokens (what the spec should provide)

### 8.1 Stepwise padding (not percentage padding)
Percent-based padding produces strange results on ultra-wide windows.
Use stable, stepwise padding by width class:
- compact: 16
- medium: 24
- expanded: 32
- large: 40
- extraLarge: 48

### 8.2 Max content width (readability)
For text-heavy pages and forms:
- medium+: clamp content width (e.g., 600–720 for forms, 720–960 for dashboards)

This prevents unreadable line lengths and “wall of text” layouts.

### 8.3 Grid columns from content width (not screen width)
Compute columns from content width using a min tile width and gutter; clamp to safe range.

### 8.4 Density and minimum targets
- touch: 48dp min tap target (recommended)
- pointer-heavy: may reduce to 40–44dp depending on accessibility policy  
Expose this as `spec.layout.minTapTarget`.

---

## 9) Adaptive patterns (what changes across sizes)

### 9.1 Navigation strategy (Material-aligned)
Recommended defaults:
- compact: navigation bar (bottom)
- medium/expanded: navigation rail (optionally extended rail)
- large/extraLarge: extended rail or navigation drawer (persistent)

Material guidance is evolving (e.g., “expressive update” notes around drawers). We support both:
- **extended navigation rail**
- **navigation drawer** (standard/modal)  
…and choose via `NavigationPolicy` rather than hardcoding.

### 9.2 List-detail (two-pane)
- compact: navigate to detail
- expanded+: list and detail side-by-side  
Avoid placing key UI under fold hinges if spanned.

### 9.3 Modality strategy
- compact: bottom sheet
- medium+: dialog or side sheet
- extraLarge: optional third pane / side sheet patterns (cap at 3 panes)

### 9.4 Height-class adaptations
Height compact (short windows):
- reduce stacked toolbars
- avoid persistent multi-row app bars
- prefer collapsible patterns and scrolling

---

## 10) Foldables, display features, and posture

Minimum enterprise support:
- treat hinges/cutouts as **avoid zones** for tappable controls and critical content
- enable two-pane layout when the window is spanned

Recommended support:
- infer a `DisplayPosture`
- provide `hingeRect` + `hingeAxis` to layout helpers
- in split view, avoid placing dividers and interactive controls under hinge

---

## 11) Performance and correctness at scale

### 11.1 Avoid rebuild storms
- Keyboard insets (`viewInsets`) change frequently.
- If every widget depends on “the whole spec,” the whole app rebuilds on keyboard open.

Mitigation:
- Provide spec via `InheritedModel` and let widgets subscribe only to `layout` or `text`, etc.
- Teach teams to prefer `context.adaptiveLayout` over `context.adaptive` for most layout code.

### 11.2 Value equality (don’t notify on identity)
`AdaptiveSpec` and sub-specs must implement **value equality** so the scope only notifies when values truly change.

### 11.3 Local regions (nested constraints)
A global “window spec” is not enough for resizable panels, split panes, inspectors, etc.  
`AdaptiveRegion` enables subtree adaptation using its own constraints.

---

## 12) Testing and governance (enterprise expectations)

### 12.1 Contract tests (unit)
- size class boundary conditions
- token table outputs
- nav policy selection
- modal policy selection
- grid column math
- text scale policy (including clamp behavior)

### 12.2 Golden matrix (widget)
At minimum:
- compact + normal text
- compact + large text
- expanded + normal text
- expanded + large text

### 12.3 Governance rules
- No feature-level ad-hoc breakpoints
- Add new behavior via tokens/policies in the adaptive module
- Any new adaptive logic must include tests and documentation
- Keep the system versioned as a contract (change log + migration notes)

---

## 13) Deliverables (what “done” looks like)

Minimum to ship:
- `AdaptiveSpec` (+ sub-specs), size classes
- `AdaptiveSpecBuilder`
- `AdaptiveScope` + `context` extensions
- `AdaptiveRegion`
- `AppPageContainer`
- `showAdaptiveModal`
- unit tests for builder + thresholds
- debug overlay (dev-only)

Recommended for completeness:
- `AdaptiveScaffold`
- `AdaptiveSplitView`
- side sheet support for large/extraLarge
- foldable posture inference helpers

---

## 14) References (primary sources)

(Include these links in your internal docs repo.)

- Flutter `MediaQuery.withClampedTextScaling` API: https://api.flutter.dev/flutter/widgets/MediaQuery/withClampedTextScaling.html  
- Flutter `TextScaler` and `TextScaler.clamp`: https://api.flutter.dev/flutter/painting/TextScaler-class.html  
- Flutter breaking change: deprecate `textScaleFactor` in favor of `TextScaler`: https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor  
- Flutter `MediaQuery` property-specific accessors (`sizeOf`, `paddingOf`, etc.): https://api.flutter.dev/flutter/widgets/MediaQuery-class.html  
- Flutter `InheritedModel` API: https://api.flutter.dev/flutter/widgets/InheritedModel-class.html  
- Material Design window size classes: https://m3.material.io/foundations/layout/applying-layout/window-size-classes  
- Material Design navigation rail: https://m3.material.io/components/navigation-rail/overview  
- Material Design navigation drawer: https://m3.material.io/components/navigation-drawer  
- `flutter_adaptive_scaffold` discontinued notice (pub.dev docs): https://pub.dev/documentation/flutter_adaptive_scaffold/latest/  

---
