import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/grid_tokens.dart';

void main() {
  group('GridTokens.computeColumns', () {
    test('returns 1 when contentWidth is non-positive', () {
      expect(
        GridTokens.computeColumns(
          contentWidth: 0,
          gutter: 16,
          widthClass: WindowWidthClass.compact,
        ),
        1,
      );

      expect(
        GridTokens.computeColumns(
          contentWidth: -10,
          gutter: 16,
          widthClass: WindowWidthClass.compact,
        ),
        1,
      );
    });

    test('computes columns based on min tile width + gutter', () {
      // compact: minTileWidth=160, maxColumns=2
      expect(
        GridTokens.computeColumns(
          contentWidth: 160,
          gutter: 16,
          widthClass: WindowWidthClass.compact,
        ),
        1,
      );

      // For 2 columns:
      // raw = floor((contentWidth + gutter) / (minWidth + gutter))
      // => floor((336 + 16) / (160 + 16)) == 2
      expect(
        GridTokens.computeColumns(
          contentWidth: 336,
          gutter: 16,
          widthClass: WindowWidthClass.compact,
        ),
        2,
      );
    });

    test('clamps to maxColumns for the width class', () {
      // compact maxColumns is 2; provide huge width so raw > 2.
      expect(
        GridTokens.computeColumns(
          contentWidth: 2000,
          gutter: 16,
          widthClass: WindowWidthClass.compact,
        ),
        2,
      );

      // extraLarge maxColumns is 6.
      expect(
        GridTokens.computeColumns(
          contentWidth: 99999,
          gutter: 20,
          widthClass: WindowWidthClass.extraLarge,
        ),
        6,
      );
    });
  });
}
