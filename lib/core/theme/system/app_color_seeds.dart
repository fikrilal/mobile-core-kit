import 'package:flutter/material.dart';

/// Single source of truth for the theme’s seed colors.
///
/// We intentionally treat seeds as the *primitive* tokens and derive semantic
/// role colors (`ColorScheme` + `SemanticColors`) from them.
///
/// Updating the theme colors should generally mean updating these values, then
/// running the contrast gate tests.
abstract final class AppColorSeeds {
  /// Brand primary seed.
  ///
  /// Provided by design. For now this is the agreed placeholder:
  /// `#9FE870`.
  static const brandPrimarySeed = Color(0xFF9FE870);

  /// Neutral seed used for surfaces/containers/outlines.
  ///
  /// Keeping this neutral avoids “tinted surfaces” when the brand seed is a
  /// saturated hue (common enterprise preference).
  static const neutralSeed = Color(0xFF6B7280);

  /// Semantic status seeds.
  ///
  /// These are temporary placeholders until design provides canonical status
  /// colors. They are chosen to behave well in both light and dark schemes.
  static const successSeed = Color(0xFF2E7D32);
  static const warningSeed = Color(0xFFF9A825);
  static const infoSeed = Color(0xFF1565C0);
}

