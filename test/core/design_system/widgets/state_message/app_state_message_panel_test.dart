import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/state_message/state_message.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('AppStateMessagePanel renders content and actions', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      wrap(
        AppStateMessagePanel(
          title: 'Title',
          description: 'Description',
          leading: const Icon(Icons.info_outline),
          actions: [
            AppButton.primary(
              text: 'Continue',
              semanticLabel: 'Continue',
              isExpanded: true,
              onPressed: () => taps++,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('AppEmptyState renders fallback no-items title', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(wrap(const AppEmptyState()));

    expect(find.text('No items'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('AppEmptyState renders CTA action', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      wrap(
        AppEmptyState(
          title: 'Nothing here',
          actionLabel: 'Refresh',
          onAction: () => taps++,
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);

    await tester.tap(find.text('Refresh'));
    await tester.pump();

    expect(taps, 1);
  });
}
