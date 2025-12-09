import 'package:flutter/material.dart';
import '../tokens/primary_colors.dart';

@Deprecated('Use ColorScheme.primary/onPrimary/primaryContainer/onPrimaryContainer instead of SystemPrimaryColors.')
class SystemPrimaryColors extends ThemeExtension<SystemPrimaryColors> {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  const SystemPrimaryColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  static SystemPrimaryColors light(PrimaryColors primaryTokens) {
    return SystemPrimaryColors(
      primary: primaryTokens.primary900,
      onPrimary: primaryTokens.primary700,
      primaryContainer: primaryTokens.primary400,
      onPrimaryContainer: primaryTokens.primary200,
    );
  }

  static SystemPrimaryColors dark(PrimaryColors primaryTokens) {
    return SystemPrimaryColors(
      primary: primaryTokens.primary200,
      onPrimary: primaryTokens.primary900,
      primaryContainer: primaryTokens.primary700,
      onPrimaryContainer: primaryTokens.primary100,
    );
  }

  @override
  SystemPrimaryColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
  }) {
    return SystemPrimaryColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
    );
  }

  @override
  SystemPrimaryColors lerp(
    ThemeExtension<SystemPrimaryColors>? other,
    double t,
  ) {
    if (other is! SystemPrimaryColors) return this;
    return SystemPrimaryColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
    );
  }
}
