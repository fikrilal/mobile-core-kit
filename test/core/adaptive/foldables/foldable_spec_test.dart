import 'dart:ui'
    show DisplayFeature, DisplayFeatureState, DisplayFeatureType, Rect;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/foldables/display_posture.dart';
import 'package:mobile_core_kit/core/adaptive/foldables/foldable_spec.dart';

void main() {
  group('FoldableSpec.fromDisplayFeatures', () {
    test('returns FoldableSpec.none for empty feature list', () {
      final spec = FoldableSpec.fromDisplayFeatures(const <DisplayFeature>[]);

      expect(spec, FoldableSpec.none);
      expect(spec.displayFeatures, isEmpty);
      expect(spec.posture, DisplayPosture.flat);
      expect(spec.isSpanned, isFalse);
      expect(spec.hingeRect, isNull);
      expect(spec.hingeAxis, isNull);
    });

    test('derives tabletop posture from postureHalfOpened state', () {
      final feature = _displayFeature(
        bounds: const Rect.fromLTWH(0, 0, 200, 0),
        state: DisplayFeatureState.postureHalfOpened,
      );
      final original = <DisplayFeature>[feature];

      final spec = FoldableSpec.fromDisplayFeatures(original);

      expect(spec.displayFeatures, isNot(same(original)));
      expect(spec.displayFeatures, hasLength(1));
      expect(spec.posture, DisplayPosture.tabletop);
      expect(spec.isSpanned, isFalse);
      expect(spec.hingeRect, feature.bounds);
      expect(spec.hingeAxis, Axis.horizontal);

      expect(
        () => spec.displayFeatures.add(feature),
        throwsUnsupportedError,
      );
    });

    test('derives spanned posture when any feature has non-zero thickness', () {
      final feature = _displayFeature(
        bounds: const Rect.fromLTWH(0, 0, 10, 200),
        state: DisplayFeatureState.unknown,
      );

      final spec = FoldableSpec.fromDisplayFeatures(<DisplayFeature>[feature]);

      expect(spec.posture, DisplayPosture.spanned);
      expect(spec.isSpanned, isTrue);
      expect(spec.hingeRect, feature.bounds);
      expect(spec.hingeAxis, Axis.vertical);
    });

    test('derives unknown posture when features are present but not hinge-like', () {
      final feature = _displayFeature(
        bounds: const Rect.fromLTWH(0, 0, 200, 0),
        state: DisplayFeatureState.unknown,
      );

      final spec = FoldableSpec.fromDisplayFeatures(<DisplayFeature>[feature]);

      expect(spec.posture, DisplayPosture.unknown);
      expect(spec.isSpanned, isFalse);
      expect(spec.hingeRect, isNull);
      expect(spec.hingeAxis, isNull);
    });
  });
}

DisplayFeature _displayFeature({
  required Rect bounds,
  required DisplayFeatureState state,
}) {
  // The constructor signature for DisplayFeature is part of `dart:ui` and may
  // include additional fields depending on the engine version. Keep this helper
  // centralized so tests remain easy to update if needed.
  return DisplayFeature(bounds: bounds, state: state, type: DisplayFeatureType.hinge);
}
