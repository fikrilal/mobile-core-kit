import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/dark_theme.dart';
import 'package:mobile_core_kit/core/theme/light_theme.dart';
import 'package:mobile_core_kit/core/theme/system/color_contrast.dart';

void main() {
  group('Theme surface hierarchy contract', () {
    for (final entry in <String, ThemeData>{
      'light': lightTheme,
      'lightHighContrast': lightHighContrastTheme,
      'dark': darkTheme,
      'darkHighContrast': darkHighContrastTheme,
    }.entries) {
      test('${entry.key} uses container surfaces for cards and overlays', () {
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

