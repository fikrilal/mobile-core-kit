import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';

void main() {
  testWidgets('AppSnackBar shows a success message', (tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    AppSnackBar.showSuccess(context, message: 'Saved');
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
  });
}
