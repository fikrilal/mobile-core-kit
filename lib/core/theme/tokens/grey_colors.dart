import 'package:flutter/material.dart';

/// GreyColors is a ThemeExtension used to manage all grey color tokens
/// in both light and dark mode using the ThemeData system.
///
/// How it works:
/// - This class defines semantic color levels (grey100 → grey1000)
/// - You define light and dark variants using `GreyColors.light` and `GreyColors.dark`
/// - These instances are injected into `ThemeData.extensions` inside light_theme.dart and dark_theme.dart
///
/// Usage:
/// 1. Inject into your ThemeData:
///
/// ```dart
/// extensions: const [GreyColors.light], // in light_theme.dart
/// extensions: const [GreyColors.dark],  // in dark_theme.dart
/// ```
///
/// 2. Access in any widget via BuildContext:
///
/// ```dart
/// context.grey.grey500
/// ```
///
/// This enables centralized, theme-aware grey color usage across your app.
///
/// Related: See `ThemeColorAccess` for other color access extensions like `context.green`, `context.lime`, etc.

@immutable
class GreyColors extends ThemeExtension<GreyColors> {
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey800;
  final Color grey900;
  final Color grey1000;

  const GreyColors({
    required this.grey100,
    required this.grey200,
    required this.grey300,
    required this.grey400,
    required this.grey500,
    required this.grey600,
    required this.grey700,
    required this.grey800,
    required this.grey900,
    required this.grey1000,
  });

  static const GreyColors light = GreyColors(
    grey100: Color(0xFFFFFFFF),
    grey200: Color(0xFFEFEFEF),
    grey300: Color(0xFF92979C),
    grey400: Color(0xFF797F85),
    grey500: Color(0xFF60686E),
    grey600: Color(0xFF4E565E),
    grey700: Color(0xFF3B444C),
    grey800: Color(0xFF28323B),
    grey900: Color(0xFF1D262F),
    grey1000: Color(0xFF12171D),
  );

  static const GreyColors dark = GreyColors(
    grey100: Color(0xFF12171D),
    grey200: Color(0xFF1D262F),
    grey300: Color(0xFF28323B),
    grey400: Color(0xFF3B444C),
    grey500: Color(0xFF4E565E),
    grey600: Color(0xFF60686E),
    grey700: Color(0xFF797F85),
    grey800: Color(0xFF92979C),
    grey900: Color(0xFFEFEFEF),
    grey1000: Color(0xFFFFFFFF),
  );

  @override
  GreyColors copyWith({
    Color? grey100,
    Color? grey200,
    Color? grey300,
    Color? grey400,
    Color? grey500,
    Color? grey600,
    Color? grey700,
    Color? grey800,
    Color? grey900,
    Color? grey1000,
  }) {
    return GreyColors(
      grey100: grey100 ?? this.grey100,
      grey200: grey200 ?? this.grey200,
      grey300: grey300 ?? this.grey300,
      grey400: grey400 ?? this.grey400,
      grey500: grey500 ?? this.grey500,
      grey600: grey600 ?? this.grey600,
      grey700: grey700 ?? this.grey700,
      grey800: grey800 ?? this.grey800,
      grey900: grey900 ?? this.grey900,
      grey1000: grey1000 ?? this.grey1000,
    );
  }

  @override
  GreyColors lerp(ThemeExtension<GreyColors>? other, double t) {
    if (other is! GreyColors) return this;
    return GreyColors(
      grey100: Color.lerp(grey100, other.grey100, t)!,
      grey200: Color.lerp(grey200, other.grey200, t)!,
      grey300: Color.lerp(grey300, other.grey300, t)!,
      grey400: Color.lerp(grey400, other.grey400, t)!,
      grey500: Color.lerp(grey500, other.grey500, t)!,
      grey600: Color.lerp(grey600, other.grey600, t)!,
      grey700: Color.lerp(grey700, other.grey700, t)!,
      grey800: Color.lerp(grey800, other.grey800, t)!,
      grey900: Color.lerp(grey900, other.grey900, t)!,
      grey1000: Color.lerp(grey1000, other.grey1000, t)!,
    );
  }
}
