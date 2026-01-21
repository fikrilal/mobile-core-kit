import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_core_kit/core/widgets/button/button_styles.dart';
import 'package:mobile_core_kit/core/widgets/button/button_variants.dart';
import 'package:mobile_core_kit/core/widgets/common/app_haptic_feedback.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AppButton extends StatelessWidget {
  // Core functionality
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;

  // Icons & content
  final Widget? icon;
  final Widget? suffixIcon;
  final double? iconSize;
  final double? iconSpacing;

  // Visual customization
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  // Layout helpers
  final bool isExpanded; // Fill available width when constraints are bounded

  // Accessibility
  final String? semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;

  // Focus & interaction
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<bool>? onHover;
  final VoidCallback? onLongPress;
  final bool enableFeedback;
  final AppHapticFeedback? hapticFeedback;

  // Loading customization
  final Widget? loadingIndicator;
  final String? loadingText;
  final double? loadingIndicatorSize;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    // Icons & content
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    // Visual customization
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHover,
    this.onLongPress,
    this.enableFeedback = true,
    this.hapticFeedback,
    // Loading customization
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  });

  // Named constructors for convenience
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    // Icons & content
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    // Visual customization
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHover,
    this.onLongPress,
    this.enableFeedback = true,
    this.hapticFeedback,
    // Loading customization
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  }) : variant = ButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    // Icons & content
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    // Visual customization
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHover,
    this.onLongPress,
    this.enableFeedback = true,
    this.hapticFeedback,
    // Loading customization
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  }) : variant = ButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    // Icons & content
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    // Visual customization
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHover,
    this.onLongPress,
    this.enableFeedback = true,
    this.hapticFeedback,
    // Loading customization
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  }) : variant = ButtonVariant.outline;

  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    // Icons & content
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    // Visual customization
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.onHover,
    this.onLongPress,
    this.enableFeedback = true,
    this.hapticFeedback,
    // Loading customization
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  }) : variant = ButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = isDisabled || isLoading;
    final buttonStyle = ButtonStyles.getStyle(
      context: context,
      variant: variant,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      borderColor: borderColor,
      isDisabled: isButtonDisabled,
    );

    Widget buttonChild = _buildButtonContent(context);

    // Apply sizing constraints
    if (width != null) {
      buttonChild = SizedBox(width: width, child: buttonChild);
    }

    // Handle press with haptic feedback
    VoidCallback? handlePress = isButtonDisabled
        ? null
        : () {
            _triggerHapticFeedback();
            onPressed?.call();
          };

    Widget button = _buildBaseButton(
      context: context,
      onPressed: handlePress,
      style: buttonStyle,
      child: buttonChild,
    );

    // Wrap with accessibility features
    button = _wrapWithAccessibility(button);

    // Wrap with focus management
    button = _wrapWithFocusManagement(button);

    // Add subtle zoom interaction on tap for enabled buttons.
    if (!isButtonDisabled) {
      button = ZoomTapAnimation(begin: 1.0, end: 0.99, child: button);
    }

    // Apply margin if specified
    if (margin != null) {
      button = Padding(padding: margin!, child: button);
    }

    // Apply safe expansion: only when width is bounded
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isExpanded && width == null && constraints.hasBoundedWidth) {
          return SizedBox(width: double.infinity, child: button);
        }
        if (isExpanded && width == null && !constraints.hasBoundedWidth) {
          // In unbounded contexts (e.g., Row), advise using Expanded externally
          debugPrint(
            'AppButton.isExpanded ignored: parent has unbounded width. Wrap with Expanded in a Row/Column.',
          );
        }
        return button;
      },
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final effectiveIconSize = iconSize ?? _getIconSize();
    final effectiveIconSpacing = iconSpacing ?? 8.0;

    if (isLoading) {
      final indicatorSize = loadingIndicatorSize ?? effectiveIconSize;
      final indicator =
          loadingIndicator ??
          _buildDefaultLoadingIndicator(size: indicatorSize);

      final label = loadingText ?? text;
      final textWidget = _buildLabel(context, label);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          indicator,
          SizedBox(width: effectiveIconSpacing),
          textWidget,
        ],
      );
    }

    if (icon != null || suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            SizedBox(
              width: effectiveIconSize,
              height: effectiveIconSize,
              child: icon!,
            ),
            SizedBox(width: effectiveIconSpacing),
          ],
          Flexible(child: _buildLabel(context, text)),
          if (suffixIcon != null) ...[
            SizedBox(width: effectiveIconSpacing),
            SizedBox(
              width: effectiveIconSize,
              height: effectiveIconSize,
              child: suffixIcon!,
            ),
          ],
        ],
      );
    }

    return Center(child: _buildLabel(context, text));
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: fontWeight == null ? null : TextStyle(fontWeight: fontWeight),
    );
  }

  Widget _buildDefaultLoadingIndicator({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: Builder(
        builder: (context) {
          final resolved =
              IconTheme.of(context).color ??
              DefaultTextStyle.of(context).style.color ??
              _getDefaultTextColor(context);

          return CircularProgressIndicator(strokeWidth: 2, color: resolved);
        },
      ),
    );
  }

  // Build the base button widget based on variant
  Widget _buildBaseButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required ButtonStyle? style,
    required Widget child,
  }) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        return ElevatedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: style,
          child: child,
        );
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: onHover,
          style: style,
          child: child,
        );
    }
  }

  // Wrap button with accessibility features
  Widget _wrapWithAccessibility(Widget button) {
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: button);
    }

    Widget accessibleButton = button;

    if (tooltip != null) {
      accessibleButton = Tooltip(message: tooltip!, child: accessibleButton);
    }

    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: !isDisabled && !isLoading,
      child: accessibleButton,
    );
  }

  // Wrap button with focus management
  Widget _wrapWithFocusManagement(Widget button) {
    if (focusNode != null || autofocus || onFocusChange != null) {
      return Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        onFocusChange: onFocusChange,
        child: button,
      );
    }
    return button;
  }

  // Trigger haptic feedback based on configuration
  void _triggerHapticFeedback() {
    if (!enableFeedback || hapticFeedback == null) return;

    switch (hapticFeedback!) {
      case AppHapticFeedback.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case AppHapticFeedback.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case AppHapticFeedback.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case AppHapticFeedback.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case AppHapticFeedback.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  Color _getDefaultTextColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return Theme.of(context).colorScheme.onSecondary;
      case ButtonVariant.outline:
        return Theme.of(context).colorScheme.primary;
      case ButtonVariant.danger:
        return Theme.of(context).colorScheme.onError;
    }
  }
}

// Enum for haptic feedback types
// AppHapticFeedback lives in core/widgets/common/app_haptic_feedback.dart
