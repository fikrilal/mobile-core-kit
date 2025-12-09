import 'package:flutter/material.dart';

@immutable
class GreenColors extends ThemeExtension<GreenColors> {
  final Color green100;
  final Color green200;
  final Color green300;
  final Color green400;
  final Color green500;
  final Color green600;
  final Color green700;
  final Color green800;
  final Color green900;
  final Color green1000;

  const GreenColors({
    required this.green100,
    required this.green200,
    required this.green300,
    required this.green400,
    required this.green500,
    required this.green600,
    required this.green700,
    required this.green800,
    required this.green900,
    required this.green1000,
  });

  static const GreenColors light = GreenColors(
    green100: Color(0xFFEFFCF0),
    green200: Color(0xFFD6F7DA),
    green300: Color(0xFFB2EFB9),
    green400: Color(0xFF74E281),
    green500: Color(0xFF02C82B),
    green600: Color(0xFF17B52C),
    green700: Color(0xFF22A334),
    green800: Color(0xFF1F912E),
    green900: Color(0xFF1C832A),
    green1000: Color(0xFF197425),
  );

  static const GreenColors dark = GreenColors(
    green100: Color(0xFF197425),
    green200: Color(0xFF1C832A),
    green300: Color(0xFF1F912E),
    green400: Color(0xFF22A334),
    green500: Color(0xFF17B52C),
    green600: Color(0xFF02C82B),
    green700: Color(0xFF74E281),
    green800: Color(0xFFB2EFB9),
    green900: Color(0xFFD6F7DA),
    green1000: Color(0xFFEFFCF0),
  );

  @override
  GreenColors copyWith({
    Color? green100,
    Color? green200,
    Color? green300,
    Color? green400,
    Color? green500,
    Color? green600,
    Color? green700,
    Color? green800,
    Color? green900,
    Color? green1000,
  }) {
    return GreenColors(
      green100: green100 ?? this.green100,
      green200: green200 ?? this.green200,
      green300: green300 ?? this.green300,
      green400: green400 ?? this.green400,
      green500: green500 ?? this.green500,
      green600: green600 ?? this.green600,
      green700: green700 ?? this.green700,
      green800: green800 ?? this.green800,
      green900: green900 ?? this.green900,
      green1000: green1000 ?? this.green1000,
    );
  }

  @override
  GreenColors lerp(ThemeExtension<GreenColors>? other, double t) {
    if (other is! GreenColors) return this;
    return GreenColors(
      green100: Color.lerp(green100, other.green100, t)!,
      green200: Color.lerp(green200, other.green200, t)!,
      green300: Color.lerp(green300, other.green300, t)!,
      green400: Color.lerp(green400, other.green400, t)!,
      green500: Color.lerp(green500, other.green500, t)!,
      green600: Color.lerp(green600, other.green600, t)!,
      green700: Color.lerp(green700, other.green700, t)!,
      green800: Color.lerp(green800, other.green800, t)!,
      green900: Color.lerp(green900, other.green900, t)!,
      green1000: Color.lerp(green1000, other.green1000, t)!,
    );
  }
}
