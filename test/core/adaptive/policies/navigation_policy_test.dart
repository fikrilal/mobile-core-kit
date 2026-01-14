import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';

void main() {
  group('NavigationPolicy.standard', () {
    const policy = NavigationPolicy.standard();
    const input = InputSpec(mode: InputMode.touch, pointerHoverEnabled: false);

    test('maps width classes to navigation kinds', () {
      expect(
        policy
            .derive(
              widthClass: WindowWidthClass.compact,
              platform: TargetPlatform.android,
              input: input,
            )
            .kind,
        NavigationKind.bar,
      );

      expect(
        policy
            .derive(
              widthClass: WindowWidthClass.medium,
              platform: TargetPlatform.android,
              input: input,
            )
            .kind,
        NavigationKind.rail,
      );

      expect(
        policy
            .derive(
              widthClass: WindowWidthClass.expanded,
              platform: TargetPlatform.android,
              input: input,
            )
            .kind,
        NavigationKind.rail,
      );

      expect(
        policy
            .derive(
              widthClass: WindowWidthClass.large,
              platform: TargetPlatform.android,
              input: input,
            )
            .kind,
        NavigationKind.extendedRail,
      );

      expect(
        policy
            .derive(
              widthClass: WindowWidthClass.extraLarge,
              platform: TargetPlatform.android,
              input: input,
            )
            .kind,
        NavigationKind.standardDrawer,
      );
    });
  });

  group('NavigationPolicy.none', () {
    const policy = NavigationPolicy.none();
    const input = InputSpec(mode: InputMode.touch, pointerHoverEnabled: false);

    test('always returns NavigationKind.none', () {
      for (final widthClass in WindowWidthClass.values) {
        expect(
          policy
              .derive(
                widthClass: widthClass,
                platform: TargetPlatform.android,
                input: input,
              )
              .kind,
          NavigationKind.none,
        );
      }
    });
  });
}
