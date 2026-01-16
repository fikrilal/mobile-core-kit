import 'package:flutter/material.dart';

/// Provides text styles that adapt to different screen sizes.
///
/// These styles are a compatibility layer for legacy call sites (AppText,
/// Heading, Paragraph) that were originally token-built here.
///
/// Canonical typography in this repo is `Theme.of(context).textTheme.*`.
/// This class now simply proxies to the theme so there is a single source of
/// truth for the type ramp.
class ResponsiveTextStyles {
  // Private constructor to prevent instantiation
  ResponsiveTextStyles._();

  // Display Styles
  static TextStyle displayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge ?? const TextStyle();
  }

  static TextStyle displayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium ?? const TextStyle();
  }

  static TextStyle displaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall ?? const TextStyle();
  }

  // Headline Styles
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge ?? const TextStyle();
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium ?? const TextStyle();
  }

  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall ?? const TextStyle();
  }

  // Title Styles
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge ?? const TextStyle();
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium ?? const TextStyle();
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall ?? const TextStyle();
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall ?? const TextStyle();
  }

  // Label Styles
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge ?? const TextStyle();
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium ?? const TextStyle();
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall ?? const TextStyle();
  }
}
