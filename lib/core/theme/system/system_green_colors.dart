import 'package:flutter/material.dart';
import '../tokens/green_colors.dart';

@immutable
@Deprecated('Use SemanticColors.success/onSuccess/successContainer/onSuccessContainer instead of SystemGreenColors.')
class SystemGreenColors extends ThemeExtension<SystemGreenColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  const SystemGreenColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  static SystemGreenColors light(GreenColors greenTokens) {
    return SystemGreenColors(
      success: greenTokens.green500,
      onSuccess: greenTokens.green100,
      successContainer: greenTokens.green200,
      onSuccessContainer: greenTokens.green700,
    );
  }

  static SystemGreenColors dark(GreenColors greenTokens) {
    return SystemGreenColors(
      success: greenTokens.green300,
      onSuccess: greenTokens.green900,
      successContainer: greenTokens.green700,
      onSuccessContainer: greenTokens.green100,
    );
  }

  @override
  SystemGreenColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return SystemGreenColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  SystemGreenColors lerp(ThemeExtension<SystemGreenColors>? other, double t) {
    if (other is! SystemGreenColors) return this;
    return SystemGreenColors(
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
    );
  }
}
