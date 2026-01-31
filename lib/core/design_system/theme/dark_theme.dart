import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/app_theme_builder.dart';

final ThemeData darkTheme = AppThemeBuilder.build(brightness: Brightness.dark);

final ThemeData darkHighContrastTheme = AppThemeBuilder.build(
  brightness: Brightness.dark,
  highContrast: true,
);
