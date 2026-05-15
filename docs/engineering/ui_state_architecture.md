# UI State Architecture — Flutter + BLoC/Cubit (Orymu)

This document defines the presentation‑layer architecture using Flutter BLoC/Cubit. It standardizes a “single state snapshot + explicit one‑shot effects” approach and aligns with conventions in this repo (status enums, skeletons, DI, navigation).

## 1) Goals & Principles

- Single source of truth: one immutable State describes the whole screen.
- Finite state progression: initial → loading → (empty | success | failure [| loadingMore]).
- Unidirectional flow: UI intent → Bloc/Cubit → UseCase(s) → State → UI renders.
- Separation of concerns: presentation (Bloc/Cubit + State), domain (UseCases/Entities), data (repositories).
- Side effects (snackbar/nav) are one‑shots, handled outside of build.
- State is for persistent rendering; effects are for one-shot commands.

## 2) Project Conventions (recap)

- State shape: single Equatable class with `status` enum + UI‑shaped fields; derived getters (`isLoading`, `hasNextPage`, etc.). Example: `lib/features/discover/presentation/bloc/trending/trending_books_state.dart:1`.
- Builders: one `BlocBuilder` switches on `state.status` and returns dedicated methods (`_buildLoading/_buildSuccess/_buildError/_buildLoadingMore`). Example: `lib/features/discover/presentation/pages/discover_page.dart:393`.
- Async renderer: prefer `AppAsyncStateView` (`lib/core/design_system/widgets/async_state/app_async_state_view.dart`) for standard body-level async states (`initial/loading/success/empty/failure`) to reduce duplicated branching.
- Paginated collections: prefer `AppPaginatedCollectionView<T>` (`lib/core/design_system/widgets/collection/app_paginated_collection_view.dart`) for list/grid pages that need pull-to-refresh + infinite load-more + empty/failure consistency.
- Date input: prefer `AppDateField` + `AppDatePickerSheet` (`lib/core/design_system/widgets/date_picker/`) instead of per-feature picker implementations.
- Skeletons: colocate under `presentation/widgets/skeleton/` per feature; keep loading placeholders lightweight and consistent.
- Forms: keep validation real‑time in state, but make error display **touched‑aware** (only show errors for fields the user interacted with). This prevents cross‑field validation from showing “required/empty” on untouched fields.
- DI: register datasources → repositories → usecases → blocs in `features/**/di/*_module.dart`; consume via `locator`.
- Navigation: GoRouter + `ShellRoute` for tabs; shell UI state is a simple Cubit (`lib/features/main/presentation/cubit/shell_cubit.dart:1`).
- Cross‑feature refresh: publish domain events on `AppEventBus`, BLoCs listen and refetch.

## 3) Folder Layout (per slice)

Keep it simple: lists and details use Bloc; forms use Cubit.

```
lib/features/<feature>/<subfeature>/presentation/
  bloc/
    list/
      list_bloc.dart
      list_event.dart
      list_state.dart
    detail/
      detail_bloc.dart
      detail_event.dart
      detail_state.dart
  cubit/
    form/
      form_cubit.dart
      form_state.dart
      form_effect.dart       # required for mutation-heavy slices
  pages/
    list_page.dart
    detail_page.dart
    form_page.dart
```

Naming & file conventions
- Bloc files: use the `part` pattern (consistent with existing code like TrendingBooks):
  - `<slice>_bloc.dart` contains the class and `part` directives.
  - `<slice>_event.dart` and `<slice>_state.dart` include `part of '<slice>_bloc.dart';`.
- Cubit files: no events. Use `<slice>_cubit.dart` and `<slice>_state.dart`; add `<slice>_effect.dart` for mutation flows that emit snackbars, dialogs, navigation, pop results, copy/share/open commands, or parent refresh commands.
- Page files: `<slice>_page.dart` (Stateful if listening to effects, Stateless otherwise).
- Tests mirror lib paths under `test/<feature>/<subfeature>/presentation/...`.

DI and navigation
- DI registration: add Bloc/Cubit factories in `features/<feature>/di/*_module.dart` and resolve with `locator`.
- Route wiring: create providers at route build time and dispatch initial events there (avoid post‑frame in pages).
```
// navigation
GoRoute(
  path: MainRoutes.discover,
  builder: (_, __) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => locator<TrendingBooksBloc>()..add(const TrendingBooksStarted())),
      // Cubit example (form)
      BlocProvider(create: (_) => locator<UpdatePasswordBloc>()), // or Cubit provider if using cubit
    ],
    child: const DiscoverPage(),
  ),
)
```

## 4) State Design (enum status pattern)

Use a single immutable state with a `status` enum and UI‑shaped fields:

```dart
enum SliceStatus { initial, loading, success, failure, loadingMore }

class SliceState extends Equatable {
  const SliceState({
    this.items = const [],
    this.status = SliceStatus.initial,
    this.errorMessage,
    this.page = 1,
    this.hasNextPage = true,
  });

  final List<Item> items;
  final SliceStatus status;
  final String? errorMessage;
  final int page;
  final bool hasNextPage;

  bool get isLoading => status == SliceStatus.loading;
  bool get isLoadingMore => status == SliceStatus.loadingMore;

  SliceState copyWith({
    List<Item>? items,
    SliceStatus? status,
    String? errorMessage,
    int? page,
    bool? hasNextPage,
  }) => SliceState(
        items: items ?? this.items,
        status: status ?? this.status,
        errorMessage: errorMessage,
        page: page ?? this.page,
        hasNextPage: hasNextPage ?? this.hasNextPage,
      );

  @override
  List<Object?> get props => [items, status, errorMessage, page, hasNextPage];
}
```

Tip: keep state UI‑shaped; map DTOs → domain before state.

### State Modeling Policy: Enums vs Sealed Unions

Default: use a single state class with a `status` enum for simple slices. Prefer sealed unions (Freezed union states) for complex slices. Use enum state for ≤3–4 simple statuses; use Freezed union states whenever a slice has mutually‑exclusive fields (pagination, wizards, rich forms).

Rules
- Pick one per slice; do not mix within a slice.
- No mass migration needed—apply unions to new/rewritten complex slices.

Use status enum when
- ≤ 3–4 states; few fields; no mutually exclusive combos.
- Straightforward read/list screens without branching logic.
- Minimal boilerplate and consistency with existing code.

Use sealed unions when
- Multiple mutually exclusive states with state‑specific fields (e.g., success has data/hasNext, failure has message).
- List flows with pagination + filters, multi‑step/wizard flows, complex forms (validation + submission + result).
- You want exhaustive `switch/when` and compile‑time guarantees.

Examples
- Enum: shell/tab UI state, small headers/cards, basic submit flows.
- Unions: Discover list, Flashcard overview list, Library detail with multi‑section loads, rich forms.

Union example (Freezed)
```dart
// states/list_state.dart
@freezed
class ListState with _$ListState {
  const factory ListState.initial() = ListInitial;
  const factory ListState.loading() = ListLoading;
  const factory ListState.success({
    required List<Item> items,
    required bool hasNextPage,
  }) = ListSuccess;
  const factory ListState.failure({required String message}) = ListFailure;
  const factory ListState.loadingMore({
    required List<Item> items, // keep existing items while fetching next page
  }) = ListLoadingMore;
}

// in the page
Widget build(BuildContext context) {
  return BlocBuilder<ListBloc, ListState>(
    builder: (context, state) {
      return switch (state) {
        ListInitial() || ListLoading() => _buildLoading(),
        ListSuccess(:final items, :final hasNextPage) => _buildList(items, hasNextPage),
        ListFailure(:final message) => _buildError(message),
        ListLoadingMore(:final items) => _buildLoadingMore(items),
      };
    },
  );
}
```

## 5) Bloc vs Cubit — When to choose

Default: Cubit‑first. Use Bloc for complex flows. Don’t hesitate to use Bloc when the slice demands stronger orchestration or concurrency control.

- Cubit (controller‑like, methods as intents): simple screens, a few intents (`load()`, `refresh()`, `submit()`), minimal concurrency. Prefer for local/UI state or straightforward server state.
- Bloc (event‑driven): multiple distinct triggers (search, filters, pagination), need advanced concurrency (`droppable/restartable`), or public event API.

Decision matrix

| Factor                 | Pick Cubit when…                                 | Pick Bloc when…                                                     |
|------------------------|---------------------------------------------------|---------------------------------------------------------------------|
| Flow complexity        | ≤ 3 user intents; 1:1 intent → transition         | Many intents; branching; multi‑step wizards                         |
| Concurrency & timing   | Rare; a simple flag/guard works                   | Need debounce/throttle, cancel/restart, or ignore‑while‑loading     |
| Inputs                 | Single source (one widget / one repo call)        | Multiple sources merged (scroll + search + filters + connectivity)  |

Additional considerations
- External streams: If you must merge external signals (connectivity, timers, event bus) and need cancel/restart semantics, prefer Bloc; simple one‑off subscriptions are fine in Cubit.
- Public API boundary: When multiple widgets/services should trigger the same logic without coupling, Bloc’s explicit Event API is cleaner.
- Growth forecast: Start with Cubit; if intents grow (> ~3) or flows branch, upgrade to Bloc early.
- Testing & observability: Both work with `bloc_test`. For complex flows, Events give clearer given/when/then narratives and easier analytics/tracing.
- Performance: Not a deciding factor—pick clarity and maintainability.

Heuristic
- Start Cubit. Switch to Bloc if any apply: needs `droppable()/restartable()`, more than ~3 intents, multiple input sources to orchestrate, or you want a reusable/public Event API.

It’s fine to mix both in the same feature: keep simple slices on Cubit and move list/search/pagination flows to Bloc.

## 6) Intents: Events (Bloc) or Methods (Cubit)

Model user intents and lifecycle explicitly.

- Bloc events: `Started`, `Refreshed`, `FilterChanged(...)`, `NextPageRequested`, `Submitted(...)`.
- Cubit methods: `load()`, `refresh()`, `applyFilter(...)`, `nextPage()`.

Dispatch initial intent at provider creation, not during build:

```dart
BlocProvider(
  create: (_) => locator<TrendingBooksBloc>()..add(const TrendingBooksStarted()),
  child: const DiscoverPage(),
)
```

## 7) One‑Shot Effects (snackbar/nav)

Default policy:

- Query/read flows (`GET`, list/detail loads, refresh, pagination) may be state-only. Render loading/success/empty/failure from state.
- Mutation flows (`POST`, `PATCH`, `PUT`, `DELETE`) should expose explicit one-shot effects for completion/failure commands such as snackbars, dialogs, navigation, pop-with-result, copy/share/open, and parent-refresh commands.
- Do not produce side effects inside `build`.
- Do not store one-shot commands as persistent state.
- If a slice emits effects, keep one page-owned subscription, close the stream in `close()`, and test “emit once” semantics.

State-transition listeners are still acceptable for simple read-flow side effects, dependent loads, or legacy slices, but avoid using persistent status as the command channel for mutation flows. Repeated `resetStatus()` calls just to re-arm snackbars are a signal that the slice wants explicit effects.

### 7.1) Explicit Effects (default for mutations)

Use an effect class when a mutation needs a one-shot command.

```dart
sealed class FormEffect {
  const FormEffect();
}

class ShowSaveSuccess extends FormEffect {
  const ShowSaveSuccess(this.message);
  final String message;
}

class ShowSaveFailure extends FormEffect {
  const ShowSaveFailure(this.message);
  final String message;
}

class NavigateBackWithResult extends FormEffect {
  const NavigateBackWithResult();
}
```

Expose an effect stream from the Cubit/Bloc:

```dart
class FormCubit extends Cubit<FormState> {
  FormCubit(this._submit) : super(const FormState());

  final SubmitFormUseCase _submit;
  final _effects = StreamController<FormEffect>.broadcast();
  Stream<FormEffect> get effects => _effects.stream;

  Future<void> submit() async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: FormStatus.submitting));
    final result = await _submit(state.toRequest());

    result.match(
      (failure) {
        emit(state.copyWith(status: FormStatus.idle, failure: failure));
        _effects.add(ShowSaveFailure(failure.userMessage));
      },
      (_) {
        emit(state.copyWith(status: FormStatus.idle, failure: null));
        _effects.add(const ShowSaveSuccess('Saved'));
        _effects.add(const NavigateBackWithResult());
      },
    );
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
```

Consume effects once from a coordinating widget:

```dart
StreamSubscription<FormEffect>? _effectSub;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _effectSub ??= context.read<FormCubit>().effects.listen((effect) {
    switch (effect) {
      case ShowSaveSuccess(:final message):
        AppSnackBar.showSuccess(context, message: message);
      case ShowSaveFailure(:final message):
        AppSnackBar.showError(context, message: message);
      case NavigateBackWithResult():
        context.pop(true);
    }
  });
}

@override
void dispose() {
  unawaited(_effectSub?.cancel());
  super.dispose();
}
```

### 7.2) Listener-Only Effects (allowed for simple read flows and legacy slices)

Drive effects from state transitions using `BlocListener` and `listenWhen` only when the effect is tightly tied to a read-flow render-state transition, dependent-load trigger, or legacy slice where repeat semantics are not a concern. Do not use this pattern for new mutation snackbar/navigation commands.

```dart
BlocListener<ConnectivityCubit, ConnectivityState>(
  listenWhen: (prev, curr) => prev.status != curr.status,
  listener: (context, state) {
    if (state.status == ConnectivityStatus.restored) {
      context.read<FeedCubit>().refresh();
    }
  },
  child: ...,
)
```

## 7.3) `AppAsyncStateView` Usage Pattern

Use `AppAsyncStateView` for render-only status shells. Keep mutation side effects in explicit effect listeners. For read flows, prefer rendering failure/retry UI from state instead of adding snackbars by default.

```dart
BlocBuilder<SliceCubit, SliceState>(
  builder: (context, state) {
    return AppAsyncStateView<SliceState>(
      status: _mapStatus(state),
      failure: state,
      loadingBuilder: (_) => const SliceSkeleton(),
      emptyBuilder: (_) => const SliceEmptyView(),
      successBuilder: (_) => SliceContent(data: state.items),
      failureBuilder: (_, failedState) => SliceErrorView(
        onRetry: () => context.read<SliceCubit>().refresh(),
        failure: failedState?.failure,
      ),
    );
  },
);
```

Notes:
- `AppAsyncStateView` is render-only; do not trigger navigation/snackbars inside builders.
- For submit-heavy forms, keep button-level loading/error handling in the form itself; use `AppAsyncStateView` when the whole body state changes.

Testing effects
- Explicit effect approach: subscribe to `effects`, trigger the intent, expect the exact command sequence, and verify the stream is closed in `close()`.
- Listener approach: assert that a given state transition (e.g., loading → failure) occurs exactly once.

## 8) Builder Pattern (rendering)

Use a single builder per slice and small helpers, matching the repo’s pattern:

```dart
BlocBuilder<SliceBloc, SliceState>(
  builder: (context, state) {
    return switch (state.status) {
      SliceStatus.initial || SliceStatus.loading => _buildLoading(),
      SliceStatus.success => _buildSuccess(state),
      SliceStatus.failure => _buildError(state.errorMessage),
      SliceStatus.loadingMore => _buildLoadingMore(state),
    };
  },
)
```

Guidelines:
- Keep `_build*` methods small and UI‑shaped.
- Use `buildWhen` to limit rebuilds when possible.
- Place skeletons in `widgets/skeleton/` and reuse theme tokens (spacing, colors, text).

Good references:
- Discover grid: `lib/features/discover/presentation/pages/discover_page.dart:387`
- Flashcard overview: `lib/features/flashcard/subfeatures/overview/presentation/pages/flashcard_page.dart:147`
- Library detail stats: `lib/features/library/subfeatures/detail/presentation/pages/content/overview_content.dart:314`

## 9) Lifecycle Triggers (avoid post‑frame hacks)

- Initial loads: dispatch at provider creation.
  - Example (route level): `lib/navigation/main/main_routes_list.dart:33,49`.
- Dependent loads: react to upstream state via listeners, not `addPostFrameCallback`.
  - For edition‑dependent stats, prefer a `BlocListener<GetUserBookByEditionBloc, ...>` that triggers stats fetch when `editionId` changes, instead of calling inside `build`.

## 10) Concurrency & Race Conditions

- Guard in state: `isLoadingMore`, `hasNextPage` (already used in Discover & Flashcard).
- For Bloc event streams, apply transformers (add `bloc_concurrency` dependency if needed):
  - Pagination: `droppable()` (ignore while in‑flight).
  - Search/filter: `restartable()` (cancel previous, keep latest).
  - Queued actions: `sequential()`.

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;

on<NextPageRequested>(_onNext, transformer: bc.droppable());
on<FilterChanged>(_onFilterChanged, transformer: bc.restartable());
```

Also debounce text input before emitting events (e.g., 300–400ms).

### 10.1 Concurrency base classes (recommended)

To avoid copy‑pasting transformers, define tiny base classes that standardize safe defaults. Features inherit and implement only the data‑loading logic.

Dependencies
- Add `bloc_concurrency` to `pubspec.yaml` and import it as `bc`.

Paged lists (NextPageRequested → droppable, SearchChanged → restartable)
```dart
// core/presentation/bloc/paged_bloc_base.dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;

sealed class PagedEvent { const PagedEvent(); }
class PagedStarted extends PagedEvent { const PagedStarted(); }
class SearchChanged extends PagedEvent { const SearchChanged(this.query); final String query; }
class NextPageRequested extends PagedEvent { const NextPageRequested(); }

abstract class PagedBlocBase<S> extends Bloc<PagedEvent, S> {
  PagedBlocBase(S initial) : super(initial) {
    on<PagedStarted>(_onStarted);
    on<SearchChanged>(_onSearchChanged, transformer: bc.restartable());
    on<NextPageRequested>(_onNextPageRequested, transformer: bc.droppable());
  }

  // Implement in subclasses
  Future<void> loadFirstPage(Emitter<S> emit);
  Future<void> applySearch(String query, Emitter<S> emit);
  Future<void> loadNextPage(Emitter<S> emit);

  Future<void> _onStarted(PagedStarted e, Emitter<S> emit) => loadFirstPage(emit);
  Future<void> _onSearchChanged(SearchChanged e, Emitter<S> emit) => applySearch(e.query, emit);
  Future<void> _onNextPageRequested(NextPageRequested e, Emitter<S> emit) => loadNextPage(emit);
}
```

Usage (example)
```dart
class TrendingBooksBloc extends PagedBlocBase<TrendingBooksState> {
  TrendingBooksBloc(this._getTrending) : super(const TrendingBooksState());
  final GetTrendingBooksUseCase _getTrending;

  @override
  Future<void> loadFirstPage(Emitter<TrendingBooksState> emit) async {
    emit(state.copyWith(status: TrendingBooksStatus.loading, page: 1));
    final res = await _getTrending(page: 1, limit: state.limit);
    res.fold(
      (f) => emit(state.copyWith(status: TrendingBooksStatus.failure, errorMessage: f.userMessage)),
      (p) => emit(state.copyWith(status: TrendingBooksStatus.success, items: p.items, hasNextPage: p.hasNext)),
    );
  }

  @override
  Future<void> applySearch(String query, Emitter<TrendingBooksState> emit) async {
    emit(state.copyWith(status: TrendingBooksStatus.loading, page: 1));
    // call search usecase; on success update items + hasNextPage
  }

  @override
  Future<void> loadNextPage(Emitter<TrendingBooksState> emit) async {
    if (!state.hasNextPage || state.isLoadingMore) return;
    final next = state.page + 1;
    emit(state.copyWith(status: TrendingBooksStatus.loadingMore, page: next));
    final res = await _getTrending(page: next, limit: state.limit);
    res.fold(
      (f) => emit(state.copyWith(status: TrendingBooksStatus.failure, errorMessage: f.userMessage, page: next - 1)),
      (p) => emit(state.copyWith(status: TrendingBooksStatus.success, items: [...state.items, ...p.items], hasNextPage: p.hasNext)),
    );
  }
}
```

Notes
- Standardize event names (`PagedStarted`, `SearchChanged`, `NextPageRequested`) to maximize reuse.
- For simple lists without search, you may ignore `SearchChanged` in the subclass.
- UI still guards with `hasNextPage` and shows `_buildLoadingMore` while fetching.

## 11) Navigation & Tabs

- Shell layout: `ShellRoute` provides `child` (active tab body); bottom nav is a separate widget.
- Keep tab pages alive with `AutomaticKeepAliveClientMixin` to avoid churn.
- Shell UI state is held in `ShellCubit` (index + navbar visibility): `lib/features/main/presentation/cubit/shell_cubit.dart:1`.

## 12) Cross‑Feature Refresh via Event Bus

- Publish domain events after successful mutations (`ReadingSessionFinished`, `LibraryEntryChanged`).
- Listen in presentation BLoCs and dispatch refresh events; cancel subscription in `close()`.
- Bus: `lib/core/runtime/events/app_event_bus.dart:1` (usage patterns in `lib/core/runtime/events/README.md:1`).

## 13) Checklists

New list/paginated screen
- [ ] State: items, status enum, page, hasNextPage, errorMessage.
- [ ] Events/Methods: Started/Refreshed, FilterChanged, NextPageRequested.
- [ ] Guard: ignore when `isLoadingMore == true` or `hasNextPage == false`.
- [ ] UI: one builder + `_build*`; skeletons under `widgets/skeleton/`.
- [ ] Effects: usually none; render GET failures inline through state. Use an explicit effect only for exceptional one-shot read commands.
- [ ] Concurrency: `droppable()` for next page; `restartable()` for filter/search.
- [ ] Initial dispatch at provider creation.

Form/submit flow
- [ ] State: fields, validation errors, `FormStatus { idle, submitting, success, failure }`, message.
- [ ] Method/Event: `submitted()` or `Submitted(...)`.
- [ ] UI: disable while submitting; success/failure handled via listener.
- [ ] Effects: explicit `<slice>_effect.dart` for snackbar/dialog/navigation/pop-result.
- [ ] Tests: assert submit state transitions and emitted effects.

Detail screen with dependent blocks
- [ ] Listen to ID changes (from parent Bloc) via `BlocListener` and refetch dependents.
- [ ] Avoid calling side‑effects in `build`.

## 14) Testing

- Use `bloc_test` to assert event → state sequences and effect emissions.
- Mock use cases; test loading/success/error and pagination guards.
- For mutation effects, subscribe to `effects`, trigger the intent, and assert the right commands are emitted once and in order.

Appendix: Good in‑repo references
- Discover trending (status + pagination): `lib/features/discover/presentation/bloc/trending/trending_books_state.dart:1`, `lib/features/discover/presentation/bloc/trending/trending_books_bloc.dart:1`.
- Discover page builder pattern: `lib/features/discover/presentation/pages/discover_page.dart:387`.
- Flashcard overview builder pattern: `lib/features/flashcard/subfeatures/overview/presentation/pages/flashcard_page.dart:147`.
- Shell Cubit (nav UI state): `lib/features/main/presentation/cubit/shell_cubit.dart:1`.
- Router + ShellRoute: `lib/navigation/main/main_routes_list.dart:22`.
