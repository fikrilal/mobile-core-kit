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

## Performance notes

- Prefer a single loading indicator per surface; avoid placing many animated loaders in large lists.
- When loading completes, remove the widget from the tree (or wrap the area in `TickerMode(enabled: isLoading, child: ...)`).
