import 'dart:ui' show DisplayFeature, Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/design_system/adaptive/foldables/display_feature_utils.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/foldables/display_posture.dart';

/// Foldable/dual-screen contract derived from `MediaQueryData.displayFeatures`.
///
/// The spec is value-based and safe to store in `AdaptiveSpec`. Feature code
/// should consume it via `context.adaptiveFoldable`.
@immutable
class FoldableSpec {
  const FoldableSpec({
    required this.displayFeatures,
    required this.posture,
    required this.isSpanned,
    this.hingeRect,
    this.hingeAxis,
  });

  static const FoldableSpec none = FoldableSpec(
    displayFeatures: <DisplayFeature>[],
    posture: DisplayPosture.flat,
    isSpanned: false,
  );

  final List<DisplayFeature> displayFeatures;
  final DisplayPosture posture;
  final bool isSpanned;
  final Rect? hingeRect;
  final Axis? hingeAxis;

  /// Builds a normalized spec from raw display features.
  factory FoldableSpec.fromDisplayFeatures(List<DisplayFeature> features) {
    if (features.isEmpty) return FoldableSpec.none;

    final list = List<DisplayFeature>.unmodifiable(features);
    final posture = postureForDisplayFeatures(list);
    final hingeRect = hingeRectForDisplayFeatures(list);
    final hingeAxis = hingeAxisForRect(hingeRect);
    final isSpanned = isSpannedByDisplayFeatures(list);

    return FoldableSpec(
      displayFeatures: list,
      posture: posture,
      isSpanned: isSpanned,
      hingeRect: hingeRect,
      hingeAxis: hingeAxis,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FoldableSpec &&
      listEquals(other.displayFeatures, displayFeatures) &&
      other.posture == posture &&
      other.isSpanned == isSpanned &&
      other.hingeRect == hingeRect &&
      other.hingeAxis == hingeAxis;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(displayFeatures),
    posture,
    isSpanned,
    hingeRect,
    hingeAxis,
  );
}
