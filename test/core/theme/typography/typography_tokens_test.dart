import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/typography/tokens/type_metrics.dart';
import 'package:mobile_core_kit/core/theme/typography/tokens/type_scale.dart';
import 'package:mobile_core_kit/core/theme/typography/tokens/type_weights.dart';
import 'package:mobile_core_kit/core/theme/typography/tokens/typefaces.dart';

void main() {
  group('Typography tokens (contract)', () {
    test('Typefaces are configured', () {
      expect(Typefaces.primary, isNotEmpty);
    });

    test('TypeScale values are stable', () {
      expect(TypeScale.displayLarge, 57.0);
      expect(TypeScale.displayMedium, 45.0);
      expect(TypeScale.displaySmall, 36.0);

      expect(TypeScale.headlineLarge, 32.0);
      expect(TypeScale.headlineMedium, 28.0);
      expect(TypeScale.headlineSmall, 24.0);

      expect(TypeScale.titleLarge, 22.0);
      expect(TypeScale.titleMedium, 16.0);
      expect(TypeScale.titleSmall, 14.0);

      expect(TypeScale.bodyLarge, 16.0);
      expect(TypeScale.bodyMedium, 14.0);
      expect(TypeScale.bodySmall, 12.0);

      expect(TypeScale.labelLarge, 14.0);
      expect(TypeScale.labelMedium, 12.0);
      expect(TypeScale.labelSmall, 11.0);
    });

    test('TypeWeights semantic roles are stable', () {
      expect(TypeWeights.regular, FontWeight.w400);
      expect(TypeWeights.medium, FontWeight.w500);
      expect(TypeWeights.semiBold, FontWeight.w600);
      expect(TypeWeights.bold, FontWeight.w700);

      expect(TypeWeights.displayWeight, TypeWeights.bold);
      expect(TypeWeights.headlineWeight, TypeWeights.semiBold);
      expect(TypeWeights.titleWeight, TypeWeights.semiBold);
      expect(TypeWeights.bodyWeight, TypeWeights.regular);
      expect(TypeWeights.labelWeight, TypeWeights.medium);
    });

    test('TypeMetrics invariants are stable', () {
      expect(TypeMetrics.displayLineHeight, 1.2);
      expect(TypeMetrics.headlineLineHeight, 1.3);
      expect(TypeMetrics.titleLineHeight, 1.4);
      expect(TypeMetrics.bodyLineHeight, 1.5);
      expect(TypeMetrics.labelLineHeight, 1.4);

      expect(TypeMetrics.minCharactersPerLine, 40);
      expect(TypeMetrics.maxCharactersPerLine, 75);
    });
  });
}
