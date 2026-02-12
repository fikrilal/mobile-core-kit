import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/date_picker/date_picker.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

Future<BuildContext> _pumpHost(WidgetTester tester, Size size) async {
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
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return context;
}

Widget _wrapDirect(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatePickerSheet', () {
    testWidgets('single mode returns selected date', (tester) async {
      final context = await _pumpHost(tester, const Size(500, 900));

      final resultFuture = showAppSingleDatePickerSheet(
        context: context,
        firstDate: DateTime(2026, 4, 1),
        lastDate: DateTime(2026, 4, 30),
        initialDate: DateTime(2026, 4, 7),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-16')),
      );
      await tester.pump();
      await tester.tap(find.byKey(appDatePickerConfirmKey));
      await tester.pumpAndSettle();

      expect(await resultFuture, DateTime(2026, 4, 16));
    });

    testWidgets('range mode reorders selection when end is before start', (
      tester,
    ) async {
      final context = await _pumpHost(tester, const Size(500, 900));

      final resultFuture = showAppDateRangePickerSheet(
        context: context,
        firstDate: DateTime(2026, 4, 1),
        lastDate: DateTime(2026, 4, 30),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-16')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-07')),
      );
      await tester.pump();

      await tester.tap(find.byKey(appDatePickerConfirmKey));
      await tester.pumpAndSettle();

      expect(
        await resultFuture,
        DateTimeRange(start: DateTime(2026, 4, 7), end: DateTime(2026, 4, 16)),
      );
    });

    testWidgets('maxRangeDays disables invalid end dates', (tester) async {
      final context = await _pumpHost(tester, const Size(500, 900));

      final resultFuture = showAppDateRangePickerSheet(
        context: context,
        firstDate: DateTime(2026, 4, 1),
        lastDate: DateTime(2026, 4, 30),
        maxRangeDays: 3,
      );

      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-07')),
      );
      await tester.pump();

      final invalidDayButton = tester.widget<TextButton>(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-12')),
      );
      expect(invalidDayButton.onPressed, isNull);

      await tester.tap(find.byKey(appDatePickerCancelKey));
      await tester.pumpAndSettle();
      expect(await resultFuture, isNull);
    });

    testWidgets('month navigation respects first/last month bounds', (
      tester,
    ) async {
      final context = await _pumpHost(tester, const Size(500, 900));

      final resultFuture = showAppSingleDatePickerSheet(
        context: context,
        firstDate: DateTime(2026, 4, 1),
        lastDate: DateTime(2026, 4, 30),
      );

      await tester.pumpAndSettle();

      final prevButton = tester.widget<IconButton>(
        find.byKey(appDatePickerPrevMonthKey),
      );
      final nextButton = tester.widget<IconButton>(
        find.byKey(appDatePickerNextMonthKey),
      );

      expect(prevButton.onPressed, isNull);
      expect(nextButton.onPressed, isNull);

      await tester.tap(find.byKey(appDatePickerCancelKey));
      await tester.pumpAndSettle();
      expect(await resultFuture, isNull);
    });

    testWidgets('reset clears current selection state', (tester) async {
      await tester.pumpWidget(
        _wrapDirect(
          AppDatePickerSheet.single(
            firstDate: DateTime(2026, 4, 1),
            lastDate: DateTime(2026, 4, 30),
            resetLabel: 'Reset',
          ),
        ),
      );
      await tester.pump();

      AppButton confirmButton() =>
          tester.widget<AppButton>(find.byKey(appDatePickerConfirmKey));

      expect(confirmButton().isDisabled, isTrue);

      await tester.tap(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-07')),
      );
      await tester.pump();
      expect(confirmButton().isDisabled, isFalse);

      await tester.ensureVisible(find.byKey(appDatePickerResetKey));
      await tester.tap(find.byKey(appDatePickerResetKey));
      await tester.pump();
      expect(confirmButton().isDisabled, isTrue);
    });

    testWidgets('selectableDayPredicate disables filtered day', (tester) async {
      await tester.pumpWidget(
        _wrapDirect(
          AppDatePickerSheet.single(
            firstDate: DateTime(2026, 4, 1),
            lastDate: DateTime(2026, 4, 30),
            selectableDayPredicate: (day) => day.day != 10,
          ),
        ),
      );
      await tester.pump();

      final dayButton = tester.widget<TextButton>(
        find.byKey(const ValueKey('app_date_picker_day_2026-04-10')),
      );
      expect(dayButton.onPressed, isNull);
    });
  });
}
