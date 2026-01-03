# Loading

Design-system loading indicators for `mobile-core-kit`.

## Import

Prefer importing via the barrel so feature code stays stable as new indicators
are added:

```dart
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
```

## Components

This folder may contain multiple loading indicators. Keep this doc updated as
new components are added.

### AppLoadingOverlay

Blocking, modal-style overlay loader for full-screen / surface-level loading.

```dart
AppLoadingOverlay(
  isLoading: state.isLoading,
  message: 'Verifying…',
  child: YourScreenBody(),
)
```

### AppDotWave

Small, inline dot-wave loader (good for numeric/value placeholders).

```dart
AppDotWave(
  color: Theme.of(context).colorScheme.primary,
)
```

### AppStartupGate

App-level startup gate that blocks interaction until startup is ready.

This is the preferred approach over an in-app “/splash” route: render the real
router tree immediately, and show a short-lived full-screen overlay only when
startup work takes long enough to be noticeable.

To avoid “blank frames” and prevent premature interaction, the gate mounts an
immediate full-screen backdrop while startup is not ready. The spinner/branding
overlay is still delayed by `showDelay` to avoid flicker on fast startups.

```dart
MaterialApp.router(
  routerConfig: router,
  builder: (context, child) => AppStartupGate(
    listenable: startupController,
    isReady: () => startupController.isReady,
    overlayBuilder: (_) => const AppStartupOverlay(title: 'My App'),
    child: child ?? const SizedBox.shrink(),
  ),
)
```

## Performance notes

- Prefer a single loading indicator per surface; avoid placing many animated loaders in large lists.
- When loading completes, remove the widget from the tree (or wrap the area in `TickerMode(enabled: isLoading, child: ...)`).
