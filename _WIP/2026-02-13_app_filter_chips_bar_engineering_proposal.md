# Engineering Proposal: `AppFilterChipsBar<T>`

## Goal
Add a reusable design-system widget that standardizes filter-chip UX across list/search/filter screens with a small, typed, and predictable API.

The widget should cover:
1. Single-select chips (choice style)
2. Multi-select chips (facet style)
3. Optional clear-all action
4. Horizontal-scroll and wrap layouts

## Why This Is High ROI
1. Filter chips recur across product surfaces (transactions, history, inbox, search results, catalogs).
2. Without a shared primitive, each feature re-implements slightly different chip behavior (selection, clear-all, disabled state), causing UX drift.
3. This is a future-leverage widget: it reduces integration cost when pagination/filter endpoints are expanded.

## Scope (PR-sized, v1)
### Add
- `lib/core/design_system/widgets/filter_chips/app_filter_chips_bar.dart`
- `lib/core/design_system/widgets/filter_chips/filter_chips.dart`
- `test/core/design_system/widgets/filter_chips/app_filter_chips_bar_test.dart`

### Out of Scope (v1)
- Search-in-chip-list
- Hierarchical chips / grouped chips
- Overflow "More" menu behavior
- Animated reordering or drag-and-drop

## Proposed API (v1)
```dart
enum AppFilterSelectionMode { single, multiple }
enum AppFilterChipsLayout { horizontal, wrap }

class AppFilterChipItem<T> {
  const AppFilterChipItem({
    required this.value,
    required this.label,
    this.enabled = true,
    this.avatar,
    this.tooltip,
  });

  final T value;
  final String label;
  final bool enabled;
  final Widget? avatar;
  final String? tooltip;
}

class AppFilterChipsBar<T> extends StatelessWidget {
  const AppFilterChipsBar({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.selectionMode = AppFilterSelectionMode.multiple,
    this.layout = AppFilterChipsLayout.horizontal,
    this.isEnabled = true,
    this.spacing = AppSpacing.space8,
    this.runSpacing = AppSpacing.space8,
    this.padding,
    this.showClearAction = false,
    this.clearActionLabel,
    this.onClear,
    this.selectedCountLabelBuilder,
  });
}
```

## Behavioral Contract
1. Selection behavior:
   - `single`: selecting a chip replaces current selection with only that value.
   - `multiple`: selecting a chip toggles its presence in the set.
2. Deselect behavior:
   - Tapping selected chip toggles off in both modes.
3. Clear-all behavior:
   - Optional action shown only when `showClearAction == true`.
   - If `onClear` is not provided, default behavior emits empty set via `onSelectionChanged({})`.
4. Disabled behavior:
   - Whole bar disabled with `isEnabled = false`.
   - Individual chip disabled via `AppFilterChipItem.enabled = false`.
5. Layout:
   - `horizontal`: horizontally scrollable row.
   - `wrap`: multiline wrap for larger widths.

## Architecture Alignment
1. Keep it presentation-only: no business logic or data fetching inside the widget.
2. Parent (Cubit/Bloc page) owns selected filter state and passes `selectedValues` snapshot.
3. Widget emits next state through `onSelectionChanged`, matching existing unidirectional UI state patterns.

## UX / A11y Notes
1. Use `FilterChip` semantics and selected state announcements.
2. Keep touch target and chip spacing aligned with theme/tokens.
3. Avoid hardcoded colors and typography; rely on theme + DS text components where needed.

## Testing Plan
`test/core/design_system/widgets/filter_chips/app_filter_chips_bar_test.dart`

Required tests:
1. Renders all chip labels.
2. Multiple mode toggles add/remove correctly.
3. Single mode enforces exclusivity.
4. Disabled item does not emit changes.
5. Clear action emits empty set (default path).
6. Clear action respects custom `onClear` callback.
7. Renders `Wrap` in wrap layout and horizontal scroll in horizontal layout.

## Rollout Strategy
1. PR 1: Add widget + tests (this proposal scope).
2. PR 2: Migrate one representative feature list/filter screen.
3. PR 3+: Opportunistic migration during feature work.

## Risks and Mitigations
1. API overgrowth:
   - Keep v1 intentionally small and typed.
2. State mismatch in consumers:
   - Document selection contract clearly in widget docs/comments.
3. Style drift:
   - Use DS tokens/theme defaults and keep custom styling minimal.

## Success Criteria
1. Widget is lint-clean and test-covered.
2. Can be dropped into any feature with minimal wiring.
3. Reduces duplicated filter-chip code in upcoming feature work.
