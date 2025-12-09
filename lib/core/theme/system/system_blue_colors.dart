import 'package:flutter/material.dart';
import '../tokens/blue_colors.dart';

@immutable
@Deprecated('Use SemanticColors.info/onInfo/infoContainer/onInfoContainer instead of SystemBlueColors.')
class SystemBlueColors extends ThemeExtension<SystemBlueColors> {
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  const SystemBlueColors({
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  static SystemBlueColors light(BlueColors blueTokens) {
    return SystemBlueColors(
      info: blueTokens.blue600,
      onInfo: blueTokens.blue100,
      infoContainer: blueTokens.blue100,
      onInfoContainer: blueTokens.blue800,
    );
  }

  static SystemBlueColors dark(BlueColors blueTokens) {
    return SystemBlueColors(
      info: blueTokens.blue400,
      onInfo: blueTokens.blue900,
      infoContainer: blueTokens.blue800,
      onInfoContainer: blueTokens.blue100,
    );
  }

  @override
  SystemBlueColors copyWith({
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return SystemBlueColors(
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  SystemBlueColors lerp(ThemeExtension<SystemBlueColors>? other, double t) {
    if (other is! SystemBlueColors) return this;
    return SystemBlueColors(
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}
