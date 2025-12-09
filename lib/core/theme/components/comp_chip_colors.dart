import 'package:flutter/material.dart';
import '../system/system_red_colors.dart';
import '../system/system_yellow_colors.dart';
import '../system/system_green_colors.dart';
import '../system/system_blue_colors.dart';

/// Component layer: Maps system semantic colors to chip/tag component roles
/// This represents the Component layer in the Token → System → Component architecture
@Deprecated('Use ChipThemeData + ColorScheme/SemanticColors for chips instead.')
class ComponentChipColors extends ThemeExtension<ComponentChipColors> {
  // Danger chip colors (Red)
  final Color dangerOutlineColor;
  final Color dangerTextColor;
  final Color dangerContainerColor;

  // Warning chip colors (Yellow)
  final Color warningOutlineColor;
  final Color warningTextColor;
  final Color warningContainerColor;

  // Success chip colors (Green)
  final Color successOutlineColor;
  final Color successTextColor;
  final Color successContainerColor;

  // Info chip colors (Blue)
  final Color infoOutlineColor;
  final Color infoTextColor;
  final Color infoContainerColor;

  const ComponentChipColors({
    required this.dangerOutlineColor,
    required this.dangerTextColor,
    required this.dangerContainerColor,
    required this.warningOutlineColor,
    required this.warningTextColor,
    required this.warningContainerColor,
    required this.successOutlineColor,
    required this.successTextColor,
    required this.successContainerColor,
    required this.infoOutlineColor,
    required this.infoTextColor,
    required this.infoContainerColor,
  });

  static ComponentChipColors light({
    required SystemRedColors red,
    required SystemYellowColors yellow,
    required SystemGreenColors green,
    required SystemBlueColors blue,
  }) {
    return ComponentChipColors(
      // Danger (Red) chip colors - using correct SystemRedColors properties
      dangerOutlineColor: red.error,
      dangerTextColor: red.onErrorContainer,
      dangerContainerColor: red.errorContainer,

      // Warning (Yellow) chip colors - using correct SystemYellowColors properties
      warningOutlineColor: yellow.warning,
      warningTextColor: yellow.onWarningContainer,
      warningContainerColor: yellow.onWarning,

      // Success (Green) chip colors - using correct SystemGreenColors properties
      successOutlineColor: green.success,
      successTextColor: green.onSuccessContainer,
      successContainerColor: green.successContainer,

      // Info (Blue) chip colors - using correct SystemBlueColors properties
      infoOutlineColor: blue.onInfoContainer,
      infoTextColor: blue.onInfoContainer,
      infoContainerColor: blue.infoContainer,
    );
  }

  static ComponentChipColors dark({
    required SystemRedColors red,
    required SystemYellowColors yellow,
    required SystemGreenColors green,
    required SystemBlueColors blue,
  }) {
    return ComponentChipColors(
      // Danger (Red) chip colors - using correct SystemRedColors properties
      dangerOutlineColor: red.error,
      dangerTextColor: red.onErrorContainer,
      dangerContainerColor: red.errorContainer,

      // Warning (Yellow) chip colors - using correct SystemYellowColors properties
      warningOutlineColor: yellow.warning,
      warningTextColor: yellow.onWarningContainer,
      warningContainerColor: yellow.onWarning,

      // Success (Green) chip colors - using correct SystemGreenColors properties
      successOutlineColor: green.success,
      successTextColor: green.onSuccessContainer,
      successContainerColor: green.successContainer,

      // Info (Blue) chip colors - using correct SystemBlueColors properties
      infoOutlineColor: blue.onInfoContainer,
      infoTextColor: blue.onInfoContainer,
      infoContainerColor: blue.infoContainer,
    );
  }

  // ... existing code ...
  @override
  ComponentChipColors copyWith({
    Color? dangerOutlineColor,
    Color? dangerTextColor,
    Color? dangerContainerColor,
    Color? warningOutlineColor,
    Color? warningTextColor,
    Color? warningContainerColor,
    Color? successOutlineColor,
    Color? successTextColor,
    Color? successContainerColor,
    Color? infoOutlineColor,
    Color? infoTextColor,
    Color? infoContainerColor,
  }) {
    return ComponentChipColors(
      dangerOutlineColor: dangerOutlineColor ?? this.dangerOutlineColor,
      dangerTextColor: dangerTextColor ?? this.dangerTextColor,
      dangerContainerColor: dangerContainerColor ?? this.dangerContainerColor,
      warningOutlineColor: warningOutlineColor ?? this.warningOutlineColor,
      warningTextColor: warningTextColor ?? this.warningTextColor,
      warningContainerColor:
          warningContainerColor ?? this.warningContainerColor,
      successOutlineColor: successOutlineColor ?? this.successOutlineColor,
      successTextColor: successTextColor ?? this.successTextColor,
      successContainerColor:
          successContainerColor ?? this.successContainerColor,
      infoOutlineColor: infoOutlineColor ?? this.infoOutlineColor,
      infoTextColor: infoTextColor ?? this.infoTextColor,
      infoContainerColor: infoContainerColor ?? this.infoContainerColor,
    );
  }

  @override
  ComponentChipColors lerp(
    ThemeExtension<ComponentChipColors>? other,
    double t,
  ) {
    if (other is! ComponentChipColors) {
      return this;
    }
    return ComponentChipColors(
      dangerOutlineColor: Color.lerp(
        dangerOutlineColor,
        other.dangerOutlineColor,
        t,
      )!,
      dangerTextColor: Color.lerp(dangerTextColor, other.dangerTextColor, t)!,
      dangerContainerColor: Color.lerp(
        dangerContainerColor,
        other.dangerContainerColor,
        t,
      )!,
      warningOutlineColor: Color.lerp(
        warningOutlineColor,
        other.warningOutlineColor,
        t,
      )!,
      warningTextColor: Color.lerp(
        warningTextColor,
        other.warningTextColor,
        t,
      )!,
      warningContainerColor: Color.lerp(
        warningContainerColor,
        other.warningContainerColor,
        t,
      )!,
      successOutlineColor: Color.lerp(
        successOutlineColor,
        other.successOutlineColor,
        t,
      )!,
      successTextColor: Color.lerp(
        successTextColor,
        other.successTextColor,
        t,
      )!,
      successContainerColor: Color.lerp(
        successContainerColor,
        other.successContainerColor,
        t,
      )!,
      infoOutlineColor: Color.lerp(
        infoOutlineColor,
        other.infoOutlineColor,
        t,
      )!,
      infoTextColor: Color.lerp(infoTextColor, other.infoTextColor, t)!,
      infoContainerColor: Color.lerp(
        infoContainerColor,
        other.infoContainerColor,
        t,
      )!,
    );
  }
}
