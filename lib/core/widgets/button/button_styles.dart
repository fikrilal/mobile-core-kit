import 'package:flutter/material.dart';

import '../../theme/tokens/sizing.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/system/state_opacities.dart';
import 'button_variants.dart';

class ButtonStyles {
  static ButtonStyle getStyle({
    required BuildContext context,
    required ButtonVariant variant,
    required ButtonSize size,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final height = _getHeight(size);
    final padding = _getPadding(size);
    final labelStyle = _getLabelTextStyle(theme, size);

    final style = switch (variant) {
      ButtonVariant.primary => _primaryStyle(
        scheme: scheme,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        isDisabled: isDisabled,
      ),
      ButtonVariant.secondary => _secondaryStyle(
        scheme: scheme,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        isDisabled: isDisabled,
      ),
      ButtonVariant.outline => _outlineStyle(
        scheme: scheme,
        height: height,
        padding: padding,
        borderColor: borderColor,
        foregroundColor: foregroundColor,
        isDisabled: isDisabled,
      ),
      ButtonVariant.danger => _dangerStyle(
        scheme: scheme,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        isDisabled: isDisabled,
      ),
    };

    return style.copyWith(textStyle: WidgetStatePropertyAll(labelStyle));
  }

  static double _getHeight(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return AppSizing.buttonHeightSmall;
      case ButtonSize.medium:
        return AppSizing.buttonHeightMedium;
      case ButtonSize.large:
        return AppSizing.buttonHeightLarge;
    }
  }

  static EdgeInsets _getPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space4,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.space24,
          vertical: AppSpacing.space12,
        );
    }
  }

  static TextStyle _getLabelTextStyle(ThemeData theme, ButtonSize size) {
    final t = theme.textTheme;
    return switch (size) {
          ButtonSize.small => t.labelSmall,
          ButtonSize.medium => t.labelMedium,
          ButtonSize.large => t.labelLarge,
        } ??
        const TextStyle();
  }

  static ButtonStyle _primaryStyle({
    required ColorScheme scheme,
    required double height,
    required EdgeInsets padding,
    Color? backgroundColor,
    Color? foregroundColor,
    required bool isDisabled,
  }) {
    final disabledBackground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContainer,
    );
    final disabledForeground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContent,
    );

    return ElevatedButton.styleFrom(
      backgroundColor: isDisabled
          ? disabledBackground
          : backgroundColor ?? scheme.primary,
      foregroundColor: isDisabled
          ? disabledForeground
          : foregroundColor ?? scheme.onPrimary,
      minimumSize: Size(0, height),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
      ),
      splashFactory: InkSparkle.splashFactory,
    ).copyWith(elevation: WidgetStateProperty.all(0));
  }

  static ButtonStyle _secondaryStyle({
    required ColorScheme scheme,
    required double height,
    required EdgeInsets padding,
    Color? backgroundColor,
    Color? foregroundColor,
    required bool isDisabled,
  }) {
    final disabledBackground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContainer,
    );
    final disabledForeground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContent,
    );

    return ElevatedButton.styleFrom(
      backgroundColor: isDisabled
          ? disabledBackground
          : backgroundColor ?? scheme.secondary,
      foregroundColor: isDisabled
          ? disabledForeground
          : foregroundColor ?? scheme.onSecondary,
      minimumSize: Size(0, height),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
      ),
      splashFactory: InkSparkle.splashFactory,
    ).copyWith(elevation: WidgetStateProperty.all(0));
  }

  static ButtonStyle _outlineStyle({
    required ColorScheme scheme,
    required double height,
    required EdgeInsets padding,
    Color? borderColor,
    Color? foregroundColor,
    required bool isDisabled,
  }) {
    final disabledForeground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContent,
    );
    final disabledBorder = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContainer,
    );

    return OutlinedButton.styleFrom(
      foregroundColor: isDisabled
          ? disabledForeground
          : foregroundColor ?? scheme.primary,
      minimumSize: Size(0, height),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
      ),
      side: BorderSide(
        color: isDisabled ? disabledBorder : borderColor ?? scheme.outline,
        width: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ButtonStyle _dangerStyle({
    required ColorScheme scheme,
    required double height,
    required EdgeInsets padding,
    Color? backgroundColor,
    Color? foregroundColor,
    required bool isDisabled,
  }) {
    final disabledBackground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContainer,
    );
    final disabledForeground = scheme.onSurface.withValues(
      alpha: StateOpacities.disabledContent,
    );

    return ElevatedButton.styleFrom(
      backgroundColor: isDisabled
          ? disabledBackground
          : backgroundColor ?? scheme.error,
      foregroundColor: isDisabled
          ? disabledForeground
          : foregroundColor ?? scheme.onError,
      minimumSize: Size(0, height),
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.space24),
      ),
      splashFactory: InkSparkle.splashFactory,
    ).copyWith(elevation: WidgetStateProperty.all(0));
  }
}
