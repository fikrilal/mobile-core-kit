import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/badge.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppIconBadge', () {
    testWidgets('shows dot when showDot is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppIconBadge(icon: PhosphorIcon(PhosphorIcons.bell()), showDot: true),
        ),
      );

      expect(find.byKey(const ValueKey('AppIconBadge.dot')), findsOneWidget);
    });

    testWidgets('hides dot when showDot is false', (tester) async {
      await tester.pumpWidget(
        _wrap(AppIconBadge(icon: PhosphorIcon(PhosphorIcons.bell()))),
      );

      expect(find.byKey(const ValueKey('AppIconBadge.dot')), findsNothing);
    });

    testWidgets('triggers onTap when provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          AppIconBadge(
            icon: const Icon(Icons.notifications_none),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('AppIconBadge.container')));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('dot stays anchored when parent expands width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: Row(
                children: [
                  Expanded(
                    child: AppIconBadge(
                      icon: const Icon(Icons.notifications_none),
                      showDot: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerRect = tester.getRect(
        find.byKey(const ValueKey('AppIconBadge.container')),
      );
      final dotRect = tester.getRect(
        find.byKey(const ValueKey('AppIconBadge.dot')),
      );

      expect(dotRect.center.dx, greaterThan(containerRect.center.dx));
      expect((dotRect.center.dx - containerRect.right).abs(), lessThan(12));
      expect((dotRect.center.dy - containerRect.top).abs(), lessThan(12));
    });
  });
}
