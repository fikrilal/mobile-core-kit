import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/async_state/async_state.dart';
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

  testWidgets(
    'initial renders default loading when treatInitialAsLoading true',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          AppAsyncStateView<void>(
            status: AppAsyncStatus.initial,
            successBuilder: (_) => const Text('Success'),
          ),
        ),
      );

      expect(find.text('Loading'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    },
  );

  testWidgets(
    'initial renders initialBuilder when treatInitialAsLoading false',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          AppAsyncStateView<void>(
            status: AppAsyncStatus.initial,
            treatInitialAsLoading: false,
            initialBuilder: (_) => const Text('Idle'),
            successBuilder: (_) => const Text('Success'),
          ),
        ),
      );

      expect(find.text('Idle'), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    },
  );

  testWidgets('success renders successBuilder', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppAsyncStateView<void>(
          status: AppAsyncStatus.success,
          successBuilder: (_) => const Text('Success'),
        ),
      ),
    );

    expect(find.text('Success'), findsOneWidget);
  });

  testWidgets('empty renders emptyBuilder', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppAsyncStateView<void>(
          status: AppAsyncStatus.empty,
          emptyBuilder: (_) => const Text('No data'),
          successBuilder: (_) => const Text('Success'),
        ),
      ),
    );

    expect(find.text('No data'), findsOneWidget);
    expect(find.text('Success'), findsNothing);
  });

  testWidgets('failure default view renders retry action when configured', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      wrap(
        AppAsyncStateView<void>(
          status: AppAsyncStatus.failure,
          successBuilder: (_) => const Text('Success'),
          onRetry: () => retryCount++,
          retryLabel: 'Retry',
        ),
      ),
    );

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retryCount, 1);
  });

  testWidgets('failure builder receives typed failure payload', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppAsyncStateView<int>(
          status: AppAsyncStatus.failure,
          failure: 404,
          successBuilder: (_) => const Text('Success'),
          failureBuilder: (_, failure) => Text('Failure:$failure'),
        ),
      ),
    );

    expect(find.text('Failure:404'), findsOneWidget);
  });
}
