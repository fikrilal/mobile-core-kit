import 'package:flutter/material.dart';
import '../tokens/tertiary_colors.dart';

@Deprecated('Use ColorScheme.tertiary/onTertiary/tertiaryContainer/onTertiaryContainer instead of SystemTertiaryColors.')
class SystemTertiaryColors extends ThemeExtension<SystemTertiaryColors> {
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  const SystemTertiaryColors({
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
  });

  static SystemTertiaryColors light(TertiaryColors tertiaryTokens) {
    return SystemTertiaryColors(
      tertiary: tertiaryTokens.tertiary200,
      onTertiary: tertiaryTokens.tertiary400,
      tertiaryContainer: tertiaryTokens.tertiary100,
      onTertiaryContainer: tertiaryTokens.tertiary300,
    );
  }

  static SystemTertiaryColors dark(TertiaryColors tertiaryTokens) {
    return SystemTertiaryColors(
      tertiary: tertiaryTokens.tertiary600,
      onTertiary: tertiaryTokens.tertiary800,
      tertiaryContainer: tertiaryTokens.tertiary700,
      onTertiaryContainer: tertiaryTokens.tertiary200,
    );
  }

  @override
  SystemTertiaryColors copyWith({
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
  }) {
    return SystemTertiaryColors(
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
    );
  }

  @override
  SystemTertiaryColors lerp(
    ThemeExtension<SystemTertiaryColors>? other,
    double t,
  ) {
    if (other is! SystemTertiaryColors) return this;
    return SystemTertiaryColors(
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      onTertiaryContainer: Color.lerp(
        onTertiaryContainer,
        other.onTertiaryContainer,
        t,
      )!,
    );
  }
}
