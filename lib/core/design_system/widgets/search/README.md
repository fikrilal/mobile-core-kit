# Search

`AppSearchExperience<T>` is a mature search primitive for feature pages that need:

- Clear action
- Debounced query changes
- Async suggestions
- Optional recent query history
- Safe async result handling (stale responses ignored)

## Usage

```dart
AppSearchExperience<String>(
  placeholder: 'Search transactions',
  debounceDuration: const Duration(milliseconds: 300),
  enableHistory: true,
  suggestionsLoader: (query) async => [
    AppSearchSuggestion<String>(label: query, value: query),
  ],
  onQueryChanged: cubit.onQueryChanged,
  onQuerySubmitted: cubit.onQuerySubmitted,
  onSuggestionSelected: (suggestion) => cubit.onSuggestionSelected(
    suggestion.value ?? suggestion.label,
  ),
)
```

## Notes

- Keep domain/business search logic in Cubit/Bloc.
- Use `historyStore` when you want persistence across app launches.
