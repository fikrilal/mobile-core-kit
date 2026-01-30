/// Size class thresholds and helpers for the adaptive system.
///
/// Feature code should branch on [WindowWidthClass] / [WindowHeightClass]
/// (or derived tokens from `context.adaptiveLayout`) rather than raw widths.
enum WindowWidthClass { compact, medium, expanded, large, extraLarge }

/// Coarse height buckets used for "short screen" adaptations.
enum WindowHeightClass { compact, medium, expanded }

/// Centralized breakpoint thresholds (logical pixels / dp).
///
/// These values are intentionally stable: changes must be treated as API changes
/// and validated with unit + golden tests.
class AdaptiveBreakpoints {
  AdaptiveBreakpoints._();

  static const double widthCompactMax = 600;
  static const double widthMediumMax = 840;
  static const double widthExpandedMax = 1200;
  static const double widthLargeMax = 1600;

  static const double heightCompactMax = 480;
  static const double heightMediumMax = 900;
}

/// Maps a width (dp) to a [WindowWidthClass].
///
/// Boundary semantics:
/// - `< widthCompactMax` => `compact`
/// - `>= widthCompactMax && < widthMediumMax` => `medium`
/// - etc.
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

/// Maps a height (dp) to a [WindowHeightClass].
///
/// Used primarily for "short screen" adaptations (e.g., compact height).
WindowHeightClass heightClassFor(double height) {
  if (height < AdaptiveBreakpoints.heightCompactMax) {
    return WindowHeightClass.compact;
  }
  if (height < AdaptiveBreakpoints.heightMediumMax) {
    return WindowHeightClass.medium;
  }
  return WindowHeightClass.expanded;
}
