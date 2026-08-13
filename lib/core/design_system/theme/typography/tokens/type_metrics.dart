/// Defines typography metrics for fine-tuning text appearance.
///
/// These metrics provide consistent text rendering across different
/// text styles and sizes, ensuring proper readability and aesthetics.
/// Each category (display, headline, etc.) has its own set of metrics
/// for consistent typography hierarchy.
class TypeMetrics {
  // Private constructor to prevent instantiation
  TypeMetrics._();

  // Line height multipliers
  static const double displayLineHeight = 1.2; // Tighter for large text
  static const double headlineLineHeight = 1.3;
  static const double titleLineHeight = 1.4;
  static const double bodyLineHeight = 1.5; // More spacing for readability
  static const double labelLineHeight = 1.4;

  // Letter spacing (in pixels)
  static const double displayLetterSpacing = -0.5; // Tighter for large text
  static const double headlineLetterSpacing = -0.25;
  static const double titleLetterSpacing = 0;
  static const double bodyLetterSpacing =
      0.25; // Slightly more spaced for readability
  static const double labelLetterSpacing = 0.1;

  // Ideal characters per line (for readability)
  static const int minCharactersPerLine = 40;
  static const int maxCharactersPerLine = 75;

  // Approximate average character width in relation to font size
  // Used for calculating ideal text container widths
  static const double averageCharWidthFactor = 0.55; // Rough estimate

  // Calculate ideal max width for a text container based on font size
  static double getIdealTextContainerWidth(double fontSize) {
    return fontSize * averageCharWidthFactor * maxCharactersPerLine;
  }
}
