# Engineering Proposal: `AppPaginatedCollectionView<T>`

## Goal
Create a reusable design-system widget that standardizes paginated collection UX across features:

- Initial loading
- Empty state
- Error state with retry
- Success state
- Pull-to-refresh
- Infinite scroll load-more

This should reduce repeated page-level branching and provide consistent behavior across future list-heavy features.

## Why This Has High ROI
1. Most upcoming product surfaces are collection-driven (inbox, transactions, statements, notifications, search results, activity feeds).
2. The repo already defines backend pagination guidance (`docs/engineering/api/api_pagination_cursor_support.md`) but lacks a UI-level reusable primitive.
3. Without a shared widget, each feature re-implements slightly different loading/empty/error/load-more behavior, causing drift.

## Scope (PR-sized)
### Add
- `lib/core/design_system/widgets/collection/app_paginated_collection_view.dart`
- `lib/core/design_system/widgets/collection/collection.dart`
- `test/core/design_system/widgets/collection/app_paginated_collection_view_test.dart`

### Update
- Documentation usage guidance in `docs/engineering/ui_state_architecture.md` (or a dedicated doc section under `docs/engineering/`).

### Out of Scope (this PR)
- Migrating existing features to use this widget.
- Sliver-first composition.
- Advanced offline/cache semantics.
- Animated list diffing.

## Proposed Public API (v1)
```dart
enum AppCollectionLayout { list, grid }

enum AppCollectionStatus {
  initialLoading,
  refreshLoading,
  success,
  empty,
  failure,
}

class AppPaginatedCollectionView<T> extends StatefulWidget {
  const AppPaginatedCollectionView({
    super.key,
    required this.status,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.hasMore,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.errorTitle,
    this.errorDescription,
    this.emptyTitle,
    this.emptyDescription,
    this.onRetry,
    this.retryLabel,
    this.padding,
    this.layout = AppCollectionLayout.list,
    this.gridDelegate,
    this.separatorBuilder,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThresholdPx = 320,
  });

  final AppCollectionStatus status;
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final bool hasMore;
  final Future<void> Function()? onLoadMore;
  final bool isLoadingMore;

  final String? errorTitle;
  final String? errorDescription;
  final String? emptyTitle;
  final String? emptyDescription;
  final VoidCallback? onRetry;
  final String? retryLabel;

  final EdgeInsetsGeometry? padding;
  final AppCollectionLayout layout;
  final SliverGridDelegate? gridDelegate;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThresholdPx;
}
```

## Behavioral Contract
1. `initialLoading`:
   - Render centered loading view (`AppDotWave` + localized loading copy).
2. `failure`:
   - Render `AppStateMessagePanel`.
   - Show retry CTA only when `onRetry != null`.
3. `empty`:
   - Render `AppEmptyState` with optional override title/description.
4. `success` and `refreshLoading`:
   - Render list/grid collection.
   - Wrap in `RefreshIndicator` to support pull-to-refresh.
5. Infinite load:
   - Trigger `onLoadMore` when remaining extent is below threshold.
   - Guard conditions:
     - `onLoadMore != null`
     - `hasMore == true`
     - `isLoadingMore == false`
     - Local request lock to avoid duplicate dispatches.
6. Footer loading:
   - When `isLoadingMore == true`, append a loading footer row/cell.
7. Layout mode:
   - `list`: `ListView.builder` or `ListView.separated` if separator provided.
   - `grid`: `GridView.builder` and assert `gridDelegate != null`.

## State Ownership and Architecture Alignment
The widget remains presentation-only. Business logic stays in Cubit/Bloc.

Feature state should provide:
- `items: List<T>`
- `status` (or a mapping to `AppCollectionStatus`)
- `hasMore: bool`
- `isLoadingMore: bool`
- Optional error display copy

This aligns with `docs/engineering/ui_state_architecture.md`:
- Centralized state snapshot in Cubit/Bloc
- Rendering delegated to reusable UI components
- Side effects handled in listeners, not build methods

## Edge Cases
1. Empty success:
   - If `status == success` but `items.isEmpty`, render empty state.
2. Failure with stale list items:
   - Recommended feature mapping: keep list visible and show snackbar/banner when stale content exists.
   - Full-page failure panel reserved for `items.isEmpty`.
3. Rapid scroll triggers:
   - Use in-flight lock + `isLoadingMore` guard.
4. Refresh during load-more:
   - External state controls priority; widget does not own data concurrency.

## Testing Plan
Create widget tests in:
`test/core/design_system/widgets/collection/app_paginated_collection_view_test.dart`

Required tests:
1. Renders loading for `initialLoading`.
2. Renders empty state for empty.
3. Renders failure state and retry CTA when configured.
4. Renders list items in success state.
5. Pull-to-refresh calls `onRefresh`.
6. Scroll near threshold triggers `onLoadMore` exactly once per cycle.
7. Does not trigger `onLoadMore` when:
   - `hasMore == false`
   - `isLoadingMore == true`
   - `onLoadMore == null`
8. Renders load-more footer while loading more.
9. Grid mode asserts when `gridDelegate` is missing.

## Rollout Strategy
1. PR 1: Add widget + tests + docs (no feature migrations).
2. PR 2: Migrate one representative list page as reference.
3. PR 3+: Opportunistically migrate other pages during feature work.

## Risks and Mitigations
1. API over-generalization:
   - Keep v1 small and opinionated.
2. Feature-state mismatches:
   - Document status-mapping examples in engineering docs.
3. Performance concerns:
   - Use builder-based rendering and threshold-guarded load-more.

## Success Criteria
1. Widget is lint-clean and tested.
2. Contract is documented and easy to adopt.
3. New list features can ship without re-implementing pagination UX primitives.
