import 'package:flutter/material.dart';

import '../extensions/semantic_colors.dart';
import 'app_color_seeds.dart';

@immutable
class AppColorSystem {
  final ColorScheme scheme;
  final SemanticColors semantic;

  const AppColorSystem({
    required this.scheme,
    required this.semantic,
  });
}

/// Builds the app's color roles from a small set of seed inputs.
///
/// This keeps the *public contract* role-based:
/// - `ColorScheme` for Material roles
/// - `SemanticColors` for status roles (success/info/warning)
///
/// Implementation uses `ColorScheme.fromSeed` (Material 3) but callers should
/// treat the output as semantic role tokens, not “Material-only”.
abstract final class AppColorSchemeBuilder {
  static AppColorSystem build({
    required Brightness brightness,
  }) {
    final brandScheme = ColorScheme.fromSeed(
      seedColor: AppColorSeeds.brandPrimarySeed,
      brightness: brightness,
    );

    final neutralScheme = ColorScheme.fromSeed(
      seedColor: AppColorSeeds.neutralSeed,
      brightness: brightness,
    );

    final scheme = brandScheme.copyWith(
      // Keep accents/brand from brand scheme, but force neutral surfaces.
      //
      // Policy: neutral elevation. We want elevated surfaces to remain neutral
      // (no brand tint). Material 3 applies tonal elevation via `surfaceTint`,
      // so we source it from the neutral scheme.
      surface: neutralScheme.surface,
      onSurface: neutralScheme.onSurface,
      onSurfaceVariant: neutralScheme.onSurfaceVariant,
      surfaceContainerLowest: neutralScheme.surfaceContainerLowest,
      surfaceContainerLow: neutralScheme.surfaceContainerLow,
      surfaceContainer: neutralScheme.surfaceContainer,
      surfaceContainerHigh: neutralScheme.surfaceContainerHigh,
      surfaceContainerHighest: neutralScheme.surfaceContainerHighest,
      outline: neutralScheme.outline,
      outlineVariant: neutralScheme.outlineVariant,
      inverseSurface: neutralScheme.inverseSurface,
      onInverseSurface: neutralScheme.onInverseSurface,
      surfaceTint: neutralScheme.surfaceTint,
      shadow: neutralScheme.shadow,
      scrim: neutralScheme.scrim,
    );

    final semantic = SemanticColors.fromSchemes(
      success: ColorScheme.fromSeed(
        seedColor: AppColorSeeds.successSeed,
        brightness: brightness,
      ),
      info: ColorScheme.fromSeed(
        seedColor: AppColorSeeds.infoSeed,
        brightness: brightness,
      ),
      warning: ColorScheme.fromSeed(
        seedColor: AppColorSeeds.warningSeed,
        brightness: brightness,
      ),
    );

    return AppColorSystem(
      scheme: scheme,
      semantic: semantic,
    );
  }
}
