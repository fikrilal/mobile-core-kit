import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('AppButton disables press when loading', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      _wrap(
        AppButton(
          text: 'Submit',
          isLoading: true,
          onPressed: () {
            tapCount++;
          },
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(tapCount, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppButton expands to full width when isExpanded in bounded width',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 200,
          child: AppButton(
            text: 'Expand',
            isExpanded: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    final buttonSize = tester.getSize(find.byType(ElevatedButton));
    expect(buttonSize.width, 200);
  });

  testWidgets('AppButton exposes semantics label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppButton(
          text: 'Save',
          semanticLabel: 'Save document',
          onPressed: () {},
        ),
      ),
    );

    final semanticsWidgets =
        tester.widgetList<Semantics>(find.byType(Semantics)).toList();

    final matching = semanticsWidgets.where(
      (s) => s.properties.label == 'Save document',
    );

    expect(matching, isNotEmpty);
    expect(matching.first.properties.button, isTrue);
    expect(matching.first.properties.enabled, isTrue);
  });
}
