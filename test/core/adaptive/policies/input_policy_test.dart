import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/policies/input_policy.dart';

void main() {
  group('InputPolicy.standard', () {
    const policy = InputPolicy.standard();

    testWidgets('derives mode from platform and hover capability', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox.shrink());

      final hoverEnabled =
          RendererBinding.instance.mouseTracker.mouseIsConnected;

      for (final platform in TargetPlatform.values) {
        final spec = policy.derive(
          media: const MediaQueryData(),
          platform: platform,
        );

        expect(spec.pointerHoverEnabled, hoverEnabled);

        final expectedMode = switch (platform) {
          TargetPlatform.android || TargetPlatform.iOS =>
            hoverEnabled ? InputMode.mixed : InputMode.touch,
          _ => hoverEnabled ? InputMode.pointer : InputMode.mixed,
        };

        expect(spec.mode, expectedMode);
      }
    });
  });
}
