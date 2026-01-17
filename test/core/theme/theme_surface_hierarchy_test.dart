import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/dark_theme.dart';
import 'package:mobile_core_kit/core/theme/light_theme.dart';
import 'package:mobile_core_kit/core/theme/system/color_contrast.dart';

void main() {
  group('Theme contract', () {
    for (final entry in <String, ThemeData>{
      'light': lightTheme,
      'lightHighContrast': lightHighContrastTheme,
      'dark': darkTheme,
      'darkHighContrast': darkHighContrastTheme,
    }.entries) {
      test('${entry.key} uses stable surfaces and component themes', () {
        final theme = entry.value;
        final scheme = theme.colorScheme;

        expect(theme.cardTheme.color, scheme.surfaceContainerLow);

        expect(theme.dialogTheme.backgroundColor, scheme.surfaceContainerHigh);
        expect(theme.bottomSheetTheme.backgroundColor, scheme.surfaceContainerHigh);
        expect(
          theme.bottomSheetTheme.modalBackgroundColor,
          scheme.surfaceContainerHigh,
        );

        expect(theme.dividerTheme.color, scheme.outlineVariant);

        expect(theme.appBarTheme.backgroundColor, scheme.surface);
        expect(theme.appBarTheme.foregroundColor, scheme.onSurface);
        expect(theme.appBarTheme.surfaceTintColor, scheme.surfaceTint);

        expect(theme.navigationBarTheme.backgroundColor, scheme.surfaceContainer);
        expect(theme.navigationBarTheme.indicatorColor, scheme.primaryContainer);

        final navSelectedIcon =
            theme.navigationBarTheme.iconTheme?.resolve({WidgetState.selected});
        final navUnselectedIcon = theme.navigationBarTheme.iconTheme?.resolve({});
        expect(navSelectedIcon?.color, scheme.onPrimaryContainer);
        expect(navUnselectedIcon?.color, scheme.onSurfaceVariant);

        final navSelectedLabel =
            theme.navigationBarTheme.labelTextStyle?.resolve({WidgetState.selected});
        final navUnselectedLabel = theme.navigationBarTheme.labelTextStyle?.resolve({});
        expect(navSelectedLabel?.color, scheme.onSurface);
        expect(navUnselectedLabel?.color, scheme.onSurfaceVariant);

        expect(theme.navigationRailTheme.backgroundColor, scheme.surfaceContainer);
        expect(theme.navigationRailTheme.indicatorColor, scheme.primaryContainer);
        expect(
          theme.navigationRailTheme.selectedIconTheme?.color,
          scheme.onPrimaryContainer,
        );
        expect(
          theme.navigationRailTheme.unselectedIconTheme?.color,
          scheme.onSurfaceVariant,
        );

        expect(
          theme.navigationDrawerTheme.backgroundColor,
          scheme.surfaceContainer,
        );
        expect(theme.navigationDrawerTheme.indicatorColor, scheme.primaryContainer);

        final drawerSelectedIcon =
            theme.navigationDrawerTheme.iconTheme?.resolve({WidgetState.selected});
        final drawerUnselectedIcon = theme.navigationDrawerTheme.iconTheme?.resolve({});
        expect(drawerSelectedIcon?.color, scheme.onPrimaryContainer);
        expect(drawerUnselectedIcon?.color, scheme.onSurfaceVariant);

        final drawerSelectedLabel =
            theme.navigationDrawerTheme.labelTextStyle?.resolve({WidgetState.selected});
        final drawerUnselectedLabel =
            theme.navigationDrawerTheme.labelTextStyle?.resolve({});
        expect(drawerSelectedLabel?.color, scheme.onSurface);
        expect(drawerUnselectedLabel?.color, scheme.onSurfaceVariant);

        expect(theme.snackBarTheme.backgroundColor, scheme.inverseSurface);

        // Sanity: text remains readable on these chosen surfaces.
        _expectAaTextContrast(
          name: 'card surface / onSurface',
          fg: scheme.onSurface,
          bg: scheme.surfaceContainerLow,
        );
        _expectAaTextContrast(
          name: 'dialog surface / onSurface',
          fg: scheme.onSurface,
          bg: scheme.surfaceContainerHigh,
        );
      });
    }
  });
}

void _expectAaTextContrast({
  required String name,
  required Color fg,
  required Color bg,
}) {
  final ratio = wcagContrastRatio(fg, bg);
  expect(
    ratio,
    greaterThanOrEqualTo(4.5),
    reason: '$name contrast was ${ratio.toStringAsFixed(2)} (min 4.5)',
  );
}
