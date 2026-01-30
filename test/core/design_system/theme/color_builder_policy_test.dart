import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/app_color_scheme_builder.dart';
import 'package:mobile_core_kit/core/design_system/theme/system/app_color_seeds.dart';

void main() {
  group('AppColorSchemeBuilder policy', () {
    test('uses neutral surfaceTint for neutral elevation', () {
      for (final brightness in <Brightness>[
        Brightness.light,
        Brightness.dark,
      ]) {
        for (final highContrast in <bool>[false, true]) {
          final built = AppColorSchemeBuilder.build(
            brightness: brightness,
            highContrast: highContrast,
          ).scheme;
          final neutral = ColorScheme.fromSeed(
            seedColor: AppColorSeeds.neutralSeed,
            brightness: brightness,
          );

          expect(built.surfaceTint, neutral.surfaceTint);
          expect(built.surface, neutral.surface);
          expect(built.outline, neutral.outline);

          if (highContrast) {
            expect(built.outlineVariant, built.outline);
          }
        }
      }
    });
  });
}
