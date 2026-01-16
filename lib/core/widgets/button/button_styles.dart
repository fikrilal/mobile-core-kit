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

    switch (variant) {
      case ButtonVariant.primary:
        return _primaryStyle(
          scheme: scheme,
          height: height,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          isDisabled: isDisabled,
        );
      case ButtonVariant.secondary:
        return _secondaryStyle(
          scheme: scheme,
          height: height,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          isDisabled: isDisabled,
        );
      case ButtonVariant.outline:
        return _outlineStyle(
          scheme: scheme,
          height: height,
          padding: padding,
          borderColor: borderColor,
          foregroundColor: foregroundColor,
          isDisabled: isDisabled,
        );
      case ButtonVariant.danger:
        return _dangerStyle(
          scheme: scheme,
          height: height,
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          isDisabled: isDisabled,
        );
    }
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
      elevation: isDisabled ? 0 : 1,
      shadowColor: scheme.shadow,
    );
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
      elevation: isDisabled ? 0 : 1,
      shadowColor: scheme.shadow,
    );
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
        color: isDisabled
            ? disabledBorder
            : borderColor ?? scheme.outline,
        width: 1,
      ),
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
      elevation: isDisabled ? 0 : 1,
      shadowColor: scheme.shadow,
    );
  }
}
