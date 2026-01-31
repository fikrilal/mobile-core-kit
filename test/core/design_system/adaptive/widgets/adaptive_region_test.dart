import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

void main() {
  group('AdaptiveRegion', () {
    testWidgets('overrides layout based on subtree constraints', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(900, 700);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AdaptiveSpec? root;
      AdaptiveSpec? region;

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveScope(
              navigationPolicy: const NavigationPolicy.standard(),
              child: Builder(
                builder: (context) {
                  root = context.adaptive;

                  return Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 400,
                      height: 700,
                      child: AdaptiveRegion(
                        child: Builder(
                          builder: (context) {
                            region = context.adaptive;
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(root, isNotNull);
      expect(region, isNotNull);

      expect(root!.layout.widthClass, WindowWidthClass.expanded);
      expect(root!.layout.navigation.kind, NavigationKind.rail);

      expect(region!.layout.size, const Size(400, 700));
      expect(region!.layout.widthClass, WindowWidthClass.compact);
      expect(region!.layout.navigation.kind, NavigationKind.none);

      expect(region!.insets, root!.insets);
      expect(region!.text, root!.text);
      expect(region!.motion, root!.motion);
      expect(region!.input, root!.input);
      expect(region!.platform, root!.platform);
      expect(region!.foldable, root!.foldable);
    });
  });
}
