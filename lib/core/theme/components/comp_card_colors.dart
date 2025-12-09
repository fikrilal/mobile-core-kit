import 'package:flutter/material.dart';
import '../system/system_grey_colors.dart';
import '../system/system_primary_colors.dart';

/// Component layer: Maps system semantic colors to card component roles
/// This represents the Component layer in the Token → System → Component architecture
@Deprecated('Use CardThemeData + ColorScheme/SemanticColors instead of custom component extensions.')
class ComponentCardColors extends ThemeExtension<ComponentCardColors> {
  // Container colors
  final Color containerColor;

  // Outline colors
  final Color outlineColor;
  final Color outlineColorBold;

  // Text colors
  final Color titleColor;
  final Color subtitleColor;
  final Color subtitleColorBrand;

  const ComponentCardColors({
    required this.containerColor,
    required this.outlineColor,
    required this.outlineColorBold,
    required this.titleColor,
    required this.subtitleColor,
    required this.subtitleColorBrand,
  });

  static ComponentCardColors light({
    required SystemGreyColors grey,
    required SystemPrimaryColors primary,
  }) {
    return ComponentCardColors(
      // Container uses grey surface for light background
      containerColor: grey.surface,

      // Outline uses grey container colors
      outlineColor: grey.onSurfaceLight,
      outlineColorBold: grey.onContainerContainer,

      // Title uses high contrast grey
      titleColor: grey.onSurfaceContainer,

      // Subtitle uses medium contrast grey
      subtitleColor: grey.onSurfaceLight,

      // Subtitle brand uses primary container for brand accent
      subtitleColorBrand: primary.primary,
    );
  }

  static ComponentCardColors dark({
    required SystemGreyColors grey,
    required SystemPrimaryColors primary,
  }) {
    return ComponentCardColors(
      // Container uses grey surface for dark background
      containerColor: grey.surface,

      // Outline uses grey container colors
      outlineColor: grey.onSurfaceLight,
      outlineColorBold: grey.onContainerContainer,

      // Title uses high contrast grey
      titleColor: grey.onSurfaceContainer,

      // Subtitle uses medium contrast grey
      subtitleColor: grey.onSurfaceLight,

      // Subtitle brand uses primary container for brand accent
      subtitleColorBrand: primary.primary,
    );
  }

  @override
  ComponentCardColors copyWith({
    Color? containerColor,
    Color? outlineColor,
    Color? outlineColorBold,
    Color? titleColor,
    Color? subtitleColor,
    Color? subtitleColorBrand,
  }) {
    return ComponentCardColors(
      containerColor: containerColor ?? this.containerColor,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineColorBold: outlineColorBold ?? this.outlineColorBold,
      titleColor: titleColor ?? this.titleColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitleColorBrand: subtitleColorBrand ?? this.subtitleColorBrand,
    );
  }

  @override
  ComponentCardColors lerp(
    ThemeExtension<ComponentCardColors>? other,
    double t,
  ) {
    if (other is! ComponentCardColors) {
      return this;
    }
    return ComponentCardColors(
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
      outlineColor: Color.lerp(outlineColor, other.outlineColor, t)!,
      outlineColorBold: Color.lerp(
        outlineColorBold,
        other.outlineColorBold,
        t,
      )!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subtitleColor: Color.lerp(subtitleColor, other.subtitleColor, t)!,
      subtitleColorBrand: Color.lerp(
        subtitleColorBrand,
        other.subtitleColorBrand,
        t,
      )!,
    );
  }
}
