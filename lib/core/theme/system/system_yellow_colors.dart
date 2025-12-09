import 'package:flutter/material.dart';
import '../tokens/yellow_colors.dart';

@immutable
@Deprecated('Use SemanticColors.warning/onWarning/warningContainer/onWarningContainer instead of SystemYellowColors.')
class SystemYellowColors extends ThemeExtension<SystemYellowColors> {
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  const SystemYellowColors({
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  static SystemYellowColors light(YellowColors yellowTokens) {
    return SystemYellowColors(
      warning: yellowTokens.yellow400,
      onWarning: yellowTokens.yellow200,
      warningContainer: yellowTokens.yellow100,
      onWarningContainer: yellowTokens.yellow600,
    );
  }

  static SystemYellowColors dark(YellowColors yellowTokens) {
    return SystemYellowColors(
      warning: yellowTokens.yellow300,
      onWarning: yellowTokens.yellow900,
      warningContainer: yellowTokens.yellow800,
      onWarningContainer: yellowTokens.yellow100,
    );
  }

  @override
  SystemYellowColors copyWith({
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return SystemYellowColors(
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  SystemYellowColors lerp(ThemeExtension<SystemYellowColors>? other, double t) {
    if (other is! SystemYellowColors) return this;
    return SystemYellowColors(
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
    );
  }
}
