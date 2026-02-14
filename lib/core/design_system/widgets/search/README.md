# Search

`AppSearchExperience<T>` is a minimal search input primitive.

## What It Does

- Custom, tokenized search field UI
- Optional debounced `onQueryChanged`
- Submit callback (`onQuerySubmitted`)
- Clear action callback (`onCleared`)
- Outside-tap unfocus behavior

## What It Does Not Do

- Suggestions dropdown
- Local search history
- Search result orchestration

Feature modules should implement those behaviors themselves when needed.

## Usage

```dart
AppSearchExperience<String>(
  placeholder: 'Search transactions',
  debounceDuration: const Duration(milliseconds: 300),
  onQueryChanged: cubit.onQueryChanged,
  onQuerySubmitted: cubit.onQuerySubmitted,
)
```
