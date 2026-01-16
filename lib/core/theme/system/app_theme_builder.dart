import 'package:flutter/material.dart';

import '../tokens/sizing.dart';
import '../tokens/spacing.dart';
import 'app_color_scheme_builder.dart';
import 'state_opacities.dart';

/// Builds the app's ThemeData from derived color roles.
///
/// This remains context-free (no MediaQuery reads). Any environment-aware
/// toggles (e.g. high contrast) must be passed in explicitly by the app shell.
abstract final class AppThemeBuilder {
  static ThemeData build({
    required Brightness brightness,
    bool highContrast = false,
  }) {
    final colors = AppColorSchemeBuilder.build(
      brightness: brightness,
      highContrast: highContrast,
    );
    final scheme = colors.scheme;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      colorScheme: scheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, AppSizing.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.space24),
          ),
          elevation: 1,
          shadowColor: scheme.shadow,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(0, AppSizing.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.space24),
          ),
          side: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(
              alpha: StateOpacities.disabledContainer,
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.all(0),
        color: scheme.surface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: scheme.outline),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      // textTheme will be applied through AppTheme.*() which uses
      // TypographySystem.applyTypography.
      extensions: [
        colors.semantic,
      ],
    );
  }
}

