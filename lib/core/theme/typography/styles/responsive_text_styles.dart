import 'package:flutter/material.dart';
import '../tokens/type_scale.dart';
import '../tokens/type_weights.dart';
import '../tokens/type_metrics.dart';
import '../tokens/typefaces.dart';

/// Provides text styles that adapt to different screen sizes.
///
/// These styles are based on typography tokens and rely on the app-level
/// adaptive system (`AdaptiveScope`) for text scaling and layout adaptation.
class ResponsiveTextStyles {
  // Private constructor to prevent instantiation
  ResponsiveTextStyles._();

  // Display Styles
  static TextStyle displayLarge(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.displayLarge,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  static TextStyle displayMedium(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.displayMedium,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  static TextStyle displaySmall(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.displaySmall,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  // Headline Styles
  static TextStyle headlineLarge(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.headlineLarge,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  static TextStyle headlineMedium(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.headlineMedium,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  static TextStyle headlineSmall(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.headlineSmall,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  // Title Styles
  static TextStyle titleLarge(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.titleLarge,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  static TextStyle titleMedium(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.titleMedium,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  static TextStyle titleSmall(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.titleSmall,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.bodyLarge,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  static TextStyle bodyMedium(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.bodyMedium,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  static TextStyle bodySmall(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.bodySmall,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  // Label Styles
  static TextStyle labelLarge(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.labelLarge,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }

  static TextStyle labelMedium(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.labelMedium,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }

  static TextStyle labelSmall(BuildContext _) {
    return TextStyle(
      fontFamily: Typefaces.primary,
      fontSize: TypeScale.labelSmall,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }
}
