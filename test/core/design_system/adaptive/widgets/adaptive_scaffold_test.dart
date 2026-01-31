import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive.dart';

Future<void> _pumpScaffold(
  WidgetTester tester, {
  required Size size,
  required NavigationPolicy navigationPolicy,
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
        navigationPolicy: navigationPolicy,
        child: AdaptiveScaffold(
          destinations: const [
            AdaptiveScaffoldDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            AdaptiveScaffoldDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          body: const SizedBox.shrink(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveScaffold', () {
    testWidgets('renders a NavigationBar on compact widths', (tester) async {
      await _pumpScaffold(
        tester,
        size: const Size(500, 800),
        navigationPolicy: const NavigationPolicy.standard(),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders a NavigationRail on medium widths', (tester) async {
      await _pumpScaffold(
        tester,
        size: const Size(800, 800),
        navigationPolicy: const NavigationPolicy.standard(),
      );

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders an extended NavigationRail on large widths', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        size: const Size(1300, 800),
        navigationPolicy: const NavigationPolicy.standard(),
      );

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders a persistent NavigationDrawer on extraLarge widths', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        size: const Size(1700, 800),
        navigationPolicy: const NavigationPolicy.standard(),
      );

      expect(find.byType(NavigationDrawer), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('renders a plain Scaffold when navigation is disabled', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        size: const Size(800, 800),
        navigationPolicy: const NavigationPolicy.none(),
      );

      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
