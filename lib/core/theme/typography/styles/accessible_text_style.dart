import 'package:flutter/material.dart';
import '../../responsive/screen_utils.dart';

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
  /// This method respects the user's text scale preference while
  /// enforcing reasonable min/max bounds to maintain layout integrity
  static TextStyle applyAccessibility(
    BuildContext context,
    TextStyle baseStyle, {
    double minScaleFactor = 0.8,
    double maxScaleFactor = 1.5,
  }) {
    // Get the user's text scale factor preference
    final scaleFactor = context.textScaleFactor.clamp(
      minScaleFactor,
      maxScaleFactor,
    );

    // Apply scaled font size with bounds
    final scaledSize = baseStyle.fontSize! * scaleFactor;

    // Return the modified style with the scaled font size
    return baseStyle.copyWith(fontSize: scaledSize);
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
    // This is a simplified version - in a real app, you would
    // check the actual accessibility settings
    final needsHighContrast = context.preferLargeText;

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
