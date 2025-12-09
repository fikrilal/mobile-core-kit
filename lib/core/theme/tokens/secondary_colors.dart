import 'package:flutter/material.dart';

class SecondaryColors extends ThemeExtension<SecondaryColors> {
  const SecondaryColors({
    required this.secondary100,
    required this.secondary200,
    required this.secondary300,
    required this.secondary400,
    required this.secondary500,
    required this.secondary600,
    required this.secondary700,
    required this.secondary800,
    required this.secondary900,
    required this.secondary1000,
  });

  final Color secondary100;
  final Color secondary200;
  final Color secondary300;
  final Color secondary400;
  final Color secondary500;
  final Color secondary600;
  final Color secondary700;
  final Color secondary800;
  final Color secondary900;
  final Color secondary1000;

  static const SecondaryColors light = SecondaryColors(
    secondary100: Color(0xFFEEF0F0),
    secondary200: Color(0xFFD8DFDE),
    secondary300: Color(0xFFAAB8B5),
    secondary400: Color(0xFF8FA19D),
    secondary500: Color(0xFF718682),
    secondary600: Color(0xFF5B6E6B),
    secondary700: Color(0xFF4B5956),
    secondary800: Color(0xFF404C4A),
    secondary900: Color(0xFF384241),
    secondary1000: Color(0xFF252C2B),
  );

  static const SecondaryColors dark = SecondaryColors(
    secondary100: Color(0xFF252C2B),
    secondary200: Color(0xFF384241),
    secondary300: Color(0xFF404C4A),
    secondary400: Color(0xFF4B5956),
    secondary500: Color(0xFF5B6E6B),
    secondary600: Color(0xFF718682),
    secondary700: Color(0xFF8FA19D),
    secondary800: Color(0xFFAAB8B5),
    secondary900: Color(0xFFD8DFDE),
    secondary1000: Color(0xFFEEF0F0),
  );

  @override
  SecondaryColors copyWith({
    Color? secondary100,
    Color? secondary200,
    Color? secondary300,
    Color? secondary400,
    Color? secondary500,
    Color? secondary600,
    Color? secondary700,
    Color? secondary800,
    Color? secondary900,
    Color? secondary1000,
  }) {
    return SecondaryColors(
      secondary100: secondary100 ?? this.secondary100,
      secondary200: secondary200 ?? this.secondary200,
      secondary300: secondary300 ?? this.secondary300,
      secondary400: secondary400 ?? this.secondary400,
      secondary500: secondary500 ?? this.secondary500,
      secondary600: secondary600 ?? this.secondary600,
      secondary700: secondary700 ?? this.secondary700,
      secondary800: secondary800 ?? this.secondary800,
      secondary900: secondary900 ?? this.secondary900,
      secondary1000: secondary1000 ?? this.secondary1000,
    );
  }

  @override
  SecondaryColors lerp(ThemeExtension<SecondaryColors>? other, double t) {
    if (other is! SecondaryColors) {
      return this;
    }
    return SecondaryColors(
      secondary100: Color.lerp(secondary100, other.secondary100, t)!,
      secondary200: Color.lerp(secondary200, other.secondary200, t)!,
      secondary300: Color.lerp(secondary300, other.secondary300, t)!,
      secondary400: Color.lerp(secondary400, other.secondary400, t)!,
      secondary500: Color.lerp(secondary500, other.secondary500, t)!,
      secondary600: Color.lerp(secondary600, other.secondary600, t)!,
      secondary700: Color.lerp(secondary700, other.secondary700, t)!,
      secondary800: Color.lerp(secondary800, other.secondary800, t)!,
      secondary900: Color.lerp(secondary900, other.secondary900, t)!,
      secondary1000: Color.lerp(secondary1000, other.secondary1000, t)!,
    );
  }
}
