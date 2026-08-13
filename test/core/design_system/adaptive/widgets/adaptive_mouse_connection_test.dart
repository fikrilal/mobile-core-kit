import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

void main() {
  group('AdaptiveScope input mode derivation', () {
    testWidgets(
      'InputSpec mode is derived at build time, not from live mouse events',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        InputMode? capturedMode;

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromView(tester.view),
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
                        capturedMode = context.adaptive.input.mode;
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(capturedMode, InputMode.touch);

        // A mouse connecting mid-session must NOT change the mode by itself:
        // the mode is recomputed on the next normal rebuild, not on a mouse
        // tracker event (there is deliberately no mouse-connection listener).
        final tracker = RendererBinding.instance.mouseTracker;
        tracker.updateWithEvent(
          PointerAddedEvent(
            position: const Offset(100, 100),
            device: 42,
            kind: PointerDeviceKind.mouse,
          ),
          null,
        );
        await tester.pump();

        expect(tracker.mouseIsConnected, isTrue);
        expect(capturedMode, InputMode.touch);
      },
    );

    testWidgets('InputSpec mode updates on a normal rebuild', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1000, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      InputMode? capturedMode;

      Future<void> pumpScope() async {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData.fromView(tester.view),
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
                        capturedMode = context.adaptive.input.mode;
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      await pumpScope();
      expect(capturedMode, InputMode.touch);

      // Connect a mouse, then rebuild (e.g. a theme/route change). The mode
      // is recomputed from the current mouse state on the rebuild.
      final tracker = RendererBinding.instance.mouseTracker;
      tracker.updateWithEvent(
        PointerAddedEvent(
          position: const Offset(100, 100),
          device: 42,
          kind: PointerDeviceKind.mouse,
        ),
        null,
      );
      await tester.pump();

      // Rebuild with a different policy instance to force the scope to re-run.
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData.fromView(tester.view),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 500,
                height: 400,
                child: AdaptiveScope(
                  navigationPolicy: const NavigationPolicy.none(),
                  modalPolicy: const ModalPolicy.standard(),
                  child: Builder(
                    builder: (context) {
                      capturedMode = context.adaptive.input.mode;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tracker.mouseIsConnected, isTrue);
      expect(capturedMode, InputMode.mixed);
    });
  });
}
