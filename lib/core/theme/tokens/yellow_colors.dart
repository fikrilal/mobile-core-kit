import 'package:flutter/material.dart';

@immutable
class YellowColors extends ThemeExtension<YellowColors> {
  final Color yellow100;
  final Color yellow200;
  final Color yellow300;
  final Color yellow400;
  final Color yellow500;
  final Color yellow600;
  final Color yellow700;
  final Color yellow800;
  final Color yellow900;
  final Color yellow1000;

  const YellowColors({
    required this.yellow100,
    required this.yellow200,
    required this.yellow300,
    required this.yellow400,
    required this.yellow500,
    required this.yellow600,
    required this.yellow700,
    required this.yellow800,
    required this.yellow900,
    required this.yellow1000,
  });

  static const YellowColors light = YellowColors(
    yellow100: Color(0xFFFFF8E0),
    yellow200: Color(0xFFFEEDB1),
    yellow300: Color(0xFFFEDD6C),
    yellow400: Color(0xFFFFCD00),
    yellow500: Color(0xFFF1AB02),
    yellow600: Color(0xFFE39304),
    yellow700: Color(0xFFCE7C06),
    yellow800: Color(0xFFBC6E06),
    yellow900: Color(0xFFA76005),
    yellow1000: Color(0xFF925304),
  );

  static const YellowColors dark = YellowColors(
    yellow100: Color(0xFF925304),
    yellow200: Color(0xFFA76005),
    yellow300: Color(0xFFBC6E06),
    yellow400: Color(0xFFCE7C06),
    yellow500: Color(0xFFE39304),
    yellow600: Color(0xFFF1AB02),
    yellow700: Color(0xFFFFCD00),
    yellow800: Color(0xFFFEDD6C),
    yellow900: Color(0xFFFEEDB1),
    yellow1000: Color(0xFFFFF8E0),
  );

  @override
  YellowColors copyWith({
    Color? yellow100,
    Color? yellow200,
    Color? yellow300,
    Color? yellow400,
    Color? yellow500,
    Color? yellow600,
    Color? yellow700,
    Color? yellow800,
    Color? yellow900,
    Color? yellow1000,
  }) {
    return YellowColors(
      yellow100: yellow100 ?? this.yellow100,
      yellow200: yellow200 ?? this.yellow200,
      yellow300: yellow300 ?? this.yellow300,
      yellow400: yellow400 ?? this.yellow400,
      yellow500: yellow500 ?? this.yellow500,
      yellow600: yellow600 ?? this.yellow600,
      yellow700: yellow700 ?? this.yellow700,
      yellow800: yellow800 ?? this.yellow800,
      yellow900: yellow900 ?? this.yellow900,
      yellow1000: yellow1000 ?? this.yellow1000,
    );
  }

  @override
  YellowColors lerp(ThemeExtension<YellowColors>? other, double t) {
    if (other is! YellowColors) return this;
    return YellowColors(
      yellow100: Color.lerp(yellow100, other.yellow100, t)!,
      yellow200: Color.lerp(yellow200, other.yellow200, t)!,
      yellow300: Color.lerp(yellow300, other.yellow300, t)!,
      yellow400: Color.lerp(yellow400, other.yellow400, t)!,
      yellow500: Color.lerp(yellow500, other.yellow500, t)!,
      yellow600: Color.lerp(yellow600, other.yellow600, t)!,
      yellow700: Color.lerp(yellow700, other.yellow700, t)!,
      yellow800: Color.lerp(yellow800, other.yellow800, t)!,
      yellow900: Color.lerp(yellow900, other.yellow900, t)!,
      yellow1000: Color.lerp(yellow1000, other.yellow1000, t)!,
    );
  }
}
