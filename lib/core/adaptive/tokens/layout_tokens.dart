import 'package:flutter/widgets.dart';

import '../adaptive_spec.dart';
import '../size_classes.dart';

class LayoutTokens {
  LayoutTokens._();

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

  static double gutter(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact => 12.0,
      WindowWidthClass.medium => 16.0,
      _ => 20.0,
    };
  }

  static double minTapTarget(InputMode mode) {
    return switch (mode) {
      InputMode.touch => 48.0,
      InputMode.pointer => 44.0,
      InputMode.mixed => 48.0,
    };
  }
}

