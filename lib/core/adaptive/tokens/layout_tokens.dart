import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';

/// Layout token table derived from size classes and input mode.
///
/// These are page-level tokens (padding/gutter/min tap target) that change with
/// [WindowWidthClass] and/or [InputMode]. They are intentionally separate from
/// theme tokens (which are typically context-free).
class LayoutTokens {
  LayoutTokens._();

  /// Page-level horizontal padding for a given width class.
  static EdgeInsets pagePadding(WindowWidthClass widthClass) {
    final horizontal = switch (widthClass) {
      WindowWidthClass.compact => 16.0,
      WindowWidthClass.medium => 24.0,
      WindowWidthClass.expanded => 32.0,
      WindowWidthClass.large => 40.0,
      WindowWidthClass.extraLarge => 48.0,
    };
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  /// Standard gutter between major page elements (cards/tiles).
  static double gutter(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 12.0,
      WindowWidthClass.medium => 16.0,
      _ => 20.0,
    };
  }

  /// Minimum interactive size for the current [InputMode].
  static double minTapTarget(InputMode mode) {
    return switch (mode) {
      InputMode.touch => 48.0,
      InputMode.pointer => 44.0,
      InputMode.mixed => 48.0,
    };
  }
}
