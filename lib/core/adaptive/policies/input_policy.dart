import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../adaptive_spec.dart';

sealed class InputPolicy {
  const InputPolicy();

  const factory InputPolicy.standard() = _StandardInputPolicy;

  InputSpec derive({
    required MediaQueryData media,
    required TargetPlatform platform,
  });
}

class _StandardInputPolicy extends InputPolicy {
  const _StandardInputPolicy();

  @override
  InputSpec derive({
    required MediaQueryData media,
    required TargetPlatform platform,
  }) {
    final hoverEnabled = _pointerHoverEnabled(platform: platform);

    final mode = switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => hoverEnabled
          ? InputMode.mixed
          : InputMode.touch,
      _ => hoverEnabled ? InputMode.pointer : InputMode.mixed,
    };

    return InputSpec(
      mode: mode,
      pointerHoverEnabled: hoverEnabled,
    );
  }

  bool _pointerHoverEnabled({required TargetPlatform platform}) {
    // MediaQueryData does not currently expose pointer-hover capability.
    // For mobile-first apps, we treat iOS/Android as touch-first by default.
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      return false;
    }

    // Best-effort for non-mobile platforms.
    return RendererBinding.instance.mouseTracker.mouseIsConnected;
  }
}
