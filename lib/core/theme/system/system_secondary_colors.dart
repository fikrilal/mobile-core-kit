import 'package:flutter/material.dart';
import '../tokens/secondary_colors.dart';

@Deprecated('Use ColorScheme.secondary/onSecondary/secondaryContainer/onSecondaryContainer instead of SystemSecondaryColors.')
class SystemSecondaryColors extends ThemeExtension<SystemSecondaryColors> {
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  const SystemSecondaryColors({
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
  });

  static SystemSecondaryColors light(SecondaryColors secondaryTokens) {
    return SystemSecondaryColors(
      secondary: secondaryTokens.secondary300,
      onSecondary: secondaryTokens.secondary500,
      secondaryContainer: secondaryTokens.secondary200,
      onSecondaryContainer: secondaryTokens.secondary400,
    );
  }

  static SystemSecondaryColors dark(SecondaryColors secondaryTokens) {
    return SystemSecondaryColors(
      secondary: secondaryTokens.secondary400,
      onSecondary: secondaryTokens.secondary800,
      secondaryContainer: secondaryTokens.secondary500,
      onSecondaryContainer: secondaryTokens.secondary200,
    );
  }

  @override
  SystemSecondaryColors copyWith({
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
  }) {
    return SystemSecondaryColors(
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
    );
  }

  @override
  SystemSecondaryColors lerp(
    ThemeExtension<SystemSecondaryColors>? other,
    double t,
  ) {
    if (other is! SystemSecondaryColors) return this;
    return SystemSecondaryColors(
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
    );
  }
}
