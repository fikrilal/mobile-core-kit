import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive.dart';

Future<void> _pumpSplitView(
  WidgetTester tester, {
  required Size size,
  required AdaptiveSplitView splitView,
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
        navigationPolicy: const NavigationPolicy.none(),
        child: splitView,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveSplitView', () {
    const masterKey = Key('master');
    const detailKey = Key('detail');
    const placeholderKey = Key('placeholder');

    testWidgets('shows master only on compact widths by default', (
      tester,
    ) async {
      await _pumpSplitView(
        tester,
        size: const Size(500, 800),
        splitView: const AdaptiveSplitView(
          hasSelection: true,
          master: SizedBox(key: masterKey),
          detail: SizedBox(key: detailKey),
        ),
      );

      expect(find.byKey(masterKey), findsOneWidget);
      expect(find.byKey(detailKey), findsNothing);
    });

    testWidgets('shows detail on compact when showDetailInCompact is enabled', (
      tester,
    ) async {
      await _pumpSplitView(
        tester,
        size: const Size(500, 800),
        splitView: const AdaptiveSplitView(
          hasSelection: true,
          showDetailInCompact: true,
          master: SizedBox(key: masterKey),
          detail: SizedBox(key: detailKey),
        ),
      );

      expect(find.byKey(masterKey), findsNothing);
      expect(find.byKey(detailKey), findsOneWidget);
    });

    testWidgets('shows placeholder when no selection on two-pane layouts', (
      tester,
    ) async {
      await _pumpSplitView(
        tester,
        size: const Size(900, 800), // expanded
        splitView: const AdaptiveSplitView(
          hasSelection: false,
          master: SizedBox(key: masterKey),
          detail: SizedBox(key: detailKey),
          detailPlaceholder: SizedBox(key: placeholderKey),
        ),
      );

      expect(find.byKey(masterKey), findsOneWidget);
      expect(find.byKey(detailKey), findsNothing);
      expect(find.byKey(placeholderKey), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('shows master and detail when selected on two-pane layouts', (
      tester,
    ) async {
      await _pumpSplitView(
        tester,
        size: const Size(900, 800), // expanded
        splitView: const AdaptiveSplitView(
          hasSelection: true,
          master: SizedBox(key: masterKey),
          detail: SizedBox(key: detailKey),
          detailPlaceholder: SizedBox(key: placeholderKey),
        ),
      );

      expect(find.byKey(masterKey), findsOneWidget);
      expect(find.byKey(detailKey), findsOneWidget);
      expect(find.byKey(placeholderKey), findsNothing);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });
}

