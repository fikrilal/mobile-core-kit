import 'package:flutter/material.dart';
import '../system/system_primary_colors.dart';
import '../system/system_grey_colors.dart';
import '../system/system_red_colors.dart';
import '../system/system_green_colors.dart';
import '../system/system_blue_colors.dart';
import '../system/system_yellow_colors.dart';

/// Component-level button colors that map system semantic colors to specific button component roles.
/// This represents the Component layer in our Token → System → Component color architecture.
@Deprecated('Use Material button sub-themes (Elevated/Outlined/Filled) with ColorScheme and SemanticColors instead.')
class ComponentButtonColors extends ThemeExtension<ComponentButtonColors> {
  const ComponentButtonColors({
    // Filled Button Colors
    required this.filledContainerColor,
    required this.filledLabelColor,

    // Text Button Colors
    required this.textLabelColor,

    // Outlined Button Colors
    required this.outlinedOutlineColor,
    required this.outlinedLabelColor,

    // Disabled Button Colors
    required this.disabledContainerColor,
    required this.disabledLabelColor,

    // Error Button Colors
    required this.errorContainerColor,
    required this.errorLabelColor,

    // Success Button Colors
    required this.successContainerColor,
    required this.successLabelColor,

    // Info Button Colors
    required this.infoContainerColor,
    required this.infoLabelColor,

    // Warning Button Colors
    required this.warningContainerColor,
    required this.warningLabelColor,
  });

  // Filled Button Colors
  final Color filledContainerColor;
  final Color filledLabelColor;

  // Text Button Colors
  final Color textLabelColor;

  // Outlined Button Colors
  final Color outlinedOutlineColor;
  final Color outlinedLabelColor;

  // Disabled Button Colors
  final Color disabledContainerColor;
  final Color disabledLabelColor;

  // Error Button Colors
  final Color errorContainerColor;
  final Color errorLabelColor;

  // Success Button Colors
  final Color successContainerColor;
  final Color successLabelColor;

  // Info Button Colors
  final Color infoContainerColor;
  final Color infoLabelColor;

  // Warning Button Colors
  final Color warningContainerColor;
  final Color warningLabelColor;

  /// Light theme button colors
  static ComponentButtonColors light({
    required SystemPrimaryColors primary,
    required SystemGreyColors grey,
    required SystemRedColors red,
    required SystemGreenColors green,
    required SystemBlueColors blue,
    required SystemYellowColors yellow,
  }) {
    return ComponentButtonColors(
      // Filled Button - Uses primary colors
      filledContainerColor: primary.primary,
      filledLabelColor: grey.surface,

      // Text Button - Uses primary for text
      textLabelColor: primary.primary,

      // Outlined Button - Uses primary for outline and text
      outlinedOutlineColor: primary.onPrimary,
      outlinedLabelColor: primary.onPrimary,

      // Disabled Button - Uses grey colors
      disabledContainerColor: grey.onSurfaceLight,
      disabledLabelColor: grey.surfaceContainer,

      // Error Button - Uses red semantic colors
      errorContainerColor: red.error,
      errorLabelColor: red.onError,

      // Success Button - Uses green semantic colors
      successContainerColor: green.success,
      successLabelColor: green.successContainer,

      // Info Button - Uses blue semantic colors
      infoContainerColor: blue.info,
      infoLabelColor: blue.onInfo,

      // Warning Button - Uses yellow semantic colors
      warningContainerColor: yellow.warning,
      warningLabelColor: yellow.onWarningContainer,
    );
  }

  /// Dark theme button colors
  static ComponentButtonColors dark({
    required SystemPrimaryColors primary,
    required SystemGreyColors grey,
    required SystemRedColors red,
    required SystemGreenColors green,
    required SystemBlueColors blue,
    required SystemYellowColors yellow,
  }) {
    return ComponentButtonColors(
      // Filled Button - Uses primary colors
      filledContainerColor: primary.primary,
      filledLabelColor: grey.surface,

      // Text Button - Uses primary for text
      textLabelColor: primary.primary,

      // Outlined Button - Uses primary for outline and text
      outlinedOutlineColor: primary.onPrimary,
      outlinedLabelColor: primary.onPrimary,

      // Disabled Button - Uses grey colors
      disabledContainerColor: grey.onSurfaceLight,
      disabledLabelColor: grey.surfaceContainer,

      // Error Button - Uses red semantic colors
      errorContainerColor: red.error,
      errorLabelColor: red.onError,

      // Success Button - Uses green semantic colors
      successContainerColor: green.success,
      successLabelColor: green.successContainer,

      // Info Button - Uses blue semantic colors
      infoContainerColor: blue.info,
      infoLabelColor: blue.onInfo,

      // Warning Button - Uses yellow semantic colors
      warningContainerColor: yellow.warning,
      warningLabelColor: yellow.onWarningContainer,
    );
  }

  @override
  ComponentButtonColors copyWith({
    Color? filledContainerColor,
    Color? filledLabelColor,
    Color? textLabelColor,
    Color? outlinedOutlineColor,
    Color? outlinedLabelColor,
    Color? disabledContainerColor,
    Color? disabledLabelColor,
    Color? errorContainerColor,
    Color? errorLabelColor,
    Color? successContainerColor,
    Color? successLabelColor,
    Color? infoContainerColor,
    Color? infoLabelColor,
    Color? warningContainerColor,
    Color? warningLabelColor,
  }) {
    return ComponentButtonColors(
      filledContainerColor: filledContainerColor ?? this.filledContainerColor,
      filledLabelColor: filledLabelColor ?? this.filledLabelColor,
      textLabelColor: textLabelColor ?? this.textLabelColor,
      outlinedOutlineColor: outlinedOutlineColor ?? this.outlinedOutlineColor,
      outlinedLabelColor: outlinedLabelColor ?? this.outlinedLabelColor,
      disabledContainerColor:
          disabledContainerColor ?? this.disabledContainerColor,
      disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
      errorContainerColor: errorContainerColor ?? this.errorContainerColor,
      errorLabelColor: errorLabelColor ?? this.errorLabelColor,
      successContainerColor:
          successContainerColor ?? this.successContainerColor,
      successLabelColor: successLabelColor ?? this.successLabelColor,
      infoContainerColor: infoContainerColor ?? this.infoContainerColor,
      infoLabelColor: infoLabelColor ?? this.infoLabelColor,
      warningContainerColor:
          warningContainerColor ?? this.warningContainerColor,
      warningLabelColor: warningLabelColor ?? this.warningLabelColor,
    );
  }

  @override
  ComponentButtonColors lerp(
    ThemeExtension<ComponentButtonColors>? other,
    double t,
  ) {
    if (other is! ComponentButtonColors) {
      return this;
    }
    return ComponentButtonColors(
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
      textLabelColor: Color.lerp(textLabelColor, other.textLabelColor, t)!,
      outlinedOutlineColor: Color.lerp(
        outlinedOutlineColor,
        other.outlinedOutlineColor,
        t,
      )!,
      outlinedLabelColor: Color.lerp(
        outlinedLabelColor,
        other.outlinedLabelColor,
        t,
      )!,
      disabledContainerColor: Color.lerp(
        disabledContainerColor,
        other.disabledContainerColor,
        t,
      )!,
      disabledLabelColor: Color.lerp(
        disabledLabelColor,
        other.disabledLabelColor,
        t,
      )!,
      errorContainerColor: Color.lerp(
        errorContainerColor,
        other.errorContainerColor,
        t,
      )!,
      errorLabelColor: Color.lerp(errorLabelColor, other.errorLabelColor, t)!,
      successContainerColor: Color.lerp(
        successContainerColor,
        other.successContainerColor,
        t,
      )!,
      successLabelColor: Color.lerp(
        successLabelColor,
        other.successLabelColor,
        t,
      )!,
      infoContainerColor: Color.lerp(
        infoContainerColor,
        other.infoContainerColor,
        t,
      )!,
      infoLabelColor: Color.lerp(infoLabelColor, other.infoLabelColor, t)!,
      warningContainerColor: Color.lerp(
        warningContainerColor,
        other.warningContainerColor,
        t,
      )!,
      warningLabelColor: Color.lerp(
        warningLabelColor,
        other.warningLabelColor,
        t,
      )!,
    );
  }
}
