import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  Widget wrapSized(Widget child, {required Size size, required TextScaler textScaler}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(size: size, textScaler: textScaler),
        child: Scaffold(
          body: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  testWidgets('blocks interaction immediately while not ready', (tester) async {
    final ready = ValueNotifier<bool>(false);
    var tapCount = 0;

    await tester.pumpWidget(
      wrap(
        AppStartupGate(
          listenable: ready,
          isReady: () => ready.value,
          overlayBuilder: (_) => const AppStartupOverlay(title: 'Test'),
          child: ElevatedButton(
            onPressed: () => tapCount++,
            child: const Text('Tap'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(AppStartupGate),
        matching: find.byType(ModalBarrier),
      ),
      findsOneWidget,
    );
    expect(find.byType(PopScope), findsOneWidget);
    expect(find.byType(AppDotWave), findsNothing);

    await tester.tap(find.text('Tap'), warnIfMissed: false);
    await tester.pump();

    expect(tapCount, 0);
    ready.dispose();
  });

  testWidgets('shows overlay only after showDelay when still not ready',
      (tester) async {
    final ready = ValueNotifier<bool>(false);

    await tester.pumpWidget(
      wrap(
        AppStartupGate(
          listenable: ready,
          isReady: () => ready.value,
          overlayBuilder: (_) => const AppStartupOverlay(title: 'Test'),
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppDotWave), findsNothing);

    await tester.pump(const Duration(milliseconds: 199));
    expect(find.byType(AppDotWave), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(AppDotWave), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppStartupGate),
        matching: find.byType(ModalBarrier),
      ),
      findsNWidgets(2),
    );
    ready.dispose();
  });

  testWidgets('removes backdrop and cancels delayed overlay when ready early',
      (tester) async {
    final ready = ValueNotifier<bool>(false);
    var tapCount = 0;

    await tester.pumpWidget(
      wrap(
        AppStartupGate(
          listenable: ready,
          isReady: () => ready.value,
          overlayBuilder: (_) => const AppStartupOverlay(title: 'Test'),
          child: ElevatedButton(
            onPressed: () => tapCount++,
            child: const Text('Tap'),
          ),
        ),
      ),
    );
    await tester.pump();

    ready.value = true;
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(AppStartupGate),
        matching: find.byType(ModalBarrier),
      ),
      findsNothing,
    );
    expect(find.byType(AppDotWave), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppDotWave), findsNothing);

    await tester.tap(find.text('Tap'));
    await tester.pump();

    expect(tapCount, 1);
    ready.dispose();
  });

  testWidgets('startup overlay does not overflow on small screens', (tester) async {
    await tester.pumpWidget(
      wrapSized(
        const AppStartupOverlay(title: 'Mobile Core Kit'),
        size: const Size(200, 120),
        textScaler: const TextScaler.linear(3.0),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
