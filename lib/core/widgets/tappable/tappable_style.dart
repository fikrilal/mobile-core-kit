import 'package:mobile_core_kit/core/theme/system/motion_durations.dart';

/// Style presets for [AppTappable] widget.
///
/// Each preset provides a different intensity of touch feedback:
/// - [subtle]: Light background shift only, no scale animation
/// - [standard]: Scale animation + background highlight + ripple (default)
/// - [bold]: More pronounced scale + stronger ripple effect
enum TappableStyle {
  /// Minimal feedback - just a light background color shift.
  /// Best for dense lists or subtle interactive elements.
  subtle,

  /// Balanced feedback with scale, highlight, and ripple.
  /// Recommended for most use cases like settings rows, menu items.
  standard,

  /// Pronounced feedback for primary actions.
  /// Best for cards or large touch targets.
  bold,
}

/// Configuration extension for [TappableStyle].
extension TappableStyleConfig on TappableStyle {
  /// Scale factor when pressed (1.0 = no scale).
  double get scaleFactor {
    switch (this) {
      case TappableStyle.subtle:
        return 1.0; // No scale animation
      case TappableStyle.standard:
        return 0.99;
      case TappableStyle.bold:
        return 0.96;
    }
  }

  /// Duration of the press animation.
  Duration get animationDuration {
    switch (this) {
      case TappableStyle.subtle:
        return MotionDurations.quick;
      case TappableStyle.standard:
        return MotionDurations.short;
      case TappableStyle.bold:
        return MotionDurations.medium;
    }
  }

  /// Whether to show ripple effect.
  bool get showRipple => true;

  /// Whether to show background highlight on press.
  bool get showHighlight => true;
}
