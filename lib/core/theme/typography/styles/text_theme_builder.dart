// lib/core/theme/typography/styles/text_theme_builder.dart

import 'package:flutter/material.dart';
import '../tokens/type_scale.dart';
import '../tokens/type_weights.dart';
import '../tokens/type_metrics.dart';
// No BuildContext dependency for static theme construction

/// Builds complete responsive TextTheme objects for use with Flutter's theming system.
///
/// This class creates properly structured TextTheme instances for light and
/// dark themes, using the typography tokens with responsive sizing that adapts
/// to different screen breakpoints.
class TextThemeBuilder {
  // Private constructor to prevent instantiation
  TextThemeBuilder._();

  // Deprecated context-based builders removed to keep theme construction context-free.

  /// Context-free light TextTheme using static token sizes.
  ///
  /// This variant avoids accessing MediaQuery or breakpoints at theme creation
  /// time to keep ThemeData construction deterministic and safe.
  static TextTheme buildLightTextThemeStatic() {
    const baseTextColor = Color(0xFF1D1D1D); // Almost black
    return _buildStaticTextTheme(baseTextColor);
  }

  /// Context-free dark TextTheme using static token sizes.
  static TextTheme buildDarkTextThemeStatic() {
    const baseTextColor = Color(0xFFF5F5F5); // Almost white
    return _buildStaticTextTheme(baseTextColor);
  }

  // Backward-compatible wrappers (deprecated) to keep tests/builds green
  @Deprecated('Use buildLightTextThemeStatic() instead; no BuildContext needed')
  static TextTheme buildLightTextTheme(BuildContext context) {
    return buildLightTextThemeStatic();
  }

  @Deprecated('Use buildDarkTextThemeStatic() instead; no BuildContext needed')
  static TextTheme buildDarkTextTheme(BuildContext context) {
    return buildDarkTextThemeStatic();
  }

  /// Internal method to build a responsive TextTheme with the specified text color
  // Removed context-based _buildTextTheme; use _buildStaticTextTheme instead.

  /// Internal method to build a TextTheme with token sizes (no context/breakpoint).
  static TextTheme _buildStaticTextTheme(Color textColor) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.displayLarge,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.displayMedium,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.displaySmall,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.headlineLarge,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.headlineMedium,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.headlineSmall,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.titleLarge,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.titleMedium,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.titleSmall,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.bodyLarge,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.bodyMedium,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.bodySmall,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.labelLarge,
        fontWeight: TypeWeights.labelWeight,
        height: TypeMetrics.labelLineHeight,
        letterSpacing: TypeMetrics.labelLetterSpacing,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.labelMedium,
        fontWeight: TypeWeights.labelWeight,
        height: TypeMetrics.labelLineHeight,
        letterSpacing: TypeMetrics.labelLetterSpacing,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Manrope',
        fontSize: TypeScale.labelSmall,
        fontWeight: TypeWeights.labelWeight,
        height: TypeMetrics.labelLineHeight,
        letterSpacing: TypeMetrics.labelLetterSpacing,
        color: textColor,
      ),
    );
  }

  /// Applies a primary color to certain text styles in a theme
  ///
  /// This creates a variant of the theme with accent colors for specific
  /// text styles (like headlines), useful for brand-aligned typography
  static TextTheme applyPrimaryColor(TextTheme baseTheme, Color primaryColor) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(color: primaryColor),
      headlineLarge: baseTheme.headlineLarge?.copyWith(color: primaryColor),
      titleLarge: baseTheme.titleLarge?.copyWith(color: primaryColor),
    );
  }
}
