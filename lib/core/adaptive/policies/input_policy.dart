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
    final hoverEnabled = _mouseIsConnected();

    final mode = switch (platform) {
      TargetPlatform.android ||
      TargetPlatform.iOS => hoverEnabled ? InputMode.mixed : InputMode.touch,
      _ => hoverEnabled ? InputMode.pointer : InputMode.mixed,
    };

    return InputSpec(mode: mode, pointerHoverEnabled: hoverEnabled);
  }

  bool _mouseIsConnected() {
    try {
      return RendererBinding.instance.mouseTracker.mouseIsConnected;
    } catch (_) {
      // Unit tests may call pure builders without initializing the binding.
      return false;
    }
  }
}
