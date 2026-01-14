import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';

Future<void> _pumpShell(
  WidgetTester tester, {
  required Size size,
  required Widget child,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: AdaptiveScope(
        navigationPolicy: const NavigationPolicy.standard(),
        child: child,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveOverrides', () {
    testWidgets('does not change navigation when absent', (tester) async {
      await _pumpShell(
        tester,
        size: const Size(800, 800), // medium -> rail
        child: AdaptiveScaffold(
          destinations: const [
            AdaptiveScaffoldDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          body: const SizedBox.shrink(),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('can override navigation policy for a subtree', (tester) async {
      await _pumpShell(
        tester,
        size: const Size(800, 800), // medium -> rail by default
        child: AdaptiveOverrides(
          navigationPolicy: const NavigationPolicy.none(),
          child: AdaptiveScaffold(
            destinations: const [
              AdaptiveScaffoldDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

