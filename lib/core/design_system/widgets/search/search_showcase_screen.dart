import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/search.dart';

class SearchShowcaseScreen extends StatefulWidget {
  const SearchShowcaseScreen({super.key});

  @override
  State<SearchShowcaseScreen> createState() => _SearchShowcaseScreenState();
}

class _SearchShowcaseScreenState extends State<SearchShowcaseScreen> {
  final InMemoryAppSearchHistoryStore _historyStore =
      InMemoryAppSearchHistoryStore();

  String _lastQuery = '-';
  String _lastSubmitted = '-';
  String _lastSelected = '-';

  static const _catalog = <String>[
    'AppButton',
    'AppTextField',
    'AppDateField',
    'AppFilterChipsBar',
    'AppSearchExperience',
    'AppPaginatedCollectionView',
    'AppStateMessagePanel',
    'AppEmptyState',
    'AppSnackbar',
    'AppAvatar',
  ];

  Future<List<AppSearchSuggestion<String>>> _loadSuggestions(
    String query,
  ) async {
    await Future<void>.delayed(MotionDurations.medium);

    final normalized = query.trim().toLowerCase();
    return _catalog
        .where((item) => item.toLowerCase().contains(normalized))
        .take(6)
        .map(
          (item) => AppSearchSuggestion<String>(
            label: item,
            value: item,
            subtitle: 'Design system widget',
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space24),
              AppSearchExperience<String>(
                placeholder: 'Search widgets',
                enableHistory: true,
                historyStore: _historyStore,
                noResultsText: 'No matching widgets',
                historySectionLabel: 'Recent searches',
                suggestionsSectionLabel: 'Widget suggestions',
                clearHistoryLabel: 'Clear all',
                suggestionsLoader: _loadSuggestions,
                onQueryChanged: (query) {
                  setState(() {
                    _lastQuery = query.isEmpty ? '-' : query;
                  });
                },
                onQuerySubmitted: (query) {
                  setState(() {
                    _lastSubmitted = query.isEmpty ? '-' : query;
                  });
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _lastSelected = suggestion.label;
                  });
                },
                onCleared: () {
                  setState(() {
                    _lastQuery = '-';
                  });
                },
              ),
              const SizedBox(height: AppSpacing.space16),
              AppText.bodyMedium('Last query: $_lastQuery'),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodyMedium('Last submitted: $_lastSubmitted'),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodyMedium('Last selected suggestion: $_lastSelected'),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
