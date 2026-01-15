import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/dark_theme.dart';
import 'package:mobile_core_kit/core/theme/extensions/semantic_colors.dart';
import 'package:mobile_core_kit/core/theme/light_theme.dart';
import 'package:mobile_core_kit/core/theme/system/color_contrast.dart';

void main() {
  group('Theme color contrast', () {
    test('light theme meets WCAG AA for core roles', () {
      _expectCoreRoles(lightTheme.colorScheme);
      _expectSemanticRoles(lightTheme.extension<SemanticColors>()!);
    });

    test('dark theme meets WCAG AA for core roles', () {
      _expectCoreRoles(darkTheme.colorScheme);
      _expectSemanticRoles(darkTheme.extension<SemanticColors>()!);
    });
  });
}

void _expectCoreRoles(ColorScheme scheme) {
  // We gate the primary text-bearing pairs at AA normal text (4.5:1).
  _expectPair(
    name: 'primary/onPrimary',
    fg: scheme.onPrimary,
    bg: scheme.primary,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'primaryContainer/onPrimaryContainer',
    fg: scheme.onPrimaryContainer,
    bg: scheme.primaryContainer,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'secondary/onSecondary',
    fg: scheme.onSecondary,
    bg: scheme.secondary,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'secondaryContainer/onSecondaryContainer',
    fg: scheme.onSecondaryContainer,
    bg: scheme.secondaryContainer,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'tertiary/onTertiary',
    fg: scheme.onTertiary,
    bg: scheme.tertiary,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'tertiaryContainer/onTertiaryContainer',
    fg: scheme.onTertiaryContainer,
    bg: scheme.tertiaryContainer,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'error/onError',
    fg: scheme.onError,
    bg: scheme.error,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'errorContainer/onErrorContainer',
    fg: scheme.onErrorContainer,
    bg: scheme.errorContainer,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'surface/onSurface',
    fg: scheme.onSurface,
    bg: scheme.surface,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'inverseSurface/onInverseSurface',
    fg: scheme.onInverseSurface,
    bg: scheme.inverseSurface,
    minRatio: 4.5,
  );

  // Secondary text still needs to be readable on base surfaces.
  _expectPair(
    name: 'surface/onSurfaceVariant',
    fg: scheme.onSurfaceVariant,
    bg: scheme.surface,
    minRatio: 4.5,
  );
}

void _expectSemanticRoles(SemanticColors semantic) {
  _expectPair(
    name: 'success/onSuccess',
    fg: semantic.onSuccess,
    bg: semantic.success,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'successContainer/onSuccessContainer',
    fg: semantic.onSuccessContainer,
    bg: semantic.successContainer,
    minRatio: 4.5,
  );

  _expectPair(
    name: 'info/onInfo',
    fg: semantic.onInfo,
    bg: semantic.info,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'infoContainer/onInfoContainer',
    fg: semantic.onInfoContainer,
    bg: semantic.infoContainer,
    minRatio: 4.5,
  );

  _expectPair(
    name: 'warning/onWarning',
    fg: semantic.onWarning,
    bg: semantic.warning,
    minRatio: 4.5,
  );
  _expectPair(
    name: 'warningContainer/onWarningContainer',
    fg: semantic.onWarningContainer,
    bg: semantic.warningContainer,
    minRatio: 4.5,
  );
}

void _expectPair({
  required String name,
  required Color fg,
  required Color bg,
  required double minRatio,
}) {
  final ratio = wcagContrastRatio(fg, bg);
  expect(
    ratio,
    greaterThanOrEqualTo(minRatio),
    reason: '$name contrast was ${ratio.toStringAsFixed(2)} (min $minRatio)',
  );
}

