import 'package:flutter/material.dart';
import 'tokens/blue_colors.dart';
import 'tokens/green_colors.dart';
import 'tokens/grey_colors.dart';
import 'tokens/primary_colors.dart';
import 'tokens/red_colors.dart';
import 'tokens/secondary_colors.dart';
import 'tokens/tertiary_colors.dart';
import 'tokens/yellow_colors.dart';
import 'extensions/semantic_colors.dart';
import 'responsive/sizing.dart';
import 'responsive/spacing.dart';
import 'system/state_opacities.dart';

final ThemeData lightTheme = (() {
  final scheme = ColorScheme.light(
    primary: PrimaryColors.light.primary500,
    onPrimary: GreyColors.light.grey100,
    primaryContainer: PrimaryColors.light.primary100,
    onPrimaryContainer: PrimaryColors.light.primary800,

    secondary: SecondaryColors.light.secondary500,
    onSecondary: GreyColors.light.grey100,
    secondaryContainer: SecondaryColors.light.secondary100,
    onSecondaryContainer: SecondaryColors.light.secondary800,

    surface: GreyColors.light.grey100,
    onSurface: GreyColors.light.grey900,
    onSurfaceVariant: GreyColors.light.grey700,

    surfaceContainerHighest: GreyColors.light.grey300,
    surfaceContainerHigh: GreyColors.light.grey200,
    surfaceContainer: GreyColors.light.grey100,
    surfaceContainerLow: GreyColors.light.grey100,
    surfaceContainerLowest: GreyColors.light.grey100,

    outline: GreyColors.light.grey400,
    outlineVariant: GreyColors.light.grey300,

    inverseSurface: GreyColors.light.grey900,
    onInverseSurface: GreyColors.light.grey200,
    inversePrimary: PrimaryColors.light.primary200,

    shadow: GreyColors.light.grey1000,
    scrim: GreyColors.light.grey1000,
  );
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: scheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(0, AppSizing.buttonHeightMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.space24)),
        elevation: 1,
        shadowColor: Colors.black12,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: const Size(0, AppSizing.buttonHeightMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.space24)),
        side: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.primary),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: scheme.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: scheme.error)),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: scheme.onSurface.withValues(alpha: StateOpacities.disabledContainer),
        ),
      ),
    ),
    cardTheme: CardThemeData(elevation: 0, margin: const EdgeInsets.all(0), color: scheme.surface),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surface,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    // textTheme will be applied through AppTheme.light() which uses TypographySystem.applyTypography
    extensions: [
      // Token colors (design tokens)
      PrimaryColors.light,
      SecondaryColors.light,
      TertiaryColors.light,
      GreyColors.light,
      GreenColors.light,
      RedColors.light,
      YellowColors.light,
      BlueColors.light,
      // Semantic status colors (non-M3)
      SemanticColors.light(
        green: GreenColors.light,
        blue: BlueColors.light,
        yellow: YellowColors.light,
      ),
    ],
  );
})();
