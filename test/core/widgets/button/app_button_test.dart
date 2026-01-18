import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/theme/system/state_opacities.dart';
import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('AppButton disables press when loading', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      wrap(
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

  testWidgets(
    'AppButton expands to full width when isExpanded in bounded width',
    (tester) async {
      await tester.pumpWidget(
        wrap(
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
    },
  );

  testWidgets('AppButton exposes semantics label', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppButton(
          text: 'Save',
          semanticLabel: 'Save document',
          onPressed: () {},
        ),
      ),
    );

    final semanticsWidgets = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .toList();

    final matching = semanticsWidgets.where(
      (s) => s.properties.label == 'Save document',
    );

    expect(matching, isNotEmpty);
    expect(matching.first.properties.button, isTrue);
    expect(matching.first.properties.enabled, isTrue);
  });

  testWidgets('AppButton label inherits the button foreground color', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(text: 'Primary', onPressed: () {}),
            AppButton.secondary(text: 'Secondary', onPressed: () {}),
            AppButton.outline(text: 'Outline', onPressed: () {}),
            AppButton.danger(text: 'Danger', onPressed: () {}),
          ],
        ),
      ),
    );

    final themeContext = tester.element(find.text('Primary'));
    final scheme = Theme.of(themeContext).colorScheme;

    expect(_effectiveTextColor(tester, find.text('Primary')), scheme.onPrimary);
    expect(
      _effectiveTextColor(tester, find.text('Secondary')),
      scheme.onSecondary,
    );
    expect(_effectiveTextColor(tester, find.text('Outline')), scheme.primary);
    expect(_effectiveTextColor(tester, find.text('Danger')), scheme.onError);
  });

  testWidgets('AppButton uses disabled foreground color when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppButton.primary(text: 'Disabled', isDisabled: true, onPressed: () {}),
      ),
    );

    final ctx = tester.element(find.text('Disabled'));
    final scheme = Theme.of(ctx).colorScheme;
    final expectedDisabled = scheme.onSurface.withAlpha(
      (255 * StateOpacities.disabledContent).round(),
    );

    expect(
      _effectiveTextColor(tester, find.text('Disabled')),
      expectedDisabled,
    );
  });

  testWidgets('AppButton spinner color matches effective foreground', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppButton.primary(text: 'Loading', isLoading: true, onPressed: () {}),
      ),
    );

    final ctx = tester.element(find.text('Loading'));
    final scheme = Theme.of(ctx).colorScheme;
    final expectedDisabled = scheme.onSurface.withAlpha(
      (255 * StateOpacities.disabledContent).round(),
    );

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.color, expectedDisabled);
  });
}

Color? _effectiveTextColor(WidgetTester tester, Finder textFinder) {
  final element = tester.element(textFinder);
  final defaultStyle = DefaultTextStyle.of(element).style;
  final textWidget = tester.widget<Text>(textFinder);
  final effectiveStyle = defaultStyle.merge(textWidget.style);
  return effectiveStyle.color;
}
