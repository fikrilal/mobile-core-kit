import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/app_theme_builder.dart';

final ThemeData lightTheme = AppThemeBuilder.build(
  brightness: Brightness.light,
);

final ThemeData lightHighContrastTheme = AppThemeBuilder.build(
  brightness: Brightness.light,
  highContrast: true,
);
