import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';

Future<BuildContext> _pumpHost(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  late BuildContext context;

  await tester.pumpWidget(
    MaterialApp(
      home: AdaptiveScope(
        navigationPolicy: const NavigationPolicy.standard(),
        child: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return context;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showAdaptiveModal', () {
    testWidgets('uses a bottom sheet on compact widths', (tester) async {
      final context = await _pumpHost(tester, const Size(500, 800));

      final result = showAdaptiveModal<String>(
        context: context,
        builder: (context) {
          return Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop('ok'),
              child: const Text('Close'),
            ),
          );
        },
      );

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(await result, 'ok');
    });

    testWidgets('uses a dialog on medium+ widths', (tester) async {
      final context = await _pumpHost(tester, const Size(800, 800));

      final result = showAdaptiveModal<String>(
        context: context,
        builder: (context) {
          return Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop('ok'),
              child: const Text('Close'),
            ),
          );
        },
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(await result, 'ok');
    });
  });

  group('showAdaptiveSideSheet', () {
    testWidgets('falls back to modal strategy on compact widths', (
      tester,
    ) async {
      final context = await _pumpHost(tester, const Size(500, 800));

      final result = showAdaptiveSideSheet<String>(
        context: context,
        builder: (context) {
          return Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop('ok'),
              child: const Text('Close'),
            ),
          );
        },
      );

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(await result, 'ok');
    });

    testWidgets('shows a side sheet on medium+ widths', (tester) async {
      final context = await _pumpHost(tester, const Size(800, 800));

      final result = showAdaptiveSideSheet<String>(
        context: context,
        builder: (context) {
          return Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop('ok'),
              child: const Text('Close'),
            ),
          );
        },
      );

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(await result, 'ok');
    });
  });
}

