import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/dialog/app_confirmation_dialog.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));
  }

  testWidgets('confirm returns true', (tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final future = showAppConfirmationDialog(
      context: context,
      title: 'Title',
      message: 'Message',
      confirmLabel: 'Confirm',
      cancelLabel: 'Cancel',
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(await future, isTrue);
  });

  testWidgets('close button pops false when enabled', (tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final future = showAppConfirmationDialog(
      context: context,
      title: 'Title',
      message: 'Message',
      confirmLabel: 'Confirm',
      cancelLabel: 'Cancel',
      showCloseButton: true,
      variant: AppConfirmationDialogVariant.featured,
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(await future, isFalse);
  });

  testWidgets('barrier dismiss is disabled while loading', (tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    showAppConfirmationDialog(
      context: context,
      title: 'Title',
      message: 'Message',
      confirmLabel: 'Confirm',
      cancelLabel: 'Cancel',
      isLoading: true,
      showCloseButton: true,
      variant: AppConfirmationDialogVariant.standard,
    );

    // Avoid pumpAndSettle here because the loading indicator animates.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Title'), findsOneWidget);

    // Tap outside the dialog; should NOT dismiss while loading.
    await tester.tapAt(const Offset(1, 1));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Title'), findsOneWidget);
  });
}
