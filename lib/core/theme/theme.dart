// lib/core/theme/theme.dart
import 'package:flutter/material.dart';
import 'light_theme.dart'; // Direct import of theme files
import 'dark_theme.dart'; // Direct import of theme files
import 'typography/typography_system.dart';

/// App theme with responsive typography integration.
///
/// This class provides access to the app's themes with
/// responsive typography that adapts to different screen sizes and
/// accessibility preferences.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Get the light theme with static typography (context-free)
  static ThemeData light() {
    return TypographySystem.applyTypography(lightTheme);
  }

  /// Get the dark theme with static typography (context-free)
  static ThemeData dark() {
    return TypographySystem.applyTypography(darkTheme);
  }

  /// Get the high-contrast light theme (context-free).
  ///
  /// Selection should happen at the app shell based on `MediaQueryData` (e.g.
  /// `MediaQuery.highContrastOf(context)`).
  static ThemeData lightHighContrast() {
    return TypographySystem.applyTypography(lightHighContrastTheme);
  }

  /// Get the high-contrast dark theme (context-free).
  ///
  /// Selection should happen at the app shell based on `MediaQueryData` (e.g.
  /// `MediaQuery.highContrastOf(context)`).
  static ThemeData darkHighContrast() {
    return TypographySystem.applyTypography(darkHighContrastTheme);
  }

  /// Create a custom theme with the specified color scheme (context-free)
  static ThemeData custom({
    required ColorScheme colorScheme,
    String? fontFamily,
  }) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily ?? TypographySystem.fontFamily,
    );
    return TypographySystem.applyTypography(baseTheme);
  }
}
