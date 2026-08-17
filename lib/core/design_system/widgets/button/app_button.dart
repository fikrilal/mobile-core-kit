import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button_styles.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button_variants.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;

  final Widget? icon;
  final Widget? suffixIcon;
  final double? iconSize;
  final double? iconSpacing;

  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  final bool isExpanded;

  final String? semanticLabel;

  final ValueChanged<bool>? onHover;
  final VoidCallback? onLongPress;

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
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    this.semanticLabel,
    this.onHover,
    this.onLongPress,
    this.loadingIndicator,
    this.loadingText,
    this.loadingIndicatorSize,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    this.semanticLabel,
    this.onHover,
    this.onLongPress,
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
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    this.semanticLabel,
    this.onHover,
    this.onLongPress,
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
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    this.semanticLabel,
    this.onHover,
    this.onLongPress,
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
    this.icon,
    this.suffixIcon,
    this.iconSize,
    this.iconSpacing,
    this.backgroundColor,
    this.textColor,
    this.fontWeight,
    this.borderColor,
    this.width,
    this.padding,
    this.margin,
    this.semanticLabel,
    this.onHover,
    this.onLongPress,
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

    if (width != null) {
      buttonChild = SizedBox(width: width, child: buttonChild);
    }

    VoidCallback? handlePress = isButtonDisabled
        ? null
        : () {
            onPressed?.call();
          };

    Widget button = _buildBaseButton(
      context: context,
      onPressed: handlePress,
      style: buttonStyle,
      child: buttonChild,
    );

    button = _wrapWithAccessibility(button);

    if (!isButtonDisabled) {
      button = ZoomTapAnimation(begin: 1.0, end: 0.99, child: button);
    }

    if (margin != null) {
      button = Padding(padding: margin!, child: button);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isExpanded && width == null && constraints.hasBoundedWidth) {
          return SizedBox(width: double.infinity, child: button);
        }
        if (isExpanded && width == null && !constraints.hasBoundedWidth) {
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

  Widget _wrapWithAccessibility(Widget button) {
    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: !isDisabled && !isLoading,
      child: button,
    );
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
