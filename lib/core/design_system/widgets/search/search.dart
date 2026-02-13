// Search component public API.
//
// This barrel exports only the design-system types. Avoid re-exporting Flutter
// SDK symbols to keep imports explicit in feature code.

export 'app_search_experience.dart'
    show
        AppSearchExperience,
        AppSearchHistoryStore,
        AppSearchSuggestion,
        AppSearchSuggestionSelected,
        AppSearchSuggestionsLoader,
        InMemoryAppSearchHistoryStore,
        appSearchExperienceBarKey,
        appSearchExperienceClearButtonKey,
        appSearchExperienceHistoryItemKey,
        appSearchExperienceSuggestionItemKey;
