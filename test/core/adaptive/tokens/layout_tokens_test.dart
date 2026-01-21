import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/layout_tokens.dart';

void main() {
  group('LayoutTokens.pagePadding', () {
    test('maps width classes to horizontal padding', () {
      expect(
        LayoutTokens.pagePadding(WindowWidthClass.compact),
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(
        LayoutTokens.pagePadding(WindowWidthClass.medium),
        const EdgeInsets.symmetric(horizontal: 24),
      );
      expect(
        LayoutTokens.pagePadding(WindowWidthClass.expanded),
        const EdgeInsets.symmetric(horizontal: 32),
      );
      expect(
        LayoutTokens.pagePadding(WindowWidthClass.large),
        const EdgeInsets.symmetric(horizontal: 40),
      );
      expect(
        LayoutTokens.pagePadding(WindowWidthClass.extraLarge),
        const EdgeInsets.symmetric(horizontal: 48),
      );
    });
  });

  group('LayoutTokens.gutter', () {
    test('maps width classes to gutter sizes', () {
      expect(LayoutTokens.gutter(WindowWidthClass.compact), 12);
      expect(LayoutTokens.gutter(WindowWidthClass.medium), 16);
      expect(LayoutTokens.gutter(WindowWidthClass.expanded), 20);
      expect(LayoutTokens.gutter(WindowWidthClass.large), 20);
      expect(LayoutTokens.gutter(WindowWidthClass.extraLarge), 20);
    });
  });

  group('LayoutTokens.minTapTarget', () {
    test('maps input mode to min tap target', () {
      expect(LayoutTokens.minTapTarget(InputMode.touch), 48);
      expect(LayoutTokens.minTapTarget(InputMode.pointer), 44);
      expect(LayoutTokens.minTapTarget(InputMode.mixed), 48);
    });
  });
}
