import 'package:flutter/material.dart';

/// Extension methods for BuildContext to easily access typography styles.
///
/// These extensions make it simple to apply typography styles consistently
/// throughout the app, providing a concise syntax for accessing the
/// responsive text styles.
@Deprecated('Use Theme.of(context).textTheme.* as the canonical typography API.')
extension TypographyExtensions on BuildContext {
  // Display styles
  TextStyle get displayLarge =>
      Theme.of(this).textTheme.displayLarge ?? const TextStyle();

  TextStyle get displayMedium =>
      Theme.of(this).textTheme.displayMedium ?? const TextStyle();

  TextStyle get displaySmall =>
      Theme.of(this).textTheme.displaySmall ?? const TextStyle();

  // Headline styles
  TextStyle get headlineLarge =>
      Theme.of(this).textTheme.headlineLarge ?? const TextStyle();

  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineMedium ?? const TextStyle();

  TextStyle get headlineSmall =>
      Theme.of(this).textTheme.headlineSmall ?? const TextStyle();

  // Title styles
  TextStyle get titleLarge =>
      Theme.of(this).textTheme.titleLarge ?? const TextStyle();

  TextStyle get titleMedium =>
      Theme.of(this).textTheme.titleMedium ?? const TextStyle();

  TextStyle get titleSmall =>
      Theme.of(this).textTheme.titleSmall ?? const TextStyle();

  // Body styles
  TextStyle get bodyLarge =>
      Theme.of(this).textTheme.bodyLarge ?? const TextStyle();

  TextStyle get bodyMedium =>
      Theme.of(this).textTheme.bodyMedium ?? const TextStyle();

  TextStyle get bodySmall =>
      Theme.of(this).textTheme.bodySmall ?? const TextStyle();

  // Label styles
  TextStyle get labelLarge =>
      Theme.of(this).textTheme.labelLarge ?? const TextStyle();

  TextStyle get labelMedium =>
      Theme.of(this).textTheme.labelMedium ?? const TextStyle();

  TextStyle get labelSmall =>
      Theme.of(this).textTheme.labelSmall ?? const TextStyle();
}

/// Extension methods for TextStyle to make typography adjustments easier.
@Deprecated(
  'Avoid ad-hoc typography mutations in feature code. Prefer adding new roles to the type ramp instead.',
)
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
