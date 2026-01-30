# App Event Bus

A lightweight publish/subscribe mechanism to broadcast domain-level changes across the app without tight coupling between screens or BLoCs.

The bus streams typed `AppEvent`s (e.g., `ReadingSessionFinished`) so any feature can listen and react (refresh state, update caches, etc.).

## Why
- Decouple features and screens (no route-callback hacks).
- Keep UI consistent across tabs/pages after domain changes.
- Respect Clean Architecture: use cases mutate, BLoCs react by refetching via repositories.

## Key Pieces
- `AppEvent` (sealed-like types):
  - `ReadingSessionFinished(editionId, sessionId)`
  - `ReadingSessionAmended(editionId, sessionId)`
  - `LibraryProgressUpdated(editionId)`
  - `LibraryEntryChanged(editionId)`
- `AppEventBus`: broadcast stream of `AppEvent`, with `publish(event)` and `stream`.
- DI registration in `CoreModule`:
  - `locator.registerLazySingleton<AppEventBus>(() => AppEventBus());`

## When To Publish
Publish after a successful mutation that affects shared UI state. Examples:
- Focus session finished or amended.
- Library entry/progress changed (start, finish, progress update, delete).

## When To Subscribe
Subscribe from presentation-layer BLoCs that show data affected by those events. Examples:
- Sessions history list for an edition.
- Book entry detail (progress/status).
- Reading stats overview.

## How To Publish
Inside a Bloc/use case handler after success:

```dart
import 'package:mobile_core_kit/core/runtime/events/app_event.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';

// In FinishFocusSessionBloc on success
_events.publish(ReadingSessionFinished(editionId, session.id));
```

Where `_events` is injected via DI (`AppEventBus`).

## How To Subscribe (Bloc)
Listen to the bus in the Bloc constructor, filter, then dispatch your own refresh event. Always cancel the subscription in `close()`.

```dart
class SessionsListBloc extends Bloc<SessionsListEvent, SessionsListState> {
  SessionsListBloc({required GetSessionsByEditionUseCase getSessionsByEdition, required AppEventBus events})
      : _getSessionsByEdition = getSessionsByEdition,
        _events = events,
        super(const SessionsListState()) {
    on<SessionsListStarted>(_onStarted);
    on<SessionsListRefreshed>(_onRefreshed);

    _sub = _events.stream.listen((e) {
      if (e is ReadingSessionFinished || e is ReadingSessionAmended) {
        final editionId = (e is ReadingSessionFinished)
            ? e.editionId
            : (e as ReadingSessionAmended).editionId;
        if (editionId == state.editionId && state.editionId.isNotEmpty) {
          add(const SessionsListRefreshed());
        }
      }
    });
  }

  final GetSessionsByEditionUseCase _getSessionsByEdition;
  final AppEventBus _events;
  late final StreamSubscription _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
```

Another example for Entry Detail:

```dart
_sub = _events.stream.listen((e) {
  if (e is ReadingSessionFinished ||
      e is ReadingSessionAmended ||
      e is LibraryProgressUpdated ||
      e is LibraryEntryChanged) {
    final ed = state.editionId;
    if (ed != null && ed.isNotEmpty) {
      final editionId = switch (e) {
        ReadingSessionFinished ev => ev.editionId,
        ReadingSessionAmended ev => ev.editionId,
        LibraryProgressUpdated ev => ev.editionId,
        LibraryEntryChanged ev => ev.editionId,
        _ => '',
      };
      if (editionId == ed) {
        add(GetUserBookByEditionRefreshed(ed));
      }
    }
  }
});
```

## DI Wiring
- Bus registered in `lib/core/di/service_locator.dart`.
- Inject bus into feature DI (e.g., `LibraryModule.register`) and pass to blocs via factories:

```dart
locator.registerFactory<FinishFocusSessionBloc>(() =>
  FinishFocusSessionBloc(finishSession: locator(), events: locator()));
```

## Best Practices
- Keep events small and domain-focused (IDs, minimal payload).
- Filter events early (match `editionId`) to avoid unnecessary work.
- Treat the bus as a signal; fetch authoritative data via repositories.
- Cancel subscriptions in `close()` to avoid leaks.
- Consider debouncing if multiple events may fire in quick succession.

## Testing
- Mock or create a real `AppEventBus` and inject it.
- Publish test events and assert the Bloc emits expected refresh states.
- Verify subscription cleanup by calling `bloc.close()`.

## Extending (Long-Term)
- Add repository-backed streams + small in-memory cache:
  - Repositories expose `watch*` streams and invalidate on relevant events.
  - Blocs subscribe to repo streams for instant updates; bus remains the signal to invalidate/refetch.

```text
AppEventBus: signal changes  →  Repositories: cache + watch streams  →  BLoCs: reflect updates
```

## Quick Checklist
- [ ] Publish event on successful mutation
- [ ] Inject `AppEventBus` into consuming Bloc
- [ ] Subscribe, filter, dispatch refresh
- [ ] Cancel subscription in `close()`
- [ ] Add tests for publish/subscribe paths
