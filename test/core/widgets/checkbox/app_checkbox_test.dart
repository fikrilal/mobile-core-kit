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

  testWidgets('toggles value and calls onChanged', (tester) async {
    bool? value = false;
    var changedTo = <bool?>[];

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppCheckbox(
              value: value,
              onChanged: (v) {
                changedTo.add(v);
                setState(() => value = v);
              },
              semanticLabel: 'Accept',
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(changedTo, isNotEmpty);
    expect(value, isTrue);
  });

  testWidgets('tristate cycles false -> true -> null', (tester) async {
    bool? value = false;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppCheckbox(
              value: value,
              tristate: true,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(value, isNull);
  });

  testWidgets('disabled does not call onChanged', (tester) async {
    var called = false;

    await tester.pumpWidget(
      wrap(
        AppCheckbox(
          value: false,
          enabled: false,
          onChanged: (_) => called = true,
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(called, isFalse);
  });
}

