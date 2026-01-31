import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
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

  testWidgets('renders child when not loading', (tester) async {
    await tester.pumpWidget(
      wrap(const AppLoadingOverlay(isLoading: false, child: Text('Content'))),
    );

    expect(find.text('Content'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppLoadingOverlay),
        matching: find.byType(ModalBarrier),
      ),
      findsNothing,
    );
  });

  testWidgets('blocks interaction and shows message when loading', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      wrap(
        AppLoadingOverlay(
          isLoading: true,
          message: 'Loading…',
          child: ElevatedButton(
            onPressed: () => tapCount++,
            child: const Text('Tap'),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppLoadingOverlay),
        matching: find.byType(ModalBarrier),
      ),
      findsOneWidget,
    );
    expect(find.text('Loading…'), findsOneWidget);

    await tester.tap(find.text('Tap'), warnIfMissed: false);
    await tester.pump();

    expect(tapCount, 0);
  });

  testWidgets('wraps with PopScope when blockBackButton is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppLoadingOverlay(
          isLoading: true,
          blockBackButton: true,
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(PopScope), findsOneWidget);
    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
  });

  testWidgets('does not use PopScope when blockBackButton is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppLoadingOverlay(
          isLoading: true,
          blockBackButton: false,
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.byType(PopScope), findsNothing);
  });
}
