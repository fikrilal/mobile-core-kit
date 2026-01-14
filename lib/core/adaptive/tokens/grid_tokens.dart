import 'dart:math' as math;

import '../size_classes.dart';

class GridTokens {
  GridTokens._();

  static double minTileWidth(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 160.0,
      WindowWidthClass.medium => 180.0,
      WindowWidthClass.expanded => 200.0,
      WindowWidthClass.large => 220.0,
      WindowWidthClass.extraLarge => 240.0,
    };
  }

  static int maxColumns(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 2,
      WindowWidthClass.medium => 3,
      WindowWidthClass.expanded => 4,
      WindowWidthClass.large => 5,
      WindowWidthClass.extraLarge => 6,
    };
  }

  static int computeColumns({
    required double contentWidth,
    required double gutter,
    required WindowWidthClass widthClass,
  }) {
    final minWidth = minTileWidth(widthClass);
    final maxCols = maxColumns(widthClass);

    if (contentWidth <= 0) return 1;

    final raw = ((contentWidth + gutter) / (minWidth + gutter)).floor();
    return math.max(1, math.min(maxCols, raw));
  }
}
