# Search

`AppSearchExperience<T>` is an enterprise search primitive with custom UX/UI (no `SearchBar` dependency).

## Features

- Fully custom shell and suggestion panel (flat visual style, no elevation)
- Debounced query stream + async suggestions
- Stale response protection (latest request wins)
- Optional persisted recent history (`AppSearchHistoryStore`)
- Keyboard navigation support (up/down/enter/escape)
- Clear-history action
- Query highlight inside suggestion labels
- Theme-aware styling through `AppSearchStyle`

## Usage

```dart
AppSearchExperience<String>(
  placeholder: 'Search transactions',
  debounceDuration: const Duration(milliseconds: 300),
  enableHistory: true,
  historyStore: InMemoryAppSearchHistoryStore(),
  noResultsText: 'No matching results',
  suggestionsLoader: (query) async => [
    AppSearchSuggestion<String>(label: query, value: query),
  ],
  onQueryChanged: cubit.onQueryChanged,
  onQuerySubmitted: cubit.onQuerySubmitted,
  onSuggestionSelected: (suggestion) {
    cubit.onSuggestionSelected(suggestion.value ?? suggestion.label);
  },
)
```

## Notes

- Keep business search logic in Cubit/Bloc/use cases.
- Keep this widget focused on UX orchestration.
- Pass a custom `AppSearchHistoryStore` for cross-session persistence.
