import 'package:flutter/material.dart';
import '../tokens/grey_colors.dart';

@Deprecated('Use ColorScheme.surface/onSurface/surfaceContainer*/outline(Variant) instead of SystemGreyColors.')
class SystemGreyColors extends ThemeExtension<SystemGreyColors> {
  final Color surface;
  final Color onSurface;
  final Color onSurfaceLight;
  final Color surfaceContainer;
  final Color onSurfaceContainer;
  final Color onContainer;
  final Color onContainerContainer;

  const SystemGreyColors({
    required this.surface,
    required this.onSurface,
    required this.onSurfaceLight,
    required this.surfaceContainer,
    required this.onSurfaceContainer,
    required this.onContainer,
    required this.onContainerContainer,
  });

  static SystemGreyColors light(GreyColors greyTokens) {
    return SystemGreyColors(
      surface: greyTokens.grey100, // gray/100
      onSurface: greyTokens.grey300, // darkGray/300
      onSurfaceLight: greyTokens.grey200, // gray/200
      surfaceContainer: greyTokens.grey700, // gray/700
      onSurfaceContainer: greyTokens.grey1000, // gray/1000
      onContainer: greyTokens.grey400, // gray/400
      onContainerContainer: greyTokens.grey500, // gray/500
    );
  }

  static SystemGreyColors dark(GreyColors greyTokens) {
    return SystemGreyColors(
      surface: greyTokens.grey1000, // Inverted - Dark surface
      onSurface: greyTokens.grey800, // Inverted - Light on dark
      onSurfaceLight: greyTokens.grey900, // Inverted - Lighter on dark
      surfaceContainer: greyTokens.grey500, // Inverted - Container
      onSurfaceContainer: greyTokens.grey900, // Inverted - Light on container
      onContainer: greyTokens.grey700, // Inverted - Medium on dark
      onContainerContainer:
          greyTokens.grey600, // Inverted - Medium-light on dark
    );
  }

  @override
  SystemGreyColors copyWith({
    Color? surface,
    Color? onSurface,
    Color? onSurfaceLight,
    Color? surfaceContainer,
    Color? onSurfaceContainer,
    Color? onContainer,
    Color? onContainerContainer,
  }) {
    return SystemGreyColors(
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceLight: onSurfaceLight ?? this.onSurfaceLight,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      onSurfaceContainer: onSurfaceContainer ?? this.onSurfaceContainer,
      onContainer: onContainer ?? this.onContainer,
      onContainerContainer: onContainerContainer ?? this.onContainerContainer,
    );
  }

  @override
  SystemGreyColors lerp(ThemeExtension<SystemGreyColors>? other, double t) {
    if (other is! SystemGreyColors) return this;
    return SystemGreyColors(
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceLight: Color.lerp(onSurfaceLight, other.onSurfaceLight, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      onSurfaceContainer: Color.lerp(
        onSurfaceContainer,
        other.onSurfaceContainer,
        t,
      )!,
      onContainer: Color.lerp(onContainer, other.onContainer, t)!,
      onContainerContainer: Color.lerp(
        onContainerContainer,
        other.onContainerContainer,
        t,
      )!,
    );
  }
}
