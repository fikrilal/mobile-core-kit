import 'package:flutter/material.dart';

/// Single source of truth for the theme’s seed colors.
///
/// We intentionally treat seeds as the *primitive* tokens and derive semantic
/// role colors (`ColorScheme` + `SemanticColors`) from them.
///
/// Updating the theme colors should generally mean updating these values, then
/// running the contrast gate tests.
abstract final class AppColorSeeds {
  /// Brand primary seed (core brand color).
  ///
  /// Provided by design: `#9FE870` (Bright Green).
  static const brandPrimarySeed = Color(0xFF9FE870);

  /// Neutral seed used for surfaces/containers/outlines.
  ///
  /// Keeping this neutral avoids “tinted surfaces” when the brand seed is a
  /// saturated hue (common enterprise preference).
  ///
  /// Provided by design: `#868685` (Interactive Secondary).
  static const neutralSeed = Color(0xFF868685);

  /// Semantic status seeds.
  ///
  /// Provided by design:
  /// - Success: `#2F5711` (Sentiment Positive)
  /// - Warning: `#EDC843` (Sentiment Warning)
  /// - Info: `#A0E1E1` (Bright Blue)
  static const successSeed = Color(0xFF2F5711);
  static const warningSeed = Color(0xFFEDC843);
  static const infoSeed = Color(0xFFA0E1E1);
}
