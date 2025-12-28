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

  test('AppDotWave asserts when count is zero', () {
    expect(
      () => AppDotWave(color: Colors.black, count: 0),
      throwsAssertionError,
    );
  });

  testWidgets('AppDotWave renders the requested number of dots',
      (tester) async {
    const dotSize = 10.0;
    await tester.pumpWidget(
      wrap(const AppDotWave(color: Colors.black, count: 4, dotSize: dotSize)),
    );

    final dots = find.descendant(
      of: find.byType(AppDotWave),
      matching: find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        final constraints = widget.constraints;
        if (constraints == null) return false;
        if (constraints.minWidth != dotSize || constraints.minHeight != dotSize) {
          return false;
        }
        if (constraints.maxWidth != dotSize || constraints.maxHeight != dotSize) {
          return false;
        }
        return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
      }),
    );

    expect(dots, findsNWidgets(4));
  });

  testWidgets('AppDotWave animates over time', (tester) async {
    await tester.pumpWidget(wrap(const AppDotWave(color: Colors.black)));

    final transforms = find.descendant(
      of: find.byType(AppDotWave),
      matching: find.byType(Transform),
    );
    expect(transforms, findsWidgets);

    final before = tester.widget<Transform>(transforms.first).transform;
    await tester.pump(const Duration(milliseconds: 150));
    final after = tester.widget<Transform>(transforms.first).transform;

    expect(before, isNot(equals(after)));
  });

  testWidgets('AppDotWave supports disabling fade', (tester) async {
    await tester.pumpWidget(
      wrap(const AppDotWave(color: Colors.black, fade: false)),
    );

    final opacities = tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(AppDotWave),
            matching: find.byType(Opacity),
          ),
        )
        .toList();

    expect(opacities, isNotEmpty);
    expect(opacities.every((o) => o.opacity == 1.0), isTrue);
  });
}
