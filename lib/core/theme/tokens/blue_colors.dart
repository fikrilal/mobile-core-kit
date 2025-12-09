import 'package:flutter/material.dart';

@immutable
class BlueColors extends ThemeExtension<BlueColors> {
  final Color blue100;
  final Color blue200;
  final Color blue300;
  final Color blue400;
  final Color blue500;
  final Color blue600;
  final Color blue700;
  final Color blue800;
  final Color blue900;
  final Color blue1000;

  const BlueColors({
    required this.blue100,
    required this.blue200,
    required this.blue300,
    required this.blue400,
    required this.blue500,
    required this.blue600,
    required this.blue700,
    required this.blue800,
    required this.blue900,
    required this.blue1000,
  });

  static const BlueColors light = BlueColors(
    blue100: Color(0xFFF3F9FF),
    blue200: Color(0xFFE1F1FF),
    blue300: Color(0xFFB9DEFF),
    blue400: Color(0xFF98CEFF),
    blue500: Color(0xFF73BAFF),
    blue600: Color(0xFF4FA4FF),
    blue700: Color(0xFF1D8FFF),
    blue800: Color(0xFF0072FF),
    blue900: Color(0xFF006DEA),
    blue1000: Color(0xFF005ED4),
  );

  static const BlueColors dark = BlueColors(
    blue100: Color(0xFF005ED4),
    blue200: Color(0xFF006DEA),
    blue300: Color(0xFF0072FF),
    blue400: Color(0xFF1D8FFF),
    blue500: Color(0xFF4FA4FF),
    blue600: Color(0xFF73BAFF),
    blue700: Color(0xFF98CEFF),
    blue800: Color(0xFFB9DEFF),
    blue900: Color(0xFFE1F1FF),
    blue1000: Color(0xFFF3F9FF),
  );

  @override
  BlueColors copyWith({
    Color? blue100,
    Color? blue200,
    Color? blue300,
    Color? blue400,
    Color? blue500,
    Color? blue600,
    Color? blue700,
    Color? blue800,
    Color? blue900,
    Color? blue1000,
  }) {
    return BlueColors(
      blue100: blue100 ?? this.blue100,
      blue200: blue200 ?? this.blue200,
      blue300: blue300 ?? this.blue300,
      blue400: blue400 ?? this.blue400,
      blue500: blue500 ?? this.blue500,
      blue600: blue600 ?? this.blue600,
      blue700: blue700 ?? this.blue700,
      blue800: blue800 ?? this.blue800,
      blue900: blue900 ?? this.blue900,
      blue1000: blue1000 ?? this.blue1000,
    );
  }

  @override
  BlueColors lerp(ThemeExtension<BlueColors>? other, double t) {
    if (other is! BlueColors) return this;
    return BlueColors(
      blue100: Color.lerp(blue100, other.blue100, t)!,
      blue200: Color.lerp(blue200, other.blue200, t)!,
      blue300: Color.lerp(blue300, other.blue300, t)!,
      blue400: Color.lerp(blue400, other.blue400, t)!,
      blue500: Color.lerp(blue500, other.blue500, t)!,
      blue600: Color.lerp(blue600, other.blue600, t)!,
      blue700: Color.lerp(blue700, other.blue700, t)!,
      blue800: Color.lerp(blue800, other.blue800, t)!,
      blue900: Color.lerp(blue900, other.blue900, t)!,
      blue1000: Color.lerp(blue1000, other.blue1000, t)!,
    );
  }
}
