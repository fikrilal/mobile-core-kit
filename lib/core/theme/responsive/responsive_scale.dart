import 'breakpoints.dart';

class ResponsiveScale {
  ResponsiveScale._();

  // Base scaling factors (consistent across all components)
  static const double mobileScale = 1.0; // Base scale
  static const double tabletScale = 1.125; // 12.5% larger (more subtle than 1.1)
  static const double desktopScale = 1.25; // 25% larger (more subtle than 1.2)

  // Content width strategy: Fluid → Constrained → Fixed
  static const Map<Breakpoint, double> contentWidthPercentages = {
    Breakpoint.mobile: 0.92, // 92% of screen width
    Breakpoint.tablet: 0.85, // 85% of screen width
    Breakpoint.desktop: 0.80, // 80% of screen width (but will be clamped)
  };

  static const Map<Breakpoint, double> contentWidthMaxValues = {
    Breakpoint.mobile: double.infinity, // No max constraint
    Breakpoint.tablet: 720.0, // Max 720px on tablets
    Breakpoint.desktop: 1200.0, // Max 1200px on desktop
  };

  /// Get scaled value for any base value across breakpoints
  static double getScaledValue(double baseValue, Breakpoint breakpoint) {
    switch (breakpoint) {
      case Breakpoint.mobile:
        return baseValue * mobileScale;
      case Breakpoint.tablet:
        return baseValue * tabletScale;
      case Breakpoint.desktop:
        return baseValue * desktopScale;
    }
  }

  /// Get content width using unified strategy
  static double getContentWidth(double screenWidth, Breakpoint breakpoint) {
    final percentage = contentWidthPercentages[breakpoint] ?? 0.92;
    final maxWidth = contentWidthMaxValues[breakpoint] ?? double.infinity;

    return (screenWidth * percentage).clamp(0, maxWidth);
  }
}
