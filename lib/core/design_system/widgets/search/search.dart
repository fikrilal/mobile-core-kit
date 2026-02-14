// Search component public API.
//
// This barrel exports only the design-system types. Avoid re-exporting Flutter
// SDK symbols to keep imports explicit in feature code.

export 'app_search_experience.dart' show AppSearchExperience;
export 'app_search_history_store.dart'
    show AppSearchHistoryStore, InMemoryAppSearchHistoryStore;
export 'app_search_keys.dart'
    show
        appSearchExperienceBarKey,
        appSearchExperienceClearButtonKey,
        appSearchExperienceClearHistoryKey,
        appSearchExperienceContainerKey,
        appSearchExperienceHistoryItemKey,
        appSearchExperiencePanelKey,
        appSearchExperiencePanelListKey,
        appSearchExperienceSuggestionItemKey;
export 'app_search_models.dart'
    show
        AppSearchPanelEntry,
        AppSearchPanelEntryType,
        AppSearchSuggestion,
        AppSearchSuggestionSelected,
        AppSearchSuggestionsLoader;
export 'app_search_style.dart' show AppSearchStyle;
