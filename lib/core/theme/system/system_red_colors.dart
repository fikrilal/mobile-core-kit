import 'package:flutter/material.dart';
import '../tokens/red_colors.dart';

@Deprecated('Use ColorScheme.error/onError/errorContainer/onErrorContainer instead of SystemRedColors.')
class SystemRedColors extends ThemeExtension<SystemRedColors> {
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  const SystemRedColors({
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
  });

  static SystemRedColors light(RedColors redTokens) {
    return SystemRedColors(
      error: redTokens.red800,
      onError: redTokens.red100,
      errorContainer: redTokens.red500,
      onErrorContainer: redTokens.red1000,
    );
  }

  static SystemRedColors dark(RedColors redTokens) {
    return SystemRedColors(
      error: redTokens.red400,
      onError: redTokens.red800,
      errorContainer: redTokens.red600,
      onErrorContainer: redTokens.red200,
    );
  }

  @override
  SystemRedColors copyWith({
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
  }) {
    return SystemRedColors(
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
    );
  }

  @override
  SystemRedColors lerp(ThemeExtension<SystemRedColors>? other, double t) {
    if (other is! SystemRedColors) return this;
    return SystemRedColors(
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
    );
  }
}
