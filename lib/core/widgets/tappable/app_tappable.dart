import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../theme/extensions/theme_extensions_utils.dart';
import '../common/app_haptic_feedback.dart';
import 'tappable_style.dart';

/// A customizable tappable wrapper with smooth touch feedback.
///
/// Combines multiple feedback effects for a polished interaction:
/// - **Scale animation** - Subtle shrink on press
/// - **Background highlight** - Color transition on press
/// - **Ripple effect** - Material ripple from touch point
/// - **Haptic feedback** - Optional vibration
///
/// Example usage:
/// ```dart
/// AppTappable(
///   onTap: () => Navigator.push(...),
///   borderRadius: BorderRadius.circular(12),
///   child: Row(
///     children: [
///       AppIconBadge(...),
///       Text('Settings'),
///     ],
///   ),
/// )
/// ```
class AppTappable extends StatelessWidget {
  const AppTappable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.style = TappableStyle.standard,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.highlightColor,
    this.splashColor,
    this.splashOverlay = true,
    this.hapticFeedback,
    this.enabled = true,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  /// The child widget to wrap.
  final Widget child;

  /// Called when the user taps.
  final VoidCallback? onTap;

  /// Called when the user long-presses.
  final VoidCallback? onLongPress;

  /// Called when the user double-taps.
  final VoidCallback? onDoubleTap;

  /// Style preset controlling animation intensity.
  final TappableStyle style;

  /// Border radius for clipping the ripple effect.
  final BorderRadius? borderRadius;

  /// Internal padding around the child.
  final EdgeInsetsGeometry? padding;

  /// Background color (defaults to transparent).
  final Color? backgroundColor;

  /// Highlight color shown on press (defaults to theme-based).
  final Color? highlightColor;

  /// Ripple/splash color (defaults to theme-based).
  final Color? splashColor;

  /// Whether splash appears on top of the child (Wise-style) or below.
  ///
  /// - `true` (default): Splash overlays the child content
  /// - `false`: Splash appears behind the child (traditional InkWell behavior)
  final bool splashOverlay;

  /// Optional haptic feedback on tap.
  final AppHapticFeedback? hapticFeedback;

  /// Whether the tappable is enabled.
  final bool enabled;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Whether to exclude from semantics tree.
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || (onTap == null && onLongPress == null);

    // Theme-aware colors
    final effectiveHighlight =
        highlightColor ?? context.grey.grey300.withValues(alpha: 0.08);
    final effectiveSplash =
        splashColor ?? context.grey.grey300.withValues(alpha: 0.12);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    Widget content = child;

    // Apply padding if specified
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Build the tappable area based on splash mode
    Widget tappable;

    if (splashOverlay) {
      // Splash on TOP of child (Wise-style)
      // Uses Stack with InkResponse overlay
      tappable = Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: effectiveBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Child content (below)
            content,
            // Ink overlay (on top)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : _handleTap,
                  onLongPress: isDisabled ? null : onLongPress,
                  onDoubleTap: isDisabled ? null : onDoubleTap,
                  borderRadius: effectiveBorderRadius,
                  highlightColor: style.showHighlight
                      ? effectiveHighlight
                      : null,
                  splashColor: style.showRipple ? effectiveSplash : null,
                  splashFactory: InkSparkle.splashFactory,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Splash BELOW child (traditional InkWell behavior)
      tappable = Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: isDisabled ? null : _handleTap,
          onLongPress: isDisabled ? null : onLongPress,
          onDoubleTap: isDisabled ? null : onDoubleTap,
          borderRadius: effectiveBorderRadius,
          highlightColor: style.showHighlight ? effectiveHighlight : null,
          splashColor: style.showRipple ? effectiveSplash : null,
          splashFactory: InkSparkle.splashFactory,
          child: content,
        ),
      );
    }

    // Add scale animation for non-subtle styles
    if (!isDisabled && style.scaleFactor < 1.0) {
      tappable = ZoomTapAnimation(
        begin: 1.0,
        end: style.scaleFactor,
        beginDuration: style.animationDuration,
        endDuration: Duration(
          milliseconds: (style.animationDuration.inMilliseconds * 0.8).round(),
        ),
        beginCurve: Curves.easeOutCubic,
        endCurve: Curves.easeInCubic,
        child: tappable,
      );
    }

    // Wrap with semantics
    if (!excludeSemantics) {
      tappable = Semantics(
        label: semanticLabel,
        button: onTap != null,
        enabled: enabled,
        child: tappable,
      );
    }

    return tappable;
  }

  void _handleTap() {
    _triggerHaptic();
    onTap?.call();
  }

  void _triggerHaptic() {
    if (hapticFeedback == null) return;

    switch (hapticFeedback!) {
      case AppHapticFeedback.lightImpact:
        HapticFeedback.lightImpact();
      case AppHapticFeedback.mediumImpact:
        HapticFeedback.mediumImpact();
      case AppHapticFeedback.heavyImpact:
        HapticFeedback.heavyImpact();
      case AppHapticFeedback.selectionClick:
        HapticFeedback.selectionClick();
      case AppHapticFeedback.vibrate:
        HapticFeedback.vibrate();
    }
  }
}
