import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/theme/theme.dart';
import 'package:mobile_core_kit/core/widgets/dialog/app_confirmation_dialog.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showAppConfirmationDialog (adaptive presentation)', () {
    testWidgets('uses a bottom sheet on compact widths', (tester) async {
      final context = await _pumpHost(tester, const Size(500, 800));

      final result = showAppConfirmationDialog(
        context: context,
        title: 'Confirm?',
        message: 'Proceed?',
      );

      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
    });

    testWidgets('uses a dialog on medium+ widths', (tester) async {
      final context = await _pumpHost(tester, const Size(800, 800));

      final result = showAppConfirmationDialog(
        context: context,
        title: 'Confirm?',
        message: 'Proceed?',
      );

      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await result, isFalse);
    });

    testWidgets('disables system back when non-dismissible', (tester) async {
      final context = await _pumpHost(tester, const Size(800, 800));

      final result = showAppConfirmationDialog(
        context: context,
        title: 'Locked',
        message: 'Cannot dismiss via back.',
        isCancelEnabled: false,
      );

      await tester.pumpAndSettle();
      expect(find.text('Locked'), findsOneWidget);

      await Navigator.of(context).maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Locked'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
    });
  });
}
