import 'package:flutter/material.dart';
import '../tokens/green_colors.dart';
import '../tokens/blue_colors.dart';
import '../tokens/yellow_colors.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  /// Build semantic status roles from dedicated per-status schemes.
  ///
  /// This keeps status colors consistent with the same role semantics as M3:
  /// - `success` uses `successScheme.primary`
  /// - `onSuccess` uses `successScheme.onPrimary`
  /// - ...and the same for container roles
  static SemanticColors fromSchemes({
    required ColorScheme success,
    required ColorScheme info,
    required ColorScheme warning,
  }) {
    return SemanticColors(
      success: success.primary,
      onSuccess: success.onPrimary,
      successContainer: success.primaryContainer,
      onSuccessContainer: success.onPrimaryContainer,
      info: info.primary,
      onInfo: info.onPrimary,
      infoContainer: info.primaryContainer,
      onInfoContainer: info.onPrimaryContainer,
      warning: warning.primary,
      onWarning: warning.onPrimary,
      warningContainer: warning.primaryContainer,
      onWarningContainer: warning.onPrimaryContainer,
    );
  }

  /// Build light semantic colors from token palettes.
  static SemanticColors light({
    required GreenColors green,
    required BlueColors blue,
    required YellowColors yellow,
  }) {
    return SemanticColors(
      // Success (Green)
      success: green.green500,
      onSuccess: green.green100,
      successContainer: green.green200,
      onSuccessContainer: green.green700,
      // Info (Blue)
      info: blue.blue600,
      onInfo: blue.blue100,
      infoContainer: blue.blue100,
      onInfoContainer: blue.blue800,
      // Warning (Yellow)
      warning: yellow.yellow400,
      onWarning: yellow.yellow200,
      warningContainer: yellow.yellow100,
      onWarningContainer: yellow.yellow600,
    );
  }

  /// Build dark semantic colors from token palettes.
  static SemanticColors dark({
    required GreenColors green,
    required BlueColors blue,
    required YellowColors yellow,
  }) {
    return SemanticColors(
      // Success (Green)
      success: green.green300,
      onSuccess: green.green900,
      successContainer: green.green700,
      onSuccessContainer: green.green100,
      // Info (Blue)
      info: blue.blue400,
      onInfo: blue.blue900,
      infoContainer: blue.blue800,
      onInfoContainer: blue.blue100,
      // Warning (Yellow)
      warning: yellow.yellow300,
      onWarning: yellow.yellow900,
      warningContainer: yellow.yellow800,
      onWarningContainer: yellow.yellow100,
    );
  }

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
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
