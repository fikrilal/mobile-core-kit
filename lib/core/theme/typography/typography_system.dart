import 'package:flutter/material.dart';
import 'tokens/type_metrics.dart';
import 'tokens/typefaces.dart';
import 'styles/text_theme_builder.dart';

/// Main entry point to the typography system.
///
/// This class serves as the central access point to the typography system,
/// providing essential typography utilities and theme integration.
///
/// For creating text components, use AppText constructors directly:
/// - AppText.displayLarge('text')
/// - AppText.headlineMedium('text')
/// - AppText.bodyMedium('text')
/// etc.
class TypographySystem {
  // Private constructor to prevent instantiation
  TypographySystem._();

  /// The font family used by the typography system
  static const String fontFamily = Typefaces.primary;

  /// Apply the typography system to a theme without requiring BuildContext.
  ///
  /// Uses static token sizes so ThemeData creation remains deterministic and
  /// safe outside of any MediaQuery or breakpoint context.
  static ThemeData applyTypography(ThemeData baseTheme, [BuildContext? _]) {
    final textTheme = baseTheme.brightness == Brightness.light
        ? TextThemeBuilder.buildLightTextThemeStatic()
        : TextThemeBuilder.buildDarkTextThemeStatic();

    return baseTheme.copyWith(
      textTheme: textTheme,
      // Apply typography to other theme components that use text
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme.copyWith(
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      tabBarTheme: baseTheme.tabBarTheme.copyWith(
        labelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      // Add more component theming as needed
    );
  }

  // Typography utility methods

  /// Calculate optimal line height for a given font size
  static double lineHeight(double fontSize, {String category = 'body'}) {
    return fontSize * TypeMetrics.getLineHeight(category);
  }

  /// Get appropriate letter spacing for a text category
  static double letterSpacing(String category) {
    return TypeMetrics.getLetterSpacing(category);
  }

  /// Calculate ideal text container width for a font size
  static double idealWidth(double fontSize) {
    return TypeMetrics.getIdealTextContainerWidth(fontSize);
  }
}
