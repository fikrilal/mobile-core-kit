import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/theme/system/app_color_scheme_builder.dart';
import 'package:mobile_core_kit/core/theme/system/state_opacities.dart';
import 'package:mobile_core_kit/core/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';

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

    final navIndicatorColor = scheme.primaryContainer;
    final navSelectedIconColor = scheme.onPrimaryContainer;
    final navUnselectedIconColor = scheme.onSurfaceVariant;
    final navSelectedLabelColor = scheme.onSurface;
    final navUnselectedLabelColor = scheme.onSurfaceVariant;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: scheme.shadow,
      ),
      dividerTheme: DividerThemeData(
        // Decorative separators should be subtle; interactive boundaries should
        // use `scheme.outline` directly.
        color: scheme.outlineVariant,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      primaryIconTheme: IconThemeData(color: scheme.onSurface),
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
        // Default “raised” surface for cards/containers.
        color: scheme.surfaceContainerLow,
      ),
      dialogTheme: DialogThemeData(
        // Overlay surfaces should read as a layer above containers.
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: scheme.surfaceTint,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        modalBackgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: scheme.surfaceTint,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        disabledActionTextColor: scheme.onInverseSurface.withValues(
          alpha: StateOpacities.disabledContent,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.space12),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        subtitleTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        surfaceTintColor: scheme.surfaceTint,
        indicatorColor: navIndicatorColor,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? navSelectedIconColor
              : navUnselectedIconColor;
          return IconThemeData(color: color);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? navSelectedLabelColor
              : navUnselectedLabelColor;
          return TextStyle(color: color);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        useIndicator: true,
        indicatorColor: navIndicatorColor,
        selectedIconTheme: IconThemeData(color: navSelectedIconColor),
        unselectedIconTheme: IconThemeData(color: navUnselectedIconColor),
        selectedLabelTextStyle: TextStyle(color: navSelectedLabelColor),
        unselectedLabelTextStyle: TextStyle(color: navUnselectedLabelColor),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: scheme.surfaceTint,
        indicatorColor: navIndicatorColor,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? navSelectedIconColor
              : navUnselectedIconColor;
          return IconThemeData(color: color);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? navSelectedLabelColor
              : navUnselectedLabelColor;
          return TextStyle(color: color);
        }),
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
      checkboxTheme: CheckboxThemeData(
        side: WidgetStateBorderSide.resolveWith((states) {
          final isDisabled = states.contains(WidgetState.disabled);
          return BorderSide(
            width: 2,
            color: isDisabled
                ? scheme.onSurface.withValues(
                    alpha: StateOpacities.disabledContent,
                  )
                : scheme.outline,
          );
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: StateOpacities.disabledContainer,
            );
          }
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return scheme.primary.withValues(alpha: StateOpacities.focus);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.hover);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.pressed);
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: StateOpacities.disabledContent,
            );
          }
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return scheme.primary.withValues(alpha: StateOpacities.focus);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.hover);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.pressed);
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: StateOpacities.disabledContainer,
            );
          }
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.surfaceContainerHighest;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(
              alpha: StateOpacities.disabledContent,
            );
          }
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return scheme.primary.withValues(alpha: StateOpacities.focus);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.hover);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.onSurface.withValues(alpha: StateOpacities.pressed);
          }
          return null;
        }),
      ),
      // textTheme will be applied through AppTheme.*() which uses
      // TypographySystem.applyTypography.
      extensions: [colors.semantic],
    );
  }
}
