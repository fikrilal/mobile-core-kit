import 'package:flutter/material.dart';
import '../tokens/type_scale.dart';
import '../tokens/type_weights.dart';
import '../tokens/type_metrics.dart';
import '../../responsive/screen_utils.dart';

/// Provides text styles that adapt to different screen sizes.
///
/// These styles use the typography tokens but adjust the sizes based
/// on the current screen breakpoint, providing a consistent typography
/// experience across device sizes.
class ResponsiveTextStyles {
  // Private constructor to prevent instantiation
  ResponsiveTextStyles._();

  // Display Styles
  static TextStyle displayLarge(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.displayLarge,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.displayMedium,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  static TextStyle displaySmall(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.displaySmall,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.displayWeight,
      height: TypeMetrics.displayLineHeight,
      letterSpacing: TypeMetrics.displayLetterSpacing,
    );
  }

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.headlineLarge,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.headlineMedium,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(
      TypeScale.headlineSmall,
      breakpoint,
    );

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.headlineWeight,
      height: TypeMetrics.headlineLineHeight,
      letterSpacing: TypeMetrics.headlineLetterSpacing,
    );
  }

  // Title Styles
  static TextStyle titleLarge(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.titleLarge, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.titleMedium, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.titleSmall, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.titleWeight,
      height: TypeMetrics.titleLineHeight,
      letterSpacing: TypeMetrics.titleLetterSpacing,
    );
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.bodyLarge, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.bodyMedium, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.bodySmall, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.bodyWeight,
      height: TypeMetrics.bodyLineHeight,
      letterSpacing: TypeMetrics.bodyLetterSpacing,
    );
  }

  // Label Styles
  static TextStyle labelLarge(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.labelLarge, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.labelMedium, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    final breakpoint = context.breakpoint;
    final size = TypeScale.getResponsiveSize(TypeScale.labelSmall, breakpoint);

    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: TypeWeights.labelWeight,
      height: TypeMetrics.labelLineHeight,
      letterSpacing: TypeMetrics.labelLetterSpacing,
    );
  }
}
