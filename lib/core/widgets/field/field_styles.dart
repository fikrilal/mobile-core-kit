import 'package:flutter/material.dart';

import 'package:mobile_core_kit/core/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/theme/system/state_opacities.dart';
import 'package:mobile_core_kit/core/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';

import 'package:mobile_core_kit/core/widgets/field/field_variants.dart';

class FieldStyles {
  FieldStyles._();

  // Size configurations
  static const Map<FieldSize, FieldSizeConfig> _sizeConfigs = {
    FieldSize.small: FieldSizeConfig(
      height: 36.0,
      iconSize: AppSizing.iconSizeSmall,
      borderRadius: 8.0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space8,
      ),
    ),
    FieldSize.medium: FieldSizeConfig(
      height: 44.0,
      iconSize: AppSizing.iconSizeCompact,
      borderRadius: 10.0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
    ),
    FieldSize.large: FieldSizeConfig(
      height: 52.0,
      iconSize: AppSizing.iconSizeMedium,
      borderRadius: 10.0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: AppSpacing.space16,
      ),
    ),
  };

  // Animation configurations
  static const Duration animationDuration = MotionDurations.medium;
  static const Curve animationCurve = Curves.easeInOut;

  // Get size configuration for a field size
  static FieldSizeConfig getSizeConfig(FieldSize size) {
    return _sizeConfigs[size]!;
  }

  // Get input decoration based on variant and state
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required FieldVariant variant,
    required FieldSize size,
    required FieldState state,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
    String? suffixText,
    Color? fillColor,
    Color? borderColor,
    bool isDense = false,
  }) {
    final theme = Theme.of(context);
    final sizeConfig = getSizeConfig(size);
    final colorScheme = theme.colorScheme;

    // Determine colors based on state
    Color getBorderColor() {
      if (borderColor != null) return borderColor;

      switch (state) {
        case FieldState.error:
          return colorScheme.error;
        case FieldState.success:
          return context.semanticColors.success;
        case FieldState.warning:
          return context.semanticColors.warning;
        case FieldState.disabled:
          return colorScheme.onSurface.withValues(
            alpha: StateOpacities.disabledContainer,
          );
        case FieldState.enabled:
          return colorScheme.outline;
      }
    }

    Color getFillColor() {
      if (fillColor != null) return fillColor;

      switch (variant) {
        case FieldVariant.filled:
          return state == FieldState.disabled
              ? colorScheme.surfaceContainerHighest.withValues(
                  alpha: StateOpacities.disabledContainer,
                )
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
        case FieldVariant.primary:
        case FieldVariant.secondary:
        case FieldVariant.outline:
          return state == FieldState.disabled
              ? colorScheme.surface.withValues(
                  alpha: StateOpacities.disabledContainer,
                )
              : colorScheme.surface;
      }
    }

    Color getPrimaryEnabledBorderColor() =>
        state == FieldState.enabled ? colorScheme.primary : getBorderColor();

    Color getSecondaryEnabledBorderColor() =>
        state == FieldState.enabled ? colorScheme.secondary : getBorderColor();

    // Base decoration
    InputDecoration decoration = InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      floatingLabelStyle: theme.textTheme.labelLarge?.copyWith(
        color: colorScheme.primary,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
      isDense: isDense,
      contentPadding: sizeConfig.contentPadding,
      filled: variant == FieldVariant.filled,
      fillColor: getFillColor(),
    );

    // Apply variant-specific styling
    switch (variant) {
      case FieldVariant.primary:
        return decoration.copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getPrimaryEnabledBorderColor()),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getPrimaryEnabledBorderColor()),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getBorderColor()),
          ),
        );

      case FieldVariant.secondary:
        return decoration.copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getSecondaryEnabledBorderColor()),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getSecondaryEnabledBorderColor()),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getBorderColor()),
          ),
        );

      case FieldVariant.outline:
        return decoration.copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getBorderColor()),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getBorderColor()),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: getBorderColor()),
          ),
        );

      case FieldVariant.filled:
        final baseBorderSide = BorderSide(color: getBorderColor(), width: 1.0);

        return decoration.copyWith(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: baseBorderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: baseBorderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
            borderSide: baseBorderSide,
          ),
        );
    }
  }

  // Get text style based on size and state
  static TextStyle getTextStyle({
    required BuildContext context,
    required FieldSize size,
    required FieldState state,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getTextColor() {
      if (textColor != null) return textColor;

      switch (state) {
        case FieldState.disabled:
          return colorScheme.onSurface.withValues(
            alpha: StateOpacities.disabledContent,
          );
        case FieldState.error:
          return colorScheme.error;
        case FieldState.enabled:
        case FieldState.success:
        case FieldState.warning:
          return colorScheme.onSurface;
      }
    }

    final base = switch (size) {
      FieldSize.small => theme.textTheme.bodySmall,
      FieldSize.medium => theme.textTheme.bodyMedium,
      FieldSize.large => theme.textTheme.bodyLarge,
    };

    return (base ?? const TextStyle()).copyWith(
      color: getTextColor(),
      fontWeight: FontWeight.normal,
    );
  }
}

class FieldSizeConfig {
  final double height;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets contentPadding;

  const FieldSizeConfig({
    required this.height,
    required this.iconSize,
    required this.borderRadius,
    required this.contentPadding,
  });
}
