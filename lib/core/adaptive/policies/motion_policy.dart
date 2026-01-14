import 'package:flutter/widgets.dart';

import '../adaptive_spec.dart';

sealed class MotionPolicy {
  const MotionPolicy();

  const factory MotionPolicy.standard() = _StandardMotionPolicy;

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
