enum WindowWidthClass { compact, medium, expanded, large, extraLarge }

enum WindowHeightClass { compact, medium, expanded }

class AdaptiveBreakpoints {
  AdaptiveBreakpoints._();

  static const double widthCompactMax = 600;
  static const double widthMediumMax = 840;
  static const double widthExpandedMax = 1200;
  static const double widthLargeMax = 1600;

  static const double heightCompactMax = 480;
  static const double heightMediumMax = 900;
}

WindowWidthClass widthClassFor(double width) {
  if (width < AdaptiveBreakpoints.widthCompactMax) {
    return WindowWidthClass.compact;
  }
  if (width < AdaptiveBreakpoints.widthMediumMax) {
    return WindowWidthClass.medium;
  }
  if (width < AdaptiveBreakpoints.widthExpandedMax) {
    return WindowWidthClass.expanded;
  }
  if (width < AdaptiveBreakpoints.widthLargeMax) {
    return WindowWidthClass.large;
  }
  return WindowWidthClass.extraLarge;
}

WindowHeightClass heightClassFor(double height) {
  if (height < AdaptiveBreakpoints.heightCompactMax) {
    return WindowHeightClass.compact;
  }
  if (height < AdaptiveBreakpoints.heightMediumMax) {
    return WindowHeightClass.medium;
  }
  return WindowHeightClass.expanded;
}
