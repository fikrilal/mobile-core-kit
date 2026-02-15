import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/search.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  Future<void> focusSearchBar(WidgetTester tester) async {
    await tester.tap(find.byKey(appSearchExperienceBarKey));
    await tester.pump();
  }

  testWidgets('debounce emits latest query only', (tester) async {
    final calls = <String>[];

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          placeholder: 'Search',
          debounceDuration: const Duration(milliseconds: 300),
          onQueryChanged: calls.add,
        ),
      ),
    );

    await focusSearchBar(tester);
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'a');
    await tester.pump(const Duration(milliseconds: 120));
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'ab');
    await tester.pump(const Duration(milliseconds: 120));

    expect(calls, isEmpty);

    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, <String>['ab']);
  });

  testWidgets('uses custom search shell instead of Material SearchBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AppSearchExperience<String>(
          placeholder: 'Search',
          debounceDuration: Duration.zero,
        ),
      ),
    );

    expect(find.byType(SearchBar), findsNothing);
    expect(find.byKey(appSearchExperienceBarKey), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('clear button resets text and notifies callbacks', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'apple');
    var clearCalls = 0;
    final changedCalls = <String>[];

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          controller: controller,
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          onCleared: () => clearCalls++,
          onQueryChanged: changedCalls.add,
        ),
      ),
    );

    await tester.tap(find.byKey(appSearchExperienceClearButtonKey));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(clearCalls, 1);
    expect(changedCalls, <String>['']);
  });

  testWidgets('submit callback receives trimmed query', (tester) async {
    final submitted = <String>[];

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          onQuerySubmitted: submitted.add,
        ),
      ),
    );

    await focusSearchBar(tester);
    await tester.enterText(find.byKey(appSearchExperienceBarKey), '  app  ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(submitted, <String>['app']);
  });

  testWidgets('tap outside unfocuses field', (tester) async {
    final focusNode = FocusNode();

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          focusNode: focusNode,
        ),
      ),
    );

    await focusSearchBar(tester);
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(2, 2));
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);

    focusNode.dispose();
  });
}
