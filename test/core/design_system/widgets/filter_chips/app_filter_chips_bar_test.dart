import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/theme.dart';
import 'package:mobile_core_kit/core/design_system/widgets/filter_chips/filter_chips.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }

  FilterChip chipForLabel(WidgetTester tester, String label) {
    return tester.widget<FilterChip>(
      find.ancestor(of: find.text(label), matching: find.byType(FilterChip)),
    );
  }

  testWidgets('renders all chip labels', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(value: 'all', label: 'All'),
            AppFilterChipItem<String>(value: 'active', label: 'Active'),
            AppFilterChipItem<String>(value: 'pending', label: 'Pending'),
          ],
          selectedValues: const <String>{},
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('multiple mode toggles selection', (tester) async {
    final emitted = <Set<String>>[];
    var selected = <String>{};

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppFilterChipsBar<String>(
              items: const <AppFilterChipItem<String>>[
                AppFilterChipItem<String>(value: 'active', label: 'Active'),
                AppFilterChipItem<String>(value: 'pending', label: 'Pending'),
              ],
              selectedValues: selected,
              onSelectionChanged: (next) {
                emitted.add(Set<String>.from(next));
                setState(() => selected = Set<String>.from(next));
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Active'));
    await tester.pump();
    await tester.tap(find.text('Pending'));
    await tester.pump();
    await tester.tap(find.text('Active'));
    await tester.pump();

    expect(emitted, <Set<String>>[
      <String>{'active'},
      <String>{'active', 'pending'},
      <String>{'pending'},
    ]);
  });

  testWidgets('single mode enforces exclusive selection', (tester) async {
    final emitted = <Set<String>>[];
    var selected = <String>{};

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppFilterChipsBar<String>(
              selectionMode: AppFilterSelectionMode.single,
              items: const <AppFilterChipItem<String>>[
                AppFilterChipItem<String>(value: 'active', label: 'Active'),
                AppFilterChipItem<String>(value: 'pending', label: 'Pending'),
              ],
              selectedValues: selected,
              onSelectionChanged: (next) {
                emitted.add(Set<String>.from(next));
                setState(() => selected = Set<String>.from(next));
              },
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Active'));
    await tester.pump();
    await tester.tap(find.text('Pending'));
    await tester.pump();
    await tester.tap(find.text('Pending'));
    await tester.pump();

    expect(emitted, <Set<String>>[
      <String>{'active'},
      <String>{'pending'},
      <String>{},
    ]);
  });

  testWidgets('disabled chip does not emit changes', (tester) async {
    final emitted = <Set<String>>[];

    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(
              value: 'active',
              label: 'Active',
              enabled: false,
            ),
          ],
          selectedValues: const <String>{},
          onSelectionChanged: emitted.add,
        ),
      ),
    );

    final chip = chipForLabel(tester, 'Active');
    expect(chip.onSelected, isNull);

    await tester.tap(find.text('Active'));
    await tester.pump();

    expect(emitted, isEmpty);
  });

  testWidgets('clear action emits empty selection by default', (tester) async {
    final emitted = <Set<String>>[];
    var selected = <String>{'active'};

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return AppFilterChipsBar<String>(
              items: const <AppFilterChipItem<String>>[
                AppFilterChipItem<String>(value: 'active', label: 'Active'),
              ],
              selectedValues: selected,
              onSelectionChanged: (next) {
                emitted.add(Set<String>.from(next));
                setState(() => selected = Set<String>.from(next));
              },
              showClearAction: true,
              clearActionLabel: 'Clear',
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(appFilterChipsClearActionKey));
    await tester.pump();

    expect(emitted, <Set<String>>[<String>{}]);
    final clearButton = tester.widget<TextButton>(
      find.byKey(appFilterChipsClearActionKey),
    );
    expect(clearButton.onPressed, isNull);
  });

  testWidgets('clear action uses onClear callback when provided', (
    tester,
  ) async {
    var clearCalls = 0;
    var selectionCalls = 0;

    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(value: 'active', label: 'Active'),
          ],
          selectedValues: const <String>{'active'},
          onSelectionChanged: (_) => selectionCalls++,
          showClearAction: true,
          clearActionLabel: 'Clear',
          onClear: () => clearCalls++,
        ),
      ),
    );

    await tester.tap(find.byKey(appFilterChipsClearActionKey));
    await tester.pump();

    expect(clearCalls, 1);
    expect(selectionCalls, 0);
  });

  testWidgets('renders wrap layout when requested', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          layout: AppFilterChipsLayout.wrap,
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(value: 'all', label: 'All'),
          ],
          selectedValues: const <String>{},
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('renders horizontal layout by default', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(value: 'all', label: 'All'),
          ],
          selectedValues: const <String>{},
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('shows selected-count label when builder returns text', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppFilterChipsBar<String>(
          items: const <AppFilterChipItem<String>>[
            AppFilterChipItem<String>(value: 'all', label: 'All'),
          ],
          selectedValues: const <String>{'all', 'other'},
          onSelectionChanged: (_) {},
          selectedCountLabelBuilder: (count) => '$count selected',
        ),
      ),
    );

    expect(find.text('2 selected'), findsOneWidget);
  });
}
