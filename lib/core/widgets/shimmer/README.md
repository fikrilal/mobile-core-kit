# Shimmer

Lightweight shimmer effect for skeleton/loading UI.

## Usage

Import the barrel:

```dart
import 'package:mobile_core_kit/core/widgets/shimmer/shimmer.dart';
```

Wrap your skeleton layout:

```dart
ShimmerComponent.fromColors(
  baseColor: const Color(0xFFE0E0E0),
  highlightColor: const Color(0xFFF5F5F5),
  child: Column(
    children: [
      ShimmerBox(width: double.infinity, height: 16),
      SizedBox(height: 12),
      ShimmerBox(width: 180, height: 16),
    ],
  ),
);
```

## Performance guidance

- Prefer **one** `ShimmerComponent` wrapping an entire skeleton screen instead of many shimmers in a list (each `ShimmerComponent` owns its own ticker/controller).
- Keep shimmering areas small; avoid applying shimmer to full-screen, complex trees when a simple skeleton layout is enough.
- Use `enabled: false` to render the child without shader/compositing work (e.g., after data loads).

