# Engineering Proposal: `AppSearchExperience<T>`

## Goal
Add a mature, reusable design-system search component that goes beyond a basic text field by providing native search capabilities:

1. Clear action
2. Debounced query callbacks
3. Async suggestions
4. Built-in recent-history display (optional)
5. Stale-result protection for async queries

This should standardize search UX and reduce duplicate search orchestration across future features.

## Why This Is High ROI
1. Search is a cross-cutting pattern used by list and discovery screens.
2. Teams repeatedly re-implement clear/debounce/suggestions/history behavior with subtle inconsistencies.
3. A DS-level search primitive becomes a force multiplier once pagination/filter endpoints expand.

## Scope (PR-sized, v1)
### Add
- `lib/core/design_system/widgets/search/app_search_experience.dart`
- `lib/core/design_system/widgets/search/search.dart`
- `test/core/design_system/widgets/search/app_search_experience_test.dart`

### Optional
- `lib/core/design_system/widgets/search/README.md`

### Out of Scope (v1)
- Full-screen search route
- Rich suggestion sections (grouped, highlighted substrings)
- Server-driven ranking logic
- Search analytics pipeline wiring
- SharedPreferences persistence implementation (interface only in v1)

## Proposed API (v1)
```dart
class AppSearchSuggestion<T> {
  const AppSearchSuggestion({
    required this.label,
    this.value,
    this.subtitle,
    this.leading,
    this.trailing,
  });
}

abstract interface class AppSearchHistoryStore {
  Future<List<String>> loadHistory();
  Future<void> saveHistory(List<String> values);
}

class AppSearchExperience<T> extends StatefulWidget {
  const AppSearchExperience({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.autofocus = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.minQueryLength = 1,
    this.isLoading = false,
    this.enableHistory = true,
    this.historyLimit = 10,
    this.historyStore,
    this.noResultsText,
    this.suggestionsLoader,
    this.onQueryChanged,
    this.onQuerySubmitted,
    this.onSuggestionSelected,
    this.onCleared,
  });
}
```

## Behavioral Contract
1. Query changes:
   - Input changes trigger debounced `onQueryChanged`.
2. Suggestions:
   - If `suggestionsLoader` is provided and query length meets `minQueryLength`, load suggestions asynchronously.
   - Late async responses must be ignored when a newer request exists (stale-result guard).
3. Submit:
   - Search action triggers `onQuerySubmitted` immediately.
   - Submitted non-empty query is added to history when history is enabled.
4. Clear:
   - Clear action empties query, triggers `onCleared`, and propagates updated query state.
5. History:
   - On empty query + focused search field, show recent history.
   - New entries deduped and moved to top.
   - History capped by `historyLimit`.
   - If `historyStore` exists, history loads/saves via interface.

## Architecture Alignment
1. Presentation-only:
   - Widget owns UI interaction mechanics only.
2. Feature state ownership:
   - Cubit/Bloc owns actual domain search results and API orchestration.
3. Integration contract:
   - Widget emits query/suggestion events upward; no business decisions inside DS layer.

## Testing Plan
`test/core/design_system/widgets/search/app_search_experience_test.dart`

Required tests:
1. Debounce emits latest query only after duration.
2. Clear action resets input and triggers clear callback.
3. Suggestion tap emits selected suggestion + submit callback.
4. Submitted query appears in history on empty query state.
5. Stale async results are ignored when newer request completes first.

## Rollout Strategy
1. PR 1 (this scope): Add widget + tests.
2. PR 2: Add concrete persisted history adapter (e.g., shared preferences) if needed.
3. PR 3: Migrate one feature page as reference integration.

## Risks and Mitigations
1. Overloading DS with business logic:
   - Keep API event-driven and stateless regarding domain outcomes.
2. Async race bugs:
   - Use request token strategy and test stale-response handling.
3. PII/privacy concerns in history:
   - History is opt-in (`enableHistory`) and store is pluggable.

## Success Criteria
1. Search behavior is consistent across features.
2. DS widget is lint-clean and test-covered.
3. Feature teams can integrate mature search without re-implementing mechanics.
