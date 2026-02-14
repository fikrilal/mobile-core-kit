import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';

class AppSearchStyle {
  const AppSearchStyle({
    this.searchRadius = AppRadii.radius24,
    this.searchVerticalPadding = AppSpacing.space12,
    this.searchHorizontalPadding = AppSpacing.space12,
    this.inputHorizontalInset = AppSpacing.space8,
    this.borderWidth = AppSpacing.space1,
    this.focusedBorderWidth = AppSpacing.space2,
  });

  final double searchRadius;
  final double searchVerticalPadding;
  final double searchHorizontalPadding;
  final double inputHorizontalInset;
  final double borderWidth;
  final double focusedBorderWidth;
}

class AppSearchPalette {
  const AppSearchPalette({
    required this.shellBackground,
    required this.shellBorder,
    required this.shellIconForeground,
    required this.shellText,
    required this.shellHint,
    required this.shellCursor,
    required this.shellDisabledBackground,
    required this.shellDisabledText,
  });

  final Color shellBackground;
  final Color shellBorder;
  final Color shellIconForeground;
  final Color shellText;
  final Color shellHint;
  final Color shellCursor;
  final Color shellDisabledBackground;
  final Color shellDisabledText;
}

AppSearchPalette resolveAppSearchPalette(
  BuildContext context, {
  required bool enabled,
  required bool focused,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  final shellBorder = focused && enabled
      ? colorScheme.primary
      : colorScheme.outlineVariant;

  return AppSearchPalette(
    shellBackground: colorScheme.surfaceContainerLow,
    shellBorder: shellBorder,
    shellIconForeground: colorScheme.onSurfaceVariant,
    shellText: enabled ? context.textPrimary : context.textDisabled,
    shellHint: context.textSecondary,
    shellCursor: colorScheme.primary,
    shellDisabledBackground: colorScheme.surfaceContainerLowest,
    shellDisabledText: context.textDisabled,
  );
}
