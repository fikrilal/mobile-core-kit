import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/styles/text_theme_builder.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/tokens/typefaces.dart';

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
  static ThemeData applyTypography(ThemeData baseTheme) {
    final textTheme = TextThemeBuilder.buildTextThemeStatic(
      baseTheme.colorScheme,
    );

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
}
