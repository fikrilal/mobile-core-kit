import 'dart:math' as math;

import 'package:mobile_core_kit/core/design_system/adaptive/size_classes.dart';

/// Token table for computing safe grid columns.
///
/// Grid behavior is derived from content width and the chosen [WindowWidthClass].
class GridTokens {
  GridTokens._();

  /// Minimum tile width used for column computation.
  static double minTileWidth(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 160.0,
      WindowWidthClass.medium => 180.0,
      WindowWidthClass.expanded => 200.0,
      WindowWidthClass.large => 220.0,
      WindowWidthClass.extraLarge => 240.0,
    };
  }

  /// Hard cap on computed columns for a given width class.
  static int maxColumns(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 2,
      WindowWidthClass.medium => 3,
      WindowWidthClass.expanded => 4,
      WindowWidthClass.large => 5,
      WindowWidthClass.extraLarge => 6,
    };
  }

  /// Computes grid columns based on content width and gutter spacing.
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
