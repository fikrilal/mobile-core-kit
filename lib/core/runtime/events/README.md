# App Event Bus

`AppEventBus` is a lightweight publish/subscribe stream for truly cross-cutting
runtime events.

Current global events are intentionally small:
- `SessionExpired(reason?)`
- `SessionCleared(reason?)`

If an event is feature-specific, keep it in that feature instead of adding it to
`lib/core/runtime/events/app_event.dart`.

## Why
- Decouple runtime coordination without tight feature coupling.
- Let listeners react to session lifecycle changes (clear caches, reset state,
  redirect flows).

## Core Files
- `lib/core/runtime/events/app_event.dart`
- `lib/core/runtime/events/app_event_bus.dart`
- `lib/core/di/registrars/core_runtime_registrar.dart`

## DI Registration
`AppEventBus` is registered as a lazy singleton in the core runtime registrar:

```dart
locator.registerLazySingleton<AppEventBus>(() => AppEventBus());
```

## Publish
Publish events after successful lifecycle mutations:

```dart
events.publish(const SessionExpired(reason: 'refresh_failed'));
events.publish(const SessionCleared(reason: 'logout'));
```

## Subscribe
Subscribe in services/BLoCs that need to react, then cancel on dispose/close:

```dart
_sub = events.stream.listen((event) {
  if (event is SessionExpired || event is SessionCleared) {
    // clear derived state / refresh / navigate
  }
});
```

## Best Practices
- Keep global events minimal and domain-focused.
- Put feature-local events under `features/<feature>/...`.
- Treat events as signals; read authoritative state from repositories/services.
- Always cancel subscriptions to avoid leaks.
