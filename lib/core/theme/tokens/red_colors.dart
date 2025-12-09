import 'package:flutter/material.dart';

@immutable
class RedColors extends ThemeExtension<RedColors> {
  final Color red100;
  final Color red200;
  final Color red300;
  final Color red400;
  final Color red500;
  final Color red600;
  final Color red700;
  final Color red800;
  final Color red900;
  final Color red1000;

  const RedColors({
    required this.red100,
    required this.red200,
    required this.red300,
    required this.red400,
    required this.red500,
    required this.red600,
    required this.red700,
    required this.red800,
    required this.red900,
    required this.red1000,
  });

  static const RedColors light = RedColors(
    red100: Color(0xFFFFF5F5),
    red200: Color(0xFFFFE6E6),
    red300: Color(0xFFFECCCB),
    red400: Color(0xFFFFB0B0),
    red500: Color(0xFFFF9090),
    red600: Color(0xFFFF7373),
    red700: Color(0xFFFF4646),
    red800: Color(0xFFE93C3C),
    red900: Color(0xFFD33534),
    red1000: Color(0xFFBB2E2E),
  );

  static const RedColors dark = RedColors(
    red100: Color(0xFFBB2E2E),
    red200: Color(0xFFD33534),
    red300: Color(0xFFE93C3C),
    red400: Color(0xFFFF4646),
    red500: Color(0xFFFF7373),
    red600: Color(0xFFFF9090),
    red700: Color(0xFFFFB0B0),
    red800: Color(0xFFFECCCB),
    red900: Color(0xFFFFE6E6),
    red1000: Color(0xFFFFF5F5),
  );

  @override
  RedColors copyWith({
    Color? red100,
    Color? red200,
    Color? red300,
    Color? red400,
    Color? red500,
    Color? red600,
    Color? red700,
    Color? red800,
    Color? red900,
    Color? red1000,
  }) {
    return RedColors(
      red100: red100 ?? this.red100,
      red200: red200 ?? this.red200,
      red300: red300 ?? this.red300,
      red400: red400 ?? this.red400,
      red500: red500 ?? this.red500,
      red600: red600 ?? this.red600,
      red700: red700 ?? this.red700,
      red800: red800 ?? this.red800,
      red900: red900 ?? this.red900,
      red1000: red1000 ?? this.red1000,
    );
  }

  @override
  RedColors lerp(ThemeExtension<RedColors>? other, double t) {
    if (other is! RedColors) return this;
    return RedColors(
      red100: Color.lerp(red100, other.red100, t)!,
      red200: Color.lerp(red200, other.red200, t)!,
      red300: Color.lerp(red300, other.red300, t)!,
      red400: Color.lerp(red400, other.red400, t)!,
      red500: Color.lerp(red500, other.red500, t)!,
      red600: Color.lerp(red600, other.red600, t)!,
      red700: Color.lerp(red700, other.red700, t)!,
      red800: Color.lerp(red800, other.red800, t)!,
      red900: Color.lerp(red900, other.red900, t)!,
      red1000: Color.lerp(red1000, other.red1000, t)!,
    );
  }
}
