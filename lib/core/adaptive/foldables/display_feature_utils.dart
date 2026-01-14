import 'dart:ui' show DisplayFeature, DisplayFeatureState, Rect;

import 'package:flutter/widgets.dart';

import 'display_posture.dart';

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

Rect? hingeRectForDisplayFeatures(List<DisplayFeature> features) {
  for (final feature in features) {
    final isHingeLike =
        feature.bounds.shortestSide > 0 ||
        feature.state == DisplayFeatureState.postureHalfOpened;
    if (isHingeLike) return feature.bounds;
  }
  return null;
}

Axis? hingeAxisForRect(Rect? rect) {
  if (rect == null) return null;
  if (rect.width == 0 && rect.height == 0) return null;
  return rect.width >= rect.height ? Axis.horizontal : Axis.vertical;
}

bool isSpannedByDisplayFeatures(List<DisplayFeature> features) {
  return features.any((f) => f.bounds.shortestSide > 0);
}
