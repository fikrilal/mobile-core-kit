import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('password field toggles obscure text', (tester) async {
    final controller = TextEditingController(text: 'secret');

    await tester.pumpWidget(
      wrapWidget(
        AppTextField.password(controller: controller, labelText: 'Password'),
      ),
    );

    expect(find.byIcon(Icons.visibility), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('number field filters non-digit input', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      wrapWidget(
        AppTextField(fieldType: FieldType.number, controller: controller),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '12a3');
    await tester.pump();

    expect(controller.text, '123');
  });

  testWidgets('uses semanticLabel when provided', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const AppTextField(labelText: 'Name', semanticLabel: 'Full name input'),
      ),
    );

    final semanticsWidgets = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .toList();

    expect(
      semanticsWidgets.where((s) => s.properties.label == 'Full name input'),
      isNotEmpty,
    );
  });
}
