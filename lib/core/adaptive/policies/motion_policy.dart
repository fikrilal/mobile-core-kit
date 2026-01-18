import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';

/// Policy for motion preferences (reduce motion).
///
/// This reads platform accessibility signals (via [MediaQueryData]) and exposes
/// a stable boolean in [MotionSpec] that widgets can respect.
sealed class MotionPolicy {
  const MotionPolicy();

  /// Standard policy: reduced motion when animations are disabled or when
  /// accessible navigation is enabled.
  const factory MotionPolicy.standard() = _StandardMotionPolicy;

  /// Derives [MotionSpec] from the current [MediaQueryData].
  MotionSpec derive({required MediaQueryData media});
}

class _StandardMotionPolicy extends MotionPolicy {
  const _StandardMotionPolicy();

  @override
  MotionSpec derive({required MediaQueryData media}) {
    final reduceMotion = media.disableAnimations || media.accessibleNavigation;
    return MotionSpec(reduceMotion: reduceMotion);
  }
}
