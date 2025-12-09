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

final ThemeData darkTheme =
    (() {
      final scheme = ColorScheme.dark(
        primary: PrimaryColors.dark.primary300,
        onPrimary: GreyColors.dark.grey1000,
        primaryContainer: PrimaryColors.dark.primary700,
        onPrimaryContainer: PrimaryColors.dark.primary100,

        secondary: SecondaryColors.dark.secondary300,
        onSecondary: GreyColors.dark.grey1000,
        secondaryContainer: SecondaryColors.dark.secondary700,
        onSecondaryContainer: SecondaryColors.dark.secondary100,

        surface: GreyColors.dark.grey1000,
        onSurface: GreyColors.dark.grey100,
        onSurfaceVariant: GreyColors.dark.grey400,

        surfaceContainerHighest: GreyColors.dark.grey800,
        surfaceContainerHigh: GreyColors.dark.grey900,
        surfaceContainer: GreyColors.dark.grey1000,
        surfaceContainerLow: GreyColors.dark.grey1000,
        surfaceContainerLowest: GreyColors.dark.grey1000,

        outline: GreyColors.dark.grey700,
        outlineVariant: GreyColors.dark.grey800,

        inverseSurface: GreyColors.dark.grey200,
        onInverseSurface: GreyColors.dark.grey900,
        inversePrimary: PrimaryColors.dark.primary600,

        shadow: GreyColors.dark.grey100,
        scrim: GreyColors.dark.grey100,
      );
      return ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
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
            shadowColor: Colors.black12,
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
            borderSide: BorderSide(color: scheme.outlineVariant),
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
              color: scheme.onSurface.withOpacity(
                StateOpacities.disabledContainer,
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
          side: BorderSide(color: scheme.outlineVariant),
          labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
        // textTheme will be applied through AppTheme.dark() which uses TypographySystem.applyTypography
        extensions: [
          // Token colors (design tokens)
          PrimaryColors.dark,
          SecondaryColors.dark,
          TertiaryColors.dark,
          GreyColors.dark,
          GreenColors.dark,
          RedColors.dark,
          YellowColors.dark,
          BlueColors.dark,
          // Semantic status colors (non-M3)
          SemanticColors.dark(
            green: GreenColors.dark,
            blue: BlueColors.dark,
            yellow: YellowColors.dark,
          ),
        ],
      );
    })();
