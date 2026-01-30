import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

void main() {
  group('AdaptiveScope', () {
    testWidgets('uses constraints over MediaQuery size', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1000, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AdaptiveSpec? spec;
      double? clampedScale;

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(textScaler: TextScaler.linear(3.0)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 500,
                height: 400,
                child: AdaptiveScope(
                  navigationPolicy: const NavigationPolicy.none(),
                  child: Builder(
                    builder: (context) {
                      spec = context.adaptive;
                      clampedScale = MediaQuery.of(
                        context,
                      ).textScaler.scale(1.0);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(spec, isNotNull);
      expect(clampedScale, isNotNull);

      expect(spec!.layout.size, const Size(500, 400));
      expect(spec!.layout.widthClass, WindowWidthClass.compact);
      expect(spec!.layout.heightClass, WindowHeightClass.compact);
      expect(spec!.layout.orientation, Orientation.landscape);
      expect(spec!.layout.navigation.kind, NavigationKind.none);

      expect(clampedScale, 2.0);
      expect(spec!.text.textScaler.scale(1.0), 2.0);
    });

    testWidgets(
      'falls back to MediaQuery size when constraints are unbounded',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 600);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        AdaptiveSpec? spec;

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromView(tester.view),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: UnconstrainedBox(
                child: AdaptiveScope(
                  navigationPolicy: const NavigationPolicy.none(),
                  child: Builder(
                    builder: (context) {
                      spec = context.adaptive;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        expect(spec, isNotNull);

        expect(spec!.layout.size, const Size(800, 600));
        expect(spec!.layout.widthClass, WindowWidthClass.medium);
        expect(spec!.layout.heightClass, WindowHeightClass.medium);
      },
    );
  });
}
