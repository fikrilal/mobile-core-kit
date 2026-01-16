import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/system/app_color_scheme_builder.dart';
import 'package:mobile_core_kit/core/theme/system/app_color_seeds.dart';

void main() {
  group('AppColorSchemeBuilder policy', () {
    test('uses neutral surfaceTint for neutral elevation', () {
      for (final brightness in <Brightness>[
        Brightness.light,
        Brightness.dark,
      ]) {
        final built =
            AppColorSchemeBuilder.build(brightness: brightness).scheme;
        final neutral = ColorScheme.fromSeed(
          seedColor: AppColorSeeds.neutralSeed,
          brightness: brightness,
        );

        expect(built.surfaceTint, neutral.surfaceTint);
        expect(built.surface, neutral.surface);
        expect(built.outline, neutral.outline);
      }
    });
  });
}

