import 'package:flutter/material.dart';
import '../system/system_primary_colors.dart';
import '../system/system_grey_colors.dart';
import '../system/system_red_colors.dart';
import '../system/system_green_colors.dart';
import '../system/system_blue_colors.dart';
import '../system/system_yellow_colors.dart';

/// Component-level text field colors that map system semantic colors to specific text field component roles.
/// This represents the Component layer in our Token → System → Component color architecture.
@Deprecated('Use InputDecorationTheme with ColorScheme/SemanticColors instead of custom component extensions.')
class ComponentTextFieldColors
    extends ThemeExtension<ComponentTextFieldColors> {
  const ComponentTextFieldColors({
    // Filled TextField Colors
    required this.filledContainerColor,
    required this.filledLabelColor,

    // Outlined TextField Colors
    required this.outlinedOutlineColor,
    required this.outlinedOutlineColorBold,

    // Error TextField Colors
    required this.errorColor,

    // Danger TextField Colors
    required this.dangerColor,

    // Success TextField Colors
    required this.successColor,

    // Info TextField Colors
    required this.infoColor,

    // Text Colors
    required this.textColor,
    required this.textColorBold,
    required this.textSubtleColor,
  });

  // Filled TextField Colors
  final Color filledContainerColor;
  final Color filledLabelColor;

  // Outlined TextField Colors
  final Color outlinedOutlineColor;
  final Color outlinedOutlineColorBold;

  // Error TextField Colors
  final Color errorColor;

  // Danger TextField Colors
  final Color dangerColor;

  // Success TextField Colors
  final Color successColor;

  // Info TextField Colors
  final Color infoColor;

  // Text Colors
  final Color textColor;
  final Color textColorBold;
  final Color textSubtleColor;

  /// Light theme text field colors
  static ComponentTextFieldColors light({
    required SystemPrimaryColors primary,
    required SystemGreyColors grey,
    required SystemRedColors red,
    required SystemGreenColors green,
    required SystemBlueColors blue,
    required SystemYellowColors yellow,
  }) {
    return ComponentTextFieldColors(
      // Filled TextField - Uses surface colors for container and surface-container for label
      filledContainerColor: grey.surface,
      filledLabelColor: grey.surfaceContainer,

      // Outlined TextField - Uses surface colors for outline variations
      outlinedOutlineColor: grey.onSurfaceLight,
      outlinedOutlineColorBold: grey.onContainerContainer,

      // Error TextField - Uses red semantic colors
      errorColor: red.onErrorContainer,

      // Danger TextField - Uses yellow semantic colors for danger/warning
      dangerColor: yellow.onWarningContainer,

      // Success TextField - Uses green semantic colors
      successColor: green.onSuccessContainer,

      // Info TextField - Uses blue semantic colors
      infoColor: blue.onInfoContainer,

      // Text Colors - Uses surface colors for text contrast
      textColor: grey.onSurfaceLight,
      textColorBold: grey.onContainerContainer,
      textSubtleColor: grey.onSurface,
    );
  }

  /// Dark theme text field colors
  static ComponentTextFieldColors dark({
    required SystemPrimaryColors primary,
    required SystemGreyColors grey,
    required SystemRedColors red,
    required SystemGreenColors green,
    required SystemBlueColors blue,
    required SystemYellowColors yellow,
  }) {
    return ComponentTextFieldColors(
      // Filled TextField - Uses surface colors for container and surface-container for label
      filledContainerColor: grey.surface,
      filledLabelColor: grey.surfaceContainer,

      // Outlined TextField - Uses surface colors for outline variations
      outlinedOutlineColor: grey.onSurfaceLight,
      outlinedOutlineColorBold: grey.onContainerContainer,

      // Error TextField - Uses red semantic colors
      errorColor: red.onErrorContainer,

      // Danger TextField - Uses yellow semantic colors for danger/warning
      dangerColor: yellow.onWarningContainer,

      // Success TextField - Uses green semantic colors
      successColor: green.onSuccessContainer,

      // Info TextField - Uses blue semantic colors
      infoColor: blue.onInfoContainer,

      // Text Colors - Uses surface colors for text contrast
      textColor: grey.onSurfaceLight,
      textColorBold: grey.onContainerContainer,
      textSubtleColor: grey.onSurface,
    );
  }

  @override
  ComponentTextFieldColors copyWith({
    Color? filledContainerColor,
    Color? filledLabelColor,
    Color? outlinedOutlineColor,
    Color? outlinedOutlineColorBold,
    Color? errorColor,
    Color? dangerColor,
    Color? successColor,
    Color? infoColor,
    Color? textColor,
    Color? textColorBold,
    Color? textSubtleColor,
  }) {
    return ComponentTextFieldColors(
      filledContainerColor: filledContainerColor ?? this.filledContainerColor,
      filledLabelColor: filledLabelColor ?? this.filledLabelColor,
      outlinedOutlineColor: outlinedOutlineColor ?? this.outlinedOutlineColor,
      outlinedOutlineColorBold:
          outlinedOutlineColorBold ?? this.outlinedOutlineColorBold,
      errorColor: errorColor ?? this.errorColor,
      dangerColor: dangerColor ?? this.dangerColor,
      successColor: successColor ?? this.successColor,
      infoColor: infoColor ?? this.infoColor,
      textColor: textColor ?? this.textColor,
      textColorBold: textColorBold ?? this.textColorBold,
      textSubtleColor: textSubtleColor ?? this.textSubtleColor,
    );
  }

  @override
  ComponentTextFieldColors lerp(
    ThemeExtension<ComponentTextFieldColors>? other,
    double t,
  ) {
    if (other is! ComponentTextFieldColors) {
      return this;
    }
    return ComponentTextFieldColors(
      filledContainerColor: Color.lerp(
        filledContainerColor,
        other.filledContainerColor,
        t,
      )!,
      filledLabelColor: Color.lerp(
        filledLabelColor,
        other.filledLabelColor,
        t,
      )!,
      outlinedOutlineColor: Color.lerp(
        outlinedOutlineColor,
        other.outlinedOutlineColor,
        t,
      )!,
      outlinedOutlineColorBold: Color.lerp(
        outlinedOutlineColorBold,
        other.outlinedOutlineColorBold,
        t,
      )!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      textColorBold: Color.lerp(textColorBold, other.textColorBold, t)!,
      textSubtleColor: Color.lerp(textSubtleColor, other.textSubtleColor, t)!,
    );
  }
}
