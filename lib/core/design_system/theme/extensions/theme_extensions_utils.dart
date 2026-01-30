import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/extensions/semantic_colors.dart';

extension ThemeColorAccess on BuildContext {
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
  Color get bgContainerLowest => cs.surfaceContainerLowest;
  Color get bgContainerLow => cs.surfaceContainerLow;
  Color get bgContainerHigh => cs.surfaceContainerHigh;
  Color get bgContainerHighest => cs.surfaceContainerHighest;

  // Brand aliases
  Color get brand => cs.primary;
  Color get onBrand => cs.onPrimary;
  Color get brandContainer => cs.primaryContainer;
  Color get onBrandContainer => cs.onPrimaryContainer;
}
