import 'package:flutter/material.dart';

/// Provides accessibility-enhanced text styles that adapt to user preferences.
///
/// This class takes the responsive text styles and further enhances them
/// to respect user accessibility settings, such as text scaling preferences,
/// while maintaining usability by enforcing reasonable limits.
class AccessibleTextStyles {
  // Private constructor to prevent instantiation
  AccessibleTextStyles._();

  /// Apply accessibility adjustments to a text style
  ///
  /// Text scaling is applied by Flutter via `MediaQueryData.textScaler`.
  /// In this codebase, clamping is enforced at the app root via `AdaptiveScope`
  /// (using `TextScaler.clamp`, which preserves Android 14+ nonlinear scaling).
  ///
  /// This method intentionally does **not** manually multiply `fontSize`, to
  /// avoid double-scaling and to keep nonlinear scaling behavior correct.
  static TextStyle applyAccessibility(
    BuildContext context,
    TextStyle baseStyle, {
    double minScaleFactor = 1.0,
    double maxScaleFactor = 2.5,
  }) {
    // Parameters are retained for backward compatibility with the previous API.
    // Effective clamping is enforced at `AdaptiveScope`.
    return baseStyle;
  }

  /// Enhances the provided responsive text style with accessibility features
  static TextStyle enhance(
    BuildContext context,
    TextStyle Function(BuildContext) styleFunction,
  ) {
    // Get the base responsive style
    final baseStyle = styleFunction(context);

    // Apply accessibility adjustments
    return applyAccessibility(context, baseStyle);
  }

  /// Creates a high-contrast version of a text style if needed
  /// based on the user's accessibility settings
  static TextStyle ensureContrast(
    BuildContext context,
    TextStyle style,
    Color backgroundColor,
  ) {
    // Check if user has high contrast setting enabled
    final needsHighContrast = MediaQuery.highContrastOf(context);

    if (needsHighContrast) {
      // Calculate if the current contrast is sufficient
      // This is a simplified version - in a real app, you would
      // use a proper contrast calculation algorithm
      // final foreground = style.color ?? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

      // For simplicity, we're just ensuring black or white text
      // based on background brightness
      final backgroundBrightness = ThemeData.estimateBrightnessForColor(
        backgroundColor,
      );
      final highContrastColor = backgroundBrightness == Brightness.light
          ? Colors.black
          : Colors.white;

      // Return the style with improved contrast
      return style.copyWith(color: highContrastColor);
    }

    // Return original style if no contrast adjustment needed
    return style;
  }
}
