import 'package:flutter/material.dart';
import 'semantic_colors.dart';
import '../tokens/blue_colors.dart';
import '../tokens/green_colors.dart';
import '../tokens/grey_colors.dart';
import '../tokens/primary_colors.dart';
import '../tokens/red_colors.dart';
import '../tokens/secondary_colors.dart';
import '../tokens/tertiary_colors.dart';
import '../tokens/yellow_colors.dart';

extension ThemeColorAccess on BuildContext {
  // Token Colors
  PrimaryColors get primary => Theme.of(this).extension<PrimaryColors>()!;
  SecondaryColors get secondary => Theme.of(this).extension<SecondaryColors>()!;
  TertiaryColors get tertiary => Theme.of(this).extension<TertiaryColors>()!;
  GreyColors get grey => Theme.of(this).extension<GreyColors>()!;
  GreenColors get green => Theme.of(this).extension<GreenColors>()!;
  RedColors get red => Theme.of(this).extension<RedColors>()!;
  YellowColors get yellow => Theme.of(this).extension<YellowColors>()!;
  BlueColors get blue => Theme.of(this).extension<BlueColors>()!;

  // Semantic status colors (non-M3)
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>()!;
}

/// Ergonomic accessors for common Material 3 color roles derived from ColorScheme.
/// Keeps call sites concise while aligning with M3 semantics.
extension ThemeRoleColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  // Text roles
  Color get textPrimary => cs.onSurface;
  Color get textSecondary => cs.onSurfaceVariant;
  Color get textDisabled => cs.onSurface.withValues(alpha: 0.38);

  // Border/outline roles
  Color get border => cs.outline;
  Color get borderSubtle => cs.outlineVariant;
  Color get borderMuted => cs.outlineVariant.withValues(alpha: 0.5);
  Color get hairline => cs.outlineVariant.withValues(alpha: 0.12);

  // Surfaces
  Color get bgSurface => cs.surface;
  Color get bgSurfaceInverse => cs.inverseSurface;
  Color get bgContainer => cs.surfaceContainer;
  Color get bgContainerLow => cs.surfaceContainerLow;
  Color get bgContainerHigh => cs.surfaceContainerHigh;
  Color get bgContainerHighest => cs.surfaceContainerHighest;

  // Brand aliases
  Color get brand => cs.primary;
  Color get onBrand => cs.onPrimary;
  Color get brandContainer => cs.primaryContainer;
  Color get onBrandContainer => cs.onPrimaryContainer;
}
