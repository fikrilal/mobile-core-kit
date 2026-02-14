import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';

class AppSearchStyle {
  const AppSearchStyle({
    this.searchRadius = AppRadii.radius24,
    this.panelRadius = AppRadii.radius24,
    this.searchVerticalPadding = AppSpacing.space12,
    this.searchHorizontalPadding = AppSpacing.space12,
    this.inputHorizontalInset = AppSpacing.space8,
    this.panelMaxHeight = 360,
    this.panelVerticalPadding = AppSpacing.space8,
    this.panelHorizontalPadding = AppSpacing.space8,
    this.itemVerticalPadding = AppSpacing.space12,
    this.itemHorizontalPadding = AppSpacing.space12,
    this.itemRadius = AppRadii.radius12,
    this.borderWidth = AppSpacing.space1,
    this.focusedBorderWidth = AppSpacing.space2,
    this.showSectionDividers = true,
  }) : assert(panelMaxHeight > 0, 'panelMaxHeight must be greater than zero.');

  final double searchRadius;
  final double panelRadius;
  final double searchVerticalPadding;
  final double searchHorizontalPadding;
  final double inputHorizontalInset;
  final double panelMaxHeight;
  final double panelVerticalPadding;
  final double panelHorizontalPadding;
  final double itemVerticalPadding;
  final double itemHorizontalPadding;
  final double itemRadius;
  final double borderWidth;
  final double focusedBorderWidth;
  final bool showSectionDividers;
}

class AppSearchPalette {
  const AppSearchPalette({
    required this.shellBackground,
    required this.shellBorder,
    required this.shellIconBackground,
    required this.shellIconForeground,
    required this.shellText,
    required this.shellHint,
    required this.shellCursor,
    required this.shellDisabledBackground,
    required this.shellDisabledText,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelSectionLabel,
    required this.panelItemText,
    required this.panelItemSubtitle,
    required this.panelItemIcon,
    required this.panelItemHover,
    required this.panelItemSelected,
    required this.panelDivider,
    required this.panelAccent,
  });

  final Color shellBackground;
  final Color shellBorder;
  final Color shellIconBackground;
  final Color shellIconForeground;
  final Color shellText;
  final Color shellHint;
  final Color shellCursor;
  final Color shellDisabledBackground;
  final Color shellDisabledText;
  final Color panelBackground;
  final Color panelBorder;
  final Color panelSectionLabel;
  final Color panelItemText;
  final Color panelItemSubtitle;
  final Color panelItemIcon;
  final Color panelItemHover;
  final Color panelItemSelected;
  final Color panelDivider;
  final Color panelAccent;
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
    shellIconBackground: focused
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest,
    shellIconForeground: focused
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant,
    shellText: enabled ? context.textPrimary : context.textDisabled,
    shellHint: context.textSecondary,
    shellCursor: colorScheme.primary,
    shellDisabledBackground: colorScheme.surfaceContainerLowest,
    shellDisabledText: context.textDisabled,
    panelBackground: colorScheme.surfaceContainerLow,
    panelBorder: colorScheme.outlineVariant,
    panelSectionLabel: context.textSecondary,
    panelItemText: context.textPrimary,
    panelItemSubtitle: context.textSecondary,
    panelItemIcon: context.textSecondary,
    panelItemHover: colorScheme.surfaceContainerHighest,
    panelItemSelected: colorScheme.primaryContainer,
    panelDivider: colorScheme.outlineVariant.withValues(alpha: 0.5),
    panelAccent: colorScheme.primary,
  );
}
