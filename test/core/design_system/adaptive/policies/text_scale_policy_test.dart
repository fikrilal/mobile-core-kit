import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/text_scale_policy.dart';

void main() {
  group('TextScalePolicy', () {
    test('unclamped preserves incoming scaler behavior', () {
      final incoming = TextScaler.linear(1.5);
      const policy = TextScalePolicy.unclamped();

      final applied = policy.apply(incoming);

      expect(applied.scale(10), incoming.scale(10));
      expect(applied.scale(16), incoming.scale(16));
    });

    test('clamp enforces maxScaleFactor via TextScaler.clamp', () {
      final incoming = TextScaler.linear(3.0);
      const policy = TextScalePolicy.clamp(
        minScaleFactor: 1.0,
        maxScaleFactor: 2.0,
      );

      final applied = policy.apply(incoming);

      expect(applied.scale(10), 20);
      expect(applied.scale(16), 32);
    });

    test('clamp enforces minScaleFactor via TextScaler.clamp', () {
      final incoming = TextScaler.linear(0.5);
      const policy = TextScalePolicy.clamp(
        minScaleFactor: 1.0,
        maxScaleFactor: 2.0,
      );

      final applied = policy.apply(incoming);

      expect(applied.scale(10), 10);
      expect(applied.scale(16), 16);
    });

    test('clamp asserts maxScaleFactor >= minScaleFactor', () {
      expect(
        () => TextScalePolicy.clamp(minScaleFactor: 2.0, maxScaleFactor: 1.0),
        throwsAssertionError,
      );
    });
  });
}
