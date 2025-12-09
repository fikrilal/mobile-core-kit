import 'package:flutter/material.dart';
import '../styles/accessible_text_style.dart';
import '../styles/responsive_text_styles.dart';

/// Extension methods for BuildContext to easily access typography styles.
///
/// These extensions make it simple to apply typography styles consistently
/// throughout the app, providing a concise syntax for accessing the
/// responsive text styles.
extension TypographyExtensions on BuildContext {
  // Display styles
  TextStyle get displayLarge =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.displayLarge);

  TextStyle get displayMedium =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.displayMedium);

  TextStyle get displaySmall =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.displaySmall);

  // Headline styles
  TextStyle get headlineLarge =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.headlineLarge);

  TextStyle get headlineMedium =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.headlineMedium);

  TextStyle get headlineSmall =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.headlineSmall);

  // Title styles
  TextStyle get titleLarge =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.titleLarge);

  TextStyle get titleMedium =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.titleMedium);

  TextStyle get titleSmall =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.titleSmall);

  // Body styles
  TextStyle get bodyLarge =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.bodyLarge);

  TextStyle get bodyMedium =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.bodyMedium);

  TextStyle get bodySmall =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.bodySmall);

  // Label styles
  TextStyle get labelLarge =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.labelLarge);

  TextStyle get labelMedium =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.labelMedium);

  TextStyle get labelSmall =>
      AccessibleTextStyles.enhance(this, ResponsiveTextStyles.labelSmall);
}

/// Extension methods for TextStyle to make typography adjustments easier.
extension TextStyleExtensions on TextStyle {
  /// Creates a bolder version of this text style
  TextStyle get bolder {
    FontWeight? newWeight;

    if (fontWeight == null || fontWeight == FontWeight.normal) {
      newWeight = FontWeight.bold;
    } else if (fontWeight!.index < FontWeight.w900.index) {
      // Increase weight by 100 if possible
      newWeight = FontWeight.values.firstWhere(
        (w) => w.index == fontWeight!.index + 1,
      );
    } else {
      // Already at maximum weight
      newWeight = fontWeight;
    }

    return copyWith(fontWeight: newWeight);
  }

  /// Creates a lighter version of this text style
  TextStyle get lighter {
    FontWeight? newWeight;

    if (fontWeight == null || fontWeight == FontWeight.bold) {
      newWeight = FontWeight.normal;
    } else if (fontWeight!.index > FontWeight.w100.index) {
      // Decrease weight by 100 if possible
      newWeight = FontWeight.values.firstWhere(
        (w) => w.index == fontWeight!.index - 1,
      );
    } else {
      // Already at minimum weight
      newWeight = fontWeight;
    }

    return copyWith(fontWeight: newWeight);
  }

  /// Creates a version of this text style with emphasis (italics)
  TextStyle get emphasized => copyWith(fontStyle: FontStyle.italic);

  /// Creates a version of this text style with tight letter spacing
  TextStyle get tight => copyWith(letterSpacing: -0.5);

  /// Creates a version of this text style with wide letter spacing
  TextStyle get wide => copyWith(letterSpacing: 1.0);

  /// Creates a version of this text style with compact line height
  TextStyle get compact => copyWith(height: (height ?? 1.2) * 0.9);

  /// Creates a version of this text style with relaxed line height
  TextStyle get relaxed => copyWith(height: (height ?? 1.2) * 1.2);

  /// Creates a version of this text style with slightly larger font size
  TextStyle get larger => copyWith(fontSize: (fontSize ?? 14.0) * 1.2);

  /// Creates a version of this text style with slightly smaller font size
  TextStyle get smaller => copyWith(fontSize: (fontSize ?? 14.0) * 0.85);
}
