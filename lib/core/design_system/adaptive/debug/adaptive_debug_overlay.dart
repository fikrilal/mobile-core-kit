import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/design_system/adaptive/debug/adaptive_debug_banner.dart';

/// Debug-only overlay that renders [AdaptiveDebugBanner] on top of the app.
///
/// Intended usage (debug only):
/// ```dart
/// Stack(
///   children: [
///     AdaptiveScope(...),
///     if (kDebugMode) const AdaptiveDebugOverlay(),
///   ],
/// )
/// ```
class AdaptiveDebugOverlay extends StatelessWidget {
  const AdaptiveDebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topLeft,
            child: const AdaptiveDebugBanner(),
          ),
        ),
      ),
    );
  }
}
