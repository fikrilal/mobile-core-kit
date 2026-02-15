import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/search/search.dart';

class SearchShowcaseScreen extends StatefulWidget {
  const SearchShowcaseScreen({super.key});

  @override
  State<SearchShowcaseScreen> createState() => _SearchShowcaseScreenState();
}

class _SearchShowcaseScreenState extends State<SearchShowcaseScreen> {
  String _lastQuery = '-';
  String _lastSubmitted = '-';

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
                debounceDuration: Duration.zero,
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
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
