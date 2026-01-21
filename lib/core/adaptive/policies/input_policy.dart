import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';

/// Policy for deriving input capabilities (touch vs pointer vs mixed).
///
/// This is intentionally conservative:
/// - On Android/iOS, touch is assumed unless a mouse/trackpad is connected.
/// - On other platforms, pointer is assumed when a mouse is connected.
///
/// Note: Flutter does not always rebuild `MediaQuery` when pointer devices are
/// connected/disconnected. `AdaptiveScope` includes a small listener to ensure
/// input capability changes can trigger a rebuild.
sealed class InputPolicy {
  const InputPolicy();

  /// Standard policy based on connected mouse/trackpad and platform.
  const factory InputPolicy.standard() = _StandardInputPolicy;

  /// Derives [InputSpec] from the current environment.
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
