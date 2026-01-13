import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'responsive_scale.dart';

/// Extension methods on BuildContext for responsive design
///
/// Provides convenient access to screen metrics and device information
/// to make responsive design decisions simpler throughout the app.
extension ScreenUtils on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  // Safe areas
  double get safeTopPadding => MediaQuery.of(this).padding.top;

  double get safeBottomPadding => MediaQuery.of(this).padding.bottom;

  // Device type checks
  bool get isMobile => screenWidth < Breakpoints.sm;

  bool get isTablet =>
      screenWidth >= Breakpoints.sm && screenWidth < Breakpoints.lg;

  bool get isDesktop => screenWidth >= Breakpoints.lg;

  // Get current breakpoint (strongly typed) and name
  Breakpoint get breakpoint => Breakpoints.getBreakpoint(screenWidth);

  String get breakpointName => Breakpoints.getBreakpointName(screenWidth);

  // Orientation checks
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  // Text scale factor (accessibility)
  double get textScaleFactor => MediaQuery.of(this).textScaler.scale(1.0);

  // Check if user prefers larger text (accessibility)
  bool get preferLargeText => textScaleFactor > 1.2;

  // Get ideal content width based on current screen size
  double get contentMaxWidth => Breakpoints.getMaxContentWidth(screenWidth);

  // Screen size percentages (0.0 - 1.0)
  double percentWidth(double factor) => screenWidth * factor;

  double percentHeight(double factor) => screenHeight * factor;

  // Get number of grid columns for current screen size
  int get gridColumns => Breakpoints.getGridColumns(screenWidth);

  // Calculate the width of a grid cell (including gutters)
  double gridCellWidth({double gutter = 16.0}) {
    final totalGutterWidth = gutter * (gridColumns - 1);
    return (screenWidth - totalGutterWidth) / gridColumns;
  }

  // Note: Standardize on AppSpacing.screenPadding(context) for layout padding.

  double getScaledValue(double baseValue) {
    return ResponsiveScale.getScaledValue(baseValue, breakpoint);
  }
}
