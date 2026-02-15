# Filter Chips

`AppFilterChipsBar<T>` standardizes filter-chip interactions (single/multiple selection, clear-all action, and layout mode).

## Usage

```dart
AppFilterChipsBar<String>(
  items: const [
    AppFilterChipItem(value: 'active', label: 'Active'),
    AppFilterChipItem(value: 'pending', label: 'Pending'),
  ],
  selectedValues: state.selectedFilters,
  onSelectionChanged: cubit.onFiltersChanged,
  selectionMode: AppFilterSelectionMode.multiple,
  showClearAction: true,
  clearActionLabel: 'Clear',
)
```

## Notes

- Keep domain/business logic in Cubit/Bloc; this widget is presentation-only.
- Use `AppFilterChipsLayout.wrap` for larger surfaces that need multiline chips.
