import 'package:flutter/material.dart';
import 'responsive_scale.dart';

/// Defines standard breakpoints for responsive design.
///
/// These breakpoints are used throughout the app to make responsive
/// design decisions, including typography changes, layout adjustments,
/// and component variations.
enum Breakpoint { mobile, tablet, desktop }

class Breakpoints {
  // Private constructor to prevent instantiation
  Breakpoints._();

  // Standard breakpoints
  static const double xs = 0; // Extra small (small phones)
  static const double sm = 600; // Small (large phones, small tablets)
  static const double md = 900; // Medium (tablets, small desktops)
  static const double lg = 1200; // Large (desktops)
  static const double xl = 1536; // Extra large (large desktops)

  // Get breakpoint name based on width
  static String getBreakpointName(double width) {
    return switch (getBreakpoint(width)) {
      Breakpoint.mobile => 'mobile',
      Breakpoint.tablet => 'tablet',
      Breakpoint.desktop => 'desktop',
    };
  }

  // Strongly-typed breakpoint by width
  static Breakpoint getBreakpoint(double width) {
    if (width < sm) {
      return Breakpoint.mobile;
    } else if (width < lg) {
      return Breakpoint.tablet;
    } else {
      return Breakpoint.desktop;
    }
  }

  // Content max width based on breakpoint
  static double getMaxContentWidth(double screenWidth) {
    final bp = getBreakpoint(screenWidth);
    return ResponsiveScale.getContentWidth(screenWidth, bp);
  }

  // Grid column counts at different breakpoints
  static int getGridColumns(double width) {
    if (width < sm) {
      return 2; // Mobile: 2 columns for better touch targets
    } else if (width < md) {
      return 3; // Small tablets: 3 columns
    } else if (width < lg) {
      return 4; // Large tablets: 4 columns
    } else {
      return 6; // Desktop: 6 columns for optimal content density
    }
  }

  // Context-aware helpers
  static double getMaxContentWidthFromContext(BuildContext context) {
    return getMaxContentWidth(MediaQuery.of(context).size.width);
  }

  static int getGridColumnsFromContext(BuildContext context) {
    return getGridColumns(MediaQuery.of(context).size.width);
  }
}
