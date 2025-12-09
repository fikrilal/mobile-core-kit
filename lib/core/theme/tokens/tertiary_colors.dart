import 'package:flutter/material.dart';

class TertiaryColors extends ThemeExtension<TertiaryColors> {
  const TertiaryColors({
    required this.tertiary100,
    required this.tertiary200,
    required this.tertiary300,
    required this.tertiary400,
    required this.tertiary500,
    required this.tertiary600,
    required this.tertiary700,
    required this.tertiary800,
    required this.tertiary900,
    required this.tertiary1000,
  });

  final Color tertiary100;
  final Color tertiary200;
  final Color tertiary300;
  final Color tertiary400;
  final Color tertiary500;
  final Color tertiary600;
  final Color tertiary700;
  final Color tertiary800;
  final Color tertiary900;
  final Color tertiary1000;

  static const TertiaryColors light = TertiaryColors(
    tertiary100: Color(0xFFDAF0E4),
    tertiary200: Color(0xFFB9E1CE),
    tertiary300: Color(0xFF8BCAAF),
    tertiary400: Color(0xFF5AAD8C),
    tertiary500: Color(0xFF389170),
    tertiary600: Color(0xFF28735A),
    tertiary700: Color(0xFF205C49),
    tertiary800: Color(0xFF1B4A3B),
    tertiary900: Color(0xFF173D32),
    tertiary1000: Color(0xFF0C221C),
  );

  static const TertiaryColors dark = TertiaryColors(
    tertiary100: Color(0xFF0C221C),
    tertiary200: Color(0xFF173D32),
    tertiary300: Color(0xFF1B4A3B),
    tertiary400: Color(0xFF205C49),
    tertiary500: Color(0xFF28735A),
    tertiary600: Color(0xFF389170),
    tertiary700: Color(0xFF5AAD8C),
    tertiary800: Color(0xFF8BCAAF),
    tertiary900: Color(0xFFB9E1CE),
    tertiary1000: Color(0xFFDAF0E4),
  );

  @override
  TertiaryColors copyWith({
    Color? tertiary100,
    Color? tertiary200,
    Color? tertiary300,
    Color? tertiary400,
    Color? tertiary500,
    Color? tertiary600,
    Color? tertiary700,
    Color? tertiary800,
    Color? tertiary900,
    Color? tertiary1000,
  }) {
    return TertiaryColors(
      tertiary100: tertiary100 ?? this.tertiary100,
      tertiary200: tertiary200 ?? this.tertiary200,
      tertiary300: tertiary300 ?? this.tertiary300,
      tertiary400: tertiary400 ?? this.tertiary400,
      tertiary500: tertiary500 ?? this.tertiary500,
      tertiary600: tertiary600 ?? this.tertiary600,
      tertiary700: tertiary700 ?? this.tertiary700,
      tertiary800: tertiary800 ?? this.tertiary800,
      tertiary900: tertiary900 ?? this.tertiary900,
      tertiary1000: tertiary1000 ?? this.tertiary1000,
    );
  }

  @override
  TertiaryColors lerp(ThemeExtension<TertiaryColors>? other, double t) {
    if (other is! TertiaryColors) {
      return this;
    }
    return TertiaryColors(
      tertiary100: Color.lerp(tertiary100, other.tertiary100, t)!,
      tertiary200: Color.lerp(tertiary200, other.tertiary200, t)!,
      tertiary300: Color.lerp(tertiary300, other.tertiary300, t)!,
      tertiary400: Color.lerp(tertiary400, other.tertiary400, t)!,
      tertiary500: Color.lerp(tertiary500, other.tertiary500, t)!,
      tertiary600: Color.lerp(tertiary600, other.tertiary600, t)!,
      tertiary700: Color.lerp(tertiary700, other.tertiary700, t)!,
      tertiary800: Color.lerp(tertiary800, other.tertiary800, t)!,
      tertiary900: Color.lerp(tertiary900, other.tertiary900, t)!,
      tertiary1000: Color.lerp(tertiary1000, other.tertiary1000, t)!,
    );
  }
}
