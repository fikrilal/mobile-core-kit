import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/checkbox/checkbox.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('tapping label toggles value', (tester) async {
    bool? value = false;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppCheckboxTile(
              value: value,
              label: 'Accept',
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(value, isTrue);
  });

  testWidgets('disabled tile does not toggle', (tester) async {
    var called = false;

    await tester.pumpWidget(
      wrap(
        AppCheckboxTile(
          value: false,
          enabled: false,
          label: 'Accept',
          onChanged: (_) => called = true,
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pump();

    expect(called, isFalse);
  });

  testWidgets('helperText is rendered when provided', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppCheckboxTile(
          value: false,
          label: 'Accept',
          helperText: 'Required to continue',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Required to continue'), findsOneWidget);
  });
}
