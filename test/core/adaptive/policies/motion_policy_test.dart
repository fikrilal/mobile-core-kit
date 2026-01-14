import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/policies/motion_policy.dart';

void main() {
  group('MotionPolicy.standard', () {
    const policy = MotionPolicy.standard();

    test('reduceMotion is false when animations and navigation are enabled', () {
      const media = MediaQueryData(
        disableAnimations: false,
        accessibleNavigation: false,
      );

      expect(policy.derive(media: media).reduceMotion, false);
    });

    test('reduceMotion is true when animations are disabled', () {
      const media = MediaQueryData(
        disableAnimations: true,
        accessibleNavigation: false,
      );

      expect(policy.derive(media: media).reduceMotion, true);
    });

    test('reduceMotion is true when accessible navigation is enabled', () {
      const media = MediaQueryData(
        disableAnimations: false,
        accessibleNavigation: true,
      );

      expect(policy.derive(media: media).reduceMotion, true);
    });

    test('reduceMotion is true when both signals are present', () {
      const media = MediaQueryData(
        disableAnimations: true,
        accessibleNavigation: true,
      );

      expect(policy.derive(media: media).reduceMotion, true);
    });
  });
}

