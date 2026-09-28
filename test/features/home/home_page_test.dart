import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_scope.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/features/home/presentation/pages/home_page.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('Home shows a discoverable entry into the merchant demo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light().copyWith(splashFactory: NoSplash.splashFactory),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AdaptiveScope(
          navigationPolicy: const NavigationPolicy.none(),
          child: const HomePage(),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Start merchant onboarding demo'), findsOneWidget);
  });
}
