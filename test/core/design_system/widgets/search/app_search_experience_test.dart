import 'dart:async';

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

  testWidgets('suggestion tap emits selected and submitted', (tester) async {
    final submitted = <String>[];
    final selected = <String>[];
    final controller = TextEditingController();

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          controller: controller,
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          suggestionsLoader: (query) async {
            if (query == 'app') {
              return const <AppSearchSuggestion<String>>[
                AppSearchSuggestion<String>(label: 'apple', value: 'apple'),
              ];
            }
            return const <AppSearchSuggestion<String>>[];
          },
          onSuggestionSelected: (suggestion) {
            selected.add(suggestion.value ?? suggestion.label);
          },
          onQuerySubmitted: submitted.add,
        ),
      ),
    );

    await focusSearchBar(tester);
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'app');
    await tester.pump();

    expect(find.text('apple'), findsOneWidget);

    await tester.tap(find.text('apple'));
    await tester.pump();

    expect(controller.text, 'apple');
    expect(selected, <String>['apple']);
    expect(submitted, <String>['apple']);
  });

  testWidgets('submitted query appears in history when query is empty', (
    tester,
  ) async {
    final store = InMemoryAppSearchHistoryStore();
    final controller = TextEditingController();

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          controller: controller,
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          historyStore: store,
          enableHistory: true,
        ),
      ),
    );

    await focusSearchBar(tester);
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'phone');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    await tester.tap(find.byKey(appSearchExperienceClearButtonKey));
    await tester.pump();
    await focusSearchBar(tester);

    expect(
      find.byKey(appSearchExperienceHistoryItemKey('phone')),
      findsOneWidget,
    );
  });

  testWidgets('ignores stale suggestion responses', (tester) async {
    final oldRequest = Completer<List<AppSearchSuggestion<String>>>();
    final newRequest = Completer<List<AppSearchSuggestion<String>>>();

    await tester.pumpWidget(
      wrap(
        AppSearchExperience<String>(
          placeholder: 'Search',
          debounceDuration: Duration.zero,
          suggestionsLoader: (query) {
            if (query == 'a') return oldRequest.future;
            if (query == 'ab') return newRequest.future;
            return const <AppSearchSuggestion<String>>[];
          },
        ),
      ),
    );

    await focusSearchBar(tester);
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'a');
    await tester.pump();
    await tester.enterText(find.byKey(appSearchExperienceBarKey), 'ab');
    await tester.pump();

    newRequest.complete(const <AppSearchSuggestion<String>>[
      AppSearchSuggestion<String>(label: 'new'),
    ]);
    await tester.pump();

    oldRequest.complete(const <AppSearchSuggestion<String>>[
      AppSearchSuggestion<String>(label: 'old'),
    ]);
    await tester.pump();

    expect(find.text('new'), findsOneWidget);
    expect(find.text('old'), findsNothing);
  });
}
