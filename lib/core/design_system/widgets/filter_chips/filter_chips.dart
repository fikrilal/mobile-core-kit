// Filter-chips component public API.
//
// This barrel exports only the design-system types. Avoid re-exporting Flutter
// SDK symbols to keep imports explicit in feature code.

export 'app_filter_chips_bar.dart'
    show
        AppFilterChipItem,
        AppFilterChipsBar,
        AppFilterChipsLayout,
        AppFilterSelectedCountLabelBuilder,
        AppFilterSelectionChanged,
        AppFilterSelectionMode,
        appFilterChipsClearActionKey;
