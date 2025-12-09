import '../../responsive/responsive_scale.dart';
import '../../responsive/breakpoints.dart';

class TypeScale {
  TypeScale._();

  // Display styles (largest, used for hero headers)
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;

  // Headline styles (section headers)
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;

  // Title styles (subsection headers and emphasized text)
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;

  // Body text styles (paragraph text)
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // Label styles (buttons, captions, etc.)
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  static double getResponsiveSize(double baseSize, Object breakpoint) {
    Breakpoint bp;
    if (breakpoint is Breakpoint) {
      bp = breakpoint;
    } else if (breakpoint is String) {
      switch (breakpoint) {
        case 'mobile':
          bp = Breakpoint.mobile;
          break;
        case 'tablet':
          bp = Breakpoint.tablet;
          break;
        case 'desktop':
        default:
          bp = Breakpoint.desktop;
      }
    } else {
      bp = Breakpoint.mobile;
    }
    return ResponsiveScale.getScaledValue(baseSize, bp);
  }
}
