import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/filter_chips/filter_chips.dart';

class FilterChipsShowcaseScreen extends StatefulWidget {
  const FilterChipsShowcaseScreen({super.key});

  @override
  State<FilterChipsShowcaseScreen> createState() =>
      _FilterChipsShowcaseScreenState();
}

class _FilterChipsShowcaseScreenState extends State<FilterChipsShowcaseScreen> {
  static const _statusItems = <AppFilterChipItem<String>>[
    AppFilterChipItem<String>(value: 'all', label: 'All'),
    AppFilterChipItem<String>(value: 'active', label: 'Active'),
    AppFilterChipItem<String>(value: 'pending', label: 'Pending'),
    AppFilterChipItem<String>(value: 'archived', label: 'Archived'),
  ];

  static const _categoryItems = <AppFilterChipItem<String>>[
    AppFilterChipItem<String>(value: 'food', label: 'Food'),
    AppFilterChipItem<String>(value: 'bills', label: 'Bills'),
    AppFilterChipItem<String>(value: 'travel', label: 'Travel'),
    AppFilterChipItem<String>(value: 'shopping', label: 'Shopping'),
    AppFilterChipItem<String>(value: 'health', label: 'Health'),
  ];

  Set<String> _singleSelection = const <String>{'all'};
  Set<String> _multiSelection = const <String>{'food', 'travel'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Chips Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space24),
              const AppText.titleLarge('Single Selection'),
              const SizedBox(height: AppSpacing.space8),
              AppFilterChipsBar<String>(
                items: _statusItems,
                selectedValues: _singleSelection,
                selectionMode: AppFilterSelectionMode.single,
                showClearAction: true,
                clearActionLabel: 'Clear',
                selectedCountLabelBuilder: (count) => '$count selected',
                onSelectionChanged: (next) {
                  setState(() {
                    _singleSelection = next;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodySmall(
                _singleSelection.isEmpty
                    ? 'Current: -'
                    : 'Current: ${_singleSelection.first}',
              ),
              const SizedBox(height: AppSpacing.space24),
              const AppText.titleLarge('Multi Selection (Wrap)'),
              const SizedBox(height: AppSpacing.space8),
              AppFilterChipsBar<String>(
                items: _categoryItems,
                selectedValues: _multiSelection,
                layout: AppFilterChipsLayout.wrap,
                showClearAction: true,
                clearActionLabel: 'Clear',
                selectedCountLabelBuilder: (count) => '$count selected',
                onSelectionChanged: (next) {
                  setState(() {
                    _multiSelection = next;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodySmall(
                _multiSelection.isEmpty
                    ? 'Current: -'
                    : 'Current: ${_multiSelection.join(', ')}',
              ),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
