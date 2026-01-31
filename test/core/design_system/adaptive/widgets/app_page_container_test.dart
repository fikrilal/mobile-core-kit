import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPageContainer', () {
    testWidgets('applies safe padding + adaptive page padding', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600); // medium
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(
            tester.view,
          ).copyWith(padding: const EdgeInsets.only(top: 10)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveScope(
              navigationPolicy: const NavigationPolicy.none(),
              child: const AppPageContainer(child: SizedBox.shrink()),
            ),
          ),
        ),
      );
      await tester.pump();

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.fromLTRB(24, 10, 24, 0));
    });

    testWidgets('constrains content width for non-compact surfaces', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600); // medium
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AdaptiveScope(
              navigationPolicy: const NavigationPolicy.none(),
              child: const AppPageContainer(
                surface: SurfaceKind.settings,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final constrained = tester.widget<ConstrainedBox>(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.maxWidth == 720, // settings surface on medium+
        ),
      );

      expect(constrained.constraints.maxWidth, 720);
    });
  });
}
