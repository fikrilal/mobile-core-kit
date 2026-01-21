// Utilities for interpreting foldable display features.
//
// Flutter exposes foldable/dual-screen signals via `MediaQueryData.displayFeatures`.
// This file normalizes those signals into the simpler `FoldableSpec` contract.
import 'dart:ui' show DisplayFeature, DisplayFeatureState, Rect;

import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/foldables/display_posture.dart';

/// Derives a coarse foldable posture from raw display features.
DisplayPosture postureForDisplayFeatures(List<DisplayFeature> features) {
  final hasFeatures = features.isNotEmpty;
  if (!hasFeatures) return DisplayPosture.flat;

  final isTabletop = features.any(
    (f) => f.state == DisplayFeatureState.postureHalfOpened,
  );
  if (isTabletop) return DisplayPosture.tabletop;

  final isSpanned = features.any((f) => f.bounds.shortestSide > 0);
  if (isSpanned) return DisplayPosture.spanned;

  return DisplayPosture.unknown;
}

/// Returns the first hinge-like rect from the given display features, if any.
Rect? hingeRectForDisplayFeatures(List<DisplayFeature> features) {
  for (final feature in features) {
    final isHingeLike =
        feature.bounds.shortestSide > 0 ||
        feature.state == DisplayFeatureState.postureHalfOpened;
    if (isHingeLike) return feature.bounds;
  }
  return null;
}

/// Derives hinge axis from the given hinge rect.
///
/// Returns `null` for empty/degenerate rects.
Axis? hingeAxisForRect(Rect? rect) {
  if (rect == null) return null;
  if (rect.width == 0 && rect.height == 0) return null;
  return rect.width >= rect.height ? Axis.horizontal : Axis.vertical;
}

/// Returns true when any display feature indicates a spanned layout.
bool isSpannedByDisplayFeatures(List<DisplayFeature> features) {
  return features.any((f) => f.bounds.shortestSide > 0);
}
