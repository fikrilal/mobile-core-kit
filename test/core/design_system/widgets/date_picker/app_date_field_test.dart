import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/date_picker/date_picker.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

Future<BuildContext> _pumpHost(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(500, 900),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AdaptiveScope(
        navigationPolicy: const NavigationPolicy.standard(),
        child: Builder(
          builder: (c) {
            context = c;
            return Scaffold(body: child);
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return context;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDateField', () {
    testWidgets('single field shows formatted initial value', (tester) async {
      final context = await _pumpHost(
        tester,
        child: AppDateField.single(
          value: DateTime(2026, 4, 7),
          firstDate: DateTime(2026, 4, 1),
          lastDate: DateTime(2026, 4, 30),
        ),
      );

      final localizations = MaterialLocalizations.of(context);
      final expected = localizations.formatMediumDate(DateTime(2026, 4, 7));

      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('single field opens picker and emits selected date', (
      tester,
    ) async {
      DateTime? selectedDate;

      await _pumpHost(
        tester,
        child: AppDateField.single(
          firstDate: DateTime(2026, 4, 1),
          lastDate: DateTime(2026, 4, 30),
          onChanged: (value) => selectedDate = value,
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-16')),
      );
      await tester.pump();
      await tester.tap(find.byKey(appDatePickerConfirmKey));
      await tester.pumpAndSettle();

      expect(selectedDate, DateTime(2026, 4, 16));
    });

    testWidgets('range field opens picker and emits selected range', (
      tester,
    ) async {
      DateTimeRange? selectedRange;

      await _pumpHost(
        tester,
        child: AppDateField.range(
          firstDate: DateTime(2026, 4, 1),
          lastDate: DateTime(2026, 4, 30),
          onRangeChanged: (value) => selectedRange = value,
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-07')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-10')),
      );
      await tester.pump();
      await tester.tap(find.byKey(appDatePickerConfirmKey));
      await tester.pumpAndSettle();

      expect(
        selectedRange,
        DateTimeRange(start: DateTime(2026, 4, 7), end: DateTime(2026, 4, 10)),
      );
    });
  });
}
