import 'package:flutter/material.dart';
import 'system/app_theme_builder.dart';

final ThemeData darkTheme = AppThemeBuilder.build(brightness: Brightness.dark);

final ThemeData darkHighContrastTheme = AppThemeBuilder.build(
  brightness: Brightness.dark,
  highContrast: true,
);
