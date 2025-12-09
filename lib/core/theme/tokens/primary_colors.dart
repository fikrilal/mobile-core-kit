import 'package:flutter/material.dart';

@immutable
class PrimaryColors extends ThemeExtension<PrimaryColors> {
  final Color primary100;
  final Color primary200;
  final Color primary300;
  final Color primary400;
  final Color primary500;
  final Color primary600;
  final Color primary700;
  final Color primary800;
  final Color primary900;
  final Color primary1000;

  const PrimaryColors({
    required this.primary100,
    required this.primary200,
    required this.primary300,
    required this.primary400,
    required this.primary500,
    required this.primary600,
    required this.primary700,
    required this.primary800,
    required this.primary900,
    required this.primary1000,
  });

  static const PrimaryColors light = PrimaryColors(
    primary100: Color(0xFFF4F7FB),
    primary200: Color(0xFFE9EEF5),
    primary300: Color(0xFFCEDBE9),
    primary400: Color(0xFF7199BF),
    primary500: Color(0xFF4F7CA8),
    primary600: Color(0xFF3C638D),
    primary700: Color(0xFF325072),
    primary800: Color(0xFF2C4560),
    primary900: Color(0xFF243447),
    primary1000: Color(0xFF1B2636),
  );

  static const PrimaryColors dark = PrimaryColors(
    primary100: Color(0xFF1B2636),
    primary200: Color(0xFF243447),
    primary300: Color(0xFF2C4560),
    primary400: Color(0xFF325072),
    primary500: Color(0xFF3C638D),
    primary600: Color(0xFF4F7CA8),
    primary700: Color(0xFF7199BF),
    primary800: Color(0xFFCEDBE9),
    primary900: Color(0xFFE9EEF5),
    primary1000: Color(0xFFF4F7FB),
  );

  @override
  PrimaryColors copyWith({
    Color? primary100,
    Color? primary200,
    Color? primary300,
    Color? primary400,
    Color? primary500,
    Color? primary600,
    Color? primary700,
    Color? primary800,
    Color? primary900,
    Color? primary1000,
  }) {
    return PrimaryColors(
      primary100: primary100 ?? this.primary100,
      primary200: primary200 ?? this.primary200,
      primary300: primary300 ?? this.primary300,
      primary400: primary400 ?? this.primary400,
      primary500: primary500 ?? this.primary500,
      primary600: primary600 ?? this.primary600,
      primary700: primary700 ?? this.primary700,
      primary800: primary800 ?? this.primary800,
      primary900: primary900 ?? this.primary900,
      primary1000: primary1000 ?? this.primary1000,
    );
  }

  @override
  PrimaryColors lerp(ThemeExtension<PrimaryColors>? other, double t) {
    if (other is! PrimaryColors) return this;
    return PrimaryColors(
      primary100: Color.lerp(primary100, other.primary100, t)!,
      primary200: Color.lerp(primary200, other.primary200, t)!,
      primary300: Color.lerp(primary300, other.primary300, t)!,
      primary400: Color.lerp(primary400, other.primary400, t)!,
      primary500: Color.lerp(primary500, other.primary500, t)!,
      primary600: Color.lerp(primary600, other.primary600, t)!,
      primary700: Color.lerp(primary700, other.primary700, t)!,
      primary800: Color.lerp(primary800, other.primary800, t)!,
      primary900: Color.lerp(primary900, other.primary900, t)!,
      primary1000: Color.lerp(primary1000, other.primary1000, t)!,
    );
  }
}
