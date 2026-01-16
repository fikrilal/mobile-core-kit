// lib/core/theme/typography/styles/text_theme_builder.dart

import 'package:flutter/material.dart';
import '../tokens/type_scale.dart';
import '../tokens/type_weights.dart';
import '../tokens/type_metrics.dart';
import '../tokens/typefaces.dart';
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

  /// Context-free TextTheme using static token sizes.
  ///
  /// Uses the provided [scheme] so text colors stay aligned with the current
  /// role-based theme (`scheme.onSurface`) without any hardcoded values.
  static TextTheme buildTextThemeStatic(ColorScheme scheme) {
    return _buildStaticTextTheme(scheme.onSurface);
  }

  // Backward-compatible wrappers (deprecated) to keep tests/builds green
  @Deprecated('Use buildTextThemeStatic(Theme.of(context).colorScheme) instead')
  static TextTheme buildLightTextTheme(BuildContext context) {
    return buildTextThemeStatic(Theme.of(context).colorScheme);
  }

  @Deprecated('Use buildTextThemeStatic(Theme.of(context).colorScheme) instead')
  static TextTheme buildDarkTextTheme(BuildContext context) {
    return buildTextThemeStatic(Theme.of(context).colorScheme);
  }

  /// Internal method to build a responsive TextTheme with the specified text color
  // Removed context-based _buildTextTheme; use _buildStaticTextTheme instead.

  /// Internal method to build a TextTheme with token sizes (no context/breakpoint).
  static TextTheme _buildStaticTextTheme(Color textColor) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.displayLarge,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.displayMedium,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.displaySmall,
        fontWeight: TypeWeights.displayWeight,
        height: TypeMetrics.displayLineHeight,
        letterSpacing: TypeMetrics.displayLetterSpacing,
        color: textColor,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.headlineLarge,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.headlineMedium,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.headlineSmall,
        fontWeight: TypeWeights.headlineWeight,
        height: TypeMetrics.headlineLineHeight,
        letterSpacing: TypeMetrics.headlineLetterSpacing,
        color: textColor,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.titleLarge,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.titleMedium,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.titleSmall,
        fontWeight: TypeWeights.titleWeight,
        height: TypeMetrics.titleLineHeight,
        letterSpacing: TypeMetrics.titleLetterSpacing,
        color: textColor,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.bodyLarge,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.bodyMedium,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.bodySmall,
        fontWeight: TypeWeights.bodyWeight,
        height: TypeMetrics.bodyLineHeight,
        letterSpacing: TypeMetrics.bodyLetterSpacing,
        color: textColor,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.labelLarge,
        fontWeight: TypeWeights.labelWeight,
        height: TypeMetrics.labelLineHeight,
        letterSpacing: TypeMetrics.labelLetterSpacing,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: Typefaces.primary,
        fontSize: TypeScale.labelMedium,
        fontWeight: TypeWeights.labelWeight,
        height: TypeMetrics.labelLineHeight,
        letterSpacing: TypeMetrics.labelLetterSpacing,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: Typefaces.primary,
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
