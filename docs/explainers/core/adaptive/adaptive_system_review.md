# Adaptive/Responsive System Review

**Date:** 2026-01-13  
**Reviewer:** Copilot CLI  
**Module:** `lib/core/design_system/adaptive/`  
**Reference:** `docs/explainers/core/adaptive/enterprise_responsive_adaptive_proposal.md`

---

## Executive Summary

The adaptive/responsive system implementation is **well-aligned with the enterprise proposal** and demonstrates solid architectural decisions. The system is constraint-first, performance-conscious, and accessibility-aware.

**Overall Grade: A-**

The main gaps are test coverage (~40% of proposed contract tests) and minor polish items (barrel file, unused policies).

---

## Follow-up Status (2026-01-14)

The high/medium priority gaps called out in this review have been addressed:

- ✅ Added `lib/core/design_system/adaptive/adaptive.dart` barrel export.
- ✅ Added unit tests for tokens (`grid_tokens`, `layout_tokens`, `surface_tokens`).
- ✅ Added unit tests for `MotionPolicy`, `InputPolicy`, and `FoldableSpec.fromDisplayFeatures`.
- ✅ Extracted `ModalPolicy` and wired `showAdaptiveModal` / `showAdaptiveSideSheet` to use it (configurable via `AdaptiveScope.modalPolicy`).
- ✅ Wired `PlatformPolicy` into `AdaptiveScope` / `AdaptiveSpecBuilder` (no longer unused).
- ✅ Added widget tests for `AdaptiveScope`, `AdaptiveRegion`, and `AdaptiveModel` aspect filtering.
- ✅ Implemented `AdaptiveOverrides` (governed escape hatch) + widget tests.
- ✅ Added height-class adaptation guidance (`docs/explainers/core/adaptive/height_class_adaptation.md`).
- ✅ Added a golden matrix for a key surface (settings) under `test/core/adaptive/goldens/`.
- ✅ Added widget tests for core adaptive widgets:
  - `AppPageContainer`
  - `AdaptiveScaffold`
  - `AdaptiveSplitView`
  - `showAdaptiveModal` / `showAdaptiveSideSheet`

---

## 1. Implementation Strengths

| Area | Status | Notes |
|------|--------|-------|
| **Core Architecture** | ✅ Excellent | `InheritedModel` with aspect-based subscriptions prevents rebuild storms |
| **Size Classes** | ✅ Complete | Material-aligned breakpoints (compact/medium/expanded/large/extraLarge for width, compact/medium/expanded for height) |
| **Constraint-First** | ✅ Complete | Uses `LayoutBuilder` + constraints, not `MediaQuery.size` |
| **TextScaler** | ✅ Modern | Uses `TextScaler.clamp` (preserves nonlinear scaling for Android 14+) |
| **Policies** | ✅ Well-structured | Sealed classes for `TextScalePolicy`, `NavigationPolicy`, `MotionPolicy`, `InputPolicy` |
| **Tokens** | ✅ Complete | Layout, grid, surface, navigation tokens all present |
| **AdaptiveRegion** | ✅ Implemented | Local subtree adaptation for nested panes |
| **Foldables** | ✅ Implemented | Display features, posture detection, hinge awareness |
| **Core Widgets** | ✅ Complete | `AppPageContainer`, `AdaptiveScaffold`, `AdaptiveSplitView`, `showAdaptiveModal`, `showAdaptiveSideSheet`, `AdaptiveGrid`, `MinTapTarget` |
| **Debug Tooling** | ✅ Present | Debug overlay and banner |
| **Value Equality** | ✅ Correct | All specs implement `==` and `hashCode` properly |

---

## 2. Gaps & Recommendations

### 2.1 Missing Tests (High Priority)

The proposal calls for comprehensive contract tests (§12), but current coverage is limited.

**Existing Tests:**
- `size_classes_test.dart` — boundary conditions ✅
- `text_scale_policy_test.dart` — clamp behavior ✅
- `navigation_policy_test.dart` — width class → nav kind mapping ✅
- `adaptive_spec_builder_test.dart` — basic spec computation + equality ✅

**Missing Test Coverage (original review):**

| Missing Test | Priority | Proposal Section |
|--------------|----------|------------------|
| Grid token computation (`GridTokens.computeColumns`) | High | §12.1 |
| Surface token resolution (`SurfaceTokenTable.resolve`) | High | §12.1 |
| Layout token outputs (`LayoutTokens.pagePadding`, `gutter`, `minTapTarget`) | High | §12.1 |
| `AdaptiveScope` widget tests | High | §12.2 |
| `AdaptiveRegion` widget tests | High | §12.2 |
| `AdaptiveModel.updateShouldNotifyDependent` aspect filtering | High | §11.1 |
| `AppPageContainer` widget tests | Medium | §12.2 |
| `AdaptiveSplitView` (including foldable scenarios) | Medium | §12.2 |
| `showAdaptiveModal` / `showAdaptiveSideSheet` | Medium | §12.2 |
| `AdaptiveScaffold` navigation switching | Medium | §12.2 |
| `MotionPolicy` / `InputPolicy` derivation | Medium | §12.1 |
| `FoldableSpec.fromDisplayFeatures` | Medium | §12.1 |

**Golden Matrix (Proposal §12.2):**
The proposal recommends golden tests for key pages at:
- compact + 1.0x text
- compact + 2.0x text
- expanded + 1.0x text
- expanded + 2.0x text

Implemented (see `test/core/adaptive/goldens/`).

---

### 2.2 Missing Exports / Barrel File

There is no `adaptive.dart` barrel file for clean imports. Feature code currently requires multiple import statements:

```dart
// Current (verbose)
import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';

// Desired (clean)
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';
```

**Recommendation:** Create `lib/core/design_system/adaptive/adaptive.dart` that exports all public APIs.

**Status:** ✅ Implemented (`lib/core/design_system/adaptive/adaptive.dart`)

---

### 2.3 Modal Policy (Proposal §9.3)

The proposal mentions modal strategy decisions should be policy-driven. Currently, `showAdaptiveModal` hardcodes the decision:

```dart
if (layout.widthClass == WindowWidthClass.compact) {
  return showModalBottomSheet<T>(...);
}
return showDialog<T>(...);
```

**Recommendation:** Consider extracting a `ModalPolicy` sealed class for consistency with other policies. This would allow:
- Custom modal strategies per product
- Testable modal decisions
- Potential medium-width variations (e.g., dialog vs side sheet)

**Status:** ✅ Implemented (`lib/core/design_system/adaptive/policies/modal_policy.dart`; configurable via `AdaptiveScope.modalPolicy`)

---

### 2.4 PlatformPolicy Not Used

`policies/platform_policy.dart` exists but is not wired into `AdaptiveScope` or `AdaptiveSpecBuilder`. The builder directly uses `defaultTargetPlatform`:

```dart
// In AdaptiveSpecBuilder.build()
platform: PlatformSpec(platform: platform),
```

**Recommendation:** Either:
1. Wire `PlatformPolicy` into the scope/builder for consistency
2. Remove the unused class to reduce confusion

**Status:** ✅ Implemented (wired into `lib/core/design_system/adaptive/adaptive_scope.dart` and `lib/core/design_system/adaptive/adaptive_spec_builder.dart`)

---

### 2.5 AdaptiveOverrides (Proposal §2.3)

The implementation guide mentions `AdaptiveOverrides` as an extension point for per-screen overrides (rare, must be reviewed). This is not implemented.

**Recommendation:** Consider implementing if feature teams request per-screen escapes. Low priority unless explicitly needed.

---

### 2.6 Height-Class Adaptations (Proposal §9.4)

The proposal mentions compact height adaptations:
- Reduce stacked toolbars
- Avoid persistent multi-row app bars
- Prefer collapsible patterns and scrolling

The tokens and spec capture `heightClass`, but no widgets currently consume it for adaptation.

**Recommendation:** Document patterns for height-class adaptation when widgets adopt them. Consider adding height-aware behavior to `AdaptiveScaffold` (e.g., collapsing app bar in compact height).

---

### 2.7 Documentation Enhancements

The README is good but could be enhanced:

| Addition | Description |
|----------|-------------|
| Complete API table | All exports with brief descriptions |
| Migration guide | For adopters integrating into existing apps |
| Troubleshooting | Common mistakes and solutions |
| Visual diagrams | Size class breakpoint visualization |

---

## 3. Action Items

### High Priority

| # | Action | Effort |
|---|--------|--------|
| 1 | ✅ Add unit tests for `GridTokens.computeColumns` | Small |
| 2 | ✅ Add unit tests for `SurfaceTokenTable.resolve` | Small |
| 3 | ✅ Add unit tests for `LayoutTokens` (all methods) | Small |
| 4 | ✅ Add widget tests for `AdaptiveScope` (aspect-based rebuilds) | Medium |
| 5 | ✅ Add widget tests for `AdaptiveRegion` (local constraints) | Medium |
| 6 | ✅ Create `adaptive.dart` barrel file | Small |

### Medium Priority

| # | Action | Effort |
|---|--------|--------|
| 7 | ✅ Add unit tests for `MotionPolicy`, `InputPolicy` | Small |
| 8 | ✅ Add unit tests for `FoldableSpec.fromDisplayFeatures` | Small |
| 9 | ✅ Add widget tests for `AppPageContainer` | Small |
| 10 | ✅ Add widget tests for `AdaptiveSplitView` | Medium |
| 11 | ✅ Add widget tests for `showAdaptiveModal` / `showAdaptiveSideSheet` | Medium |
| 12 | ✅ Add widget tests for `AdaptiveScaffold` | Medium |
| 13 | ✅ Extract `ModalPolicy` for consistency | Medium |
| 14 | ✅ Wire or remove `PlatformPolicy` | Small |

### Low Priority

| # | Action | Effort |
|---|--------|--------|
| 15 | ✅ Document height-class adaptation patterns | Small |
| 16 | ✅ Implement `AdaptiveOverrides` | Medium |
| 17 | ✅ Add golden test matrix for key surfaces | Large |
| 18 | ✅ Enhance README with API table and diagrams | Medium |

---

## 4. File Structure Validation

The current structure matches the proposal's recommended layout:

```
lib/core/design_system/adaptive/
├── adaptive.dart                  ✅
├── README.md                      ✅
├── adaptive_aspect.dart           ✅
├── adaptive_context.dart          ✅
├── adaptive_overrides.dart        ✅
├── adaptive_policies.dart         ✅
├── adaptive_region.dart           ✅
├── adaptive_scope.dart            ✅
├── adaptive_spec.dart             ✅
├── adaptive_spec_builder.dart     ✅
├── size_classes.dart              ✅
├── debug/
│   ├── adaptive_debug_banner.dart ✅
│   └── adaptive_debug_overlay.dart ✅
├── foldables/
│   ├── display_feature_utils.dart ✅
│   ├── display_posture.dart       ✅
│   └── foldable_spec.dart         ✅
├── policies/
│   ├── input_policy.dart          ✅
│   ├── modal_policy.dart          ✅
│   ├── motion_policy.dart         ✅
│   ├── navigation_policy.dart     ✅
│   ├── platform_policy.dart       ✅ (wired)
│   └── text_scale_policy.dart     ✅
├── tokens/
│   ├── grid_tokens.dart           ✅
│   ├── layout_tokens.dart         ✅
│   ├── navigation_tokens.dart     ✅
│   └── surface_tokens.dart        ✅
└── widgets/
    ├── adaptive_grid.dart         ✅
    ├── adaptive_modal.dart        ✅
    ├── adaptive_scaffold.dart     ✅
    ├── adaptive_side_sheet.dart   ✅
    ├── adaptive_split_view.dart   ✅
    ├── app_page_container.dart    ✅
    └── min_tap_target.dart        ✅
```

**Status:** File structure matches the proposal (plus additions: `adaptive.dart`, `AdaptiveOverrides`, `ModalPolicy`).

---

## 5. Test Structure Validation

Current test structure:

```
test/core/adaptive/
├── adaptive_spec_builder_test.dart  ✅
├── size_classes_test.dart           ✅
└── policies/
    ├── navigation_policy_test.dart  ✅
    └── text_scale_policy_test.dart  ✅
```

**Recommended additions (current status):**

```
test/core/adaptive/
├── tokens/
│   ├── grid_tokens_test.dart        ✅
│   ├── layout_tokens_test.dart      ✅
│   └── surface_tokens_test.dart     ✅
├── foldables/
│   └── foldable_spec_test.dart      ✅
├── policies/
│   ├── modal_policy_test.dart       ✅
│   ├── motion_policy_test.dart      ✅
│   └── input_policy_test.dart       ✅
└── widgets/
    ├── adaptive_overrides_test.dart ✅
    ├── adaptive_scope_test.dart     ✅
    ├── adaptive_region_test.dart    ✅
    ├── adaptive_model_aspect_filtering_test.dart ✅
    ├── app_page_container_test.dart ✅
    ├── adaptive_scaffold_test.dart  ✅
    ├── adaptive_split_view_test.dart ✅
    └── adaptive_modal_test.dart     ✅
```

**Golden matrix:**
- `test/core/adaptive/goldens/adaptive_settings_matrix_golden_test.dart`

---

## 6. Conclusion

The adaptive/responsive system is **production-ready** for mobile-first use cases. The architecture is sound, follows enterprise patterns, and aligns with Material Design guidelines.

**Status:** The core contract and recommended tests are in place, including a minimal golden matrix.

The system provides a solid foundation for the mobile core kit and will serve well as a starter for future projects.

---

## Appendix: Quick Reference

### Context Accessors

| Accessor | Rebuilds when | Use for |
|----------|---------------|---------|
| `context.adaptiveLayout` | layout changes | padding, columns, nav, density |
| `context.adaptiveInsets` | safe padding / keyboard changes | bottom padding, safe area |
| `context.adaptiveText` | text scaler changes | text scaling reactions |
| `context.adaptiveMotion` | reduce motion changes | animations |
| `context.adaptiveInput` | pointer/touch mode changes | hover UI, density |
| `context.adaptiveFoldable` | display features change | hinge-aware layouts |
| `context.adaptive` | anything changes | debugging, rare cases |

### Size Class Breakpoints

**Width Classes (dp):**
- `compact`: < 600
- `medium`: 600–839
- `expanded`: 840–1199
- `large`: 1200–1599
- `extraLarge`: ≥ 1600

**Height Classes (dp):**
- `compact`: < 480
- `medium`: 480–899
- `expanded`: ≥ 900
