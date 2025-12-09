import 'package:flutter/material.dart';

/// Utilities for calculating line heights and typographic metrics.
///
/// This class provides methods to convert between different typographic
/// measurements, ensuring precise text layouts and consistent vertical rhythm.
class LineHeightCalculator {
  // Private constructor to prevent instantiation
  LineHeightCalculator._();

  /// Converts a line height multiplier to exact pixel height
  ///
  /// Line height in typography is typically specified as a multiplier of the
  /// font size. This method calculates the exact pixel height for a given
  /// font size and line height multiplier.
  static double calculateExactHeight(
    double fontSize,
    double lineHeightMultiplier,
  ) {
    return fontSize * lineHeightMultiplier;
  }

  /// Calculates the vertical space needed between two text elements
  /// to maintain a consistent vertical rhythm
  ///
  /// This is useful for creating consistent spacing between different
  /// typography elements (like headings and paragraphs).
  static double calculateVerticalSpace({
    required TextStyle topStyle,
    required TextStyle bottomStyle,
    double desiredSpacing = 8.0,
  }) {
    // Get the line heights
    final topLineHeight = topStyle.height ?? 1.2;
    final bottomLineHeight = bottomStyle.height ?? 1.2;

    // Calculate the actual space
    final topTextBottomSpace = topStyle.fontSize! * topLineHeight / 2;
    final bottomTextTopSpace = bottomStyle.fontSize! * bottomLineHeight / 2;

    // Calculate the needed additional space
    return desiredSpacing - (topTextBottomSpace + bottomTextTopSpace);
  }

  /// Calculates padding needed for a text container to align with baseline grid
  ///
  /// When working with a typographic baseline grid (for vertical rhythm),
  /// text elements need specific padding to align properly.
  static EdgeInsets calculateBaselinePadding({
    required TextStyle style,
    required double gridSize,
  }) {
    final fontSize = style.fontSize!;
    final lineHeight = style.height ?? 1.2;
    final totalHeight = fontSize * lineHeight;

    // Calculate the offset from the grid
    final gridOffset = totalHeight % gridSize;

    // Calculate padding to align to grid
    final topPadding = gridOffset / 2;
    final bottomPadding = gridOffset / 2;

    return EdgeInsets.only(top: topPadding, bottom: bottomPadding);
  }

  /// Calculates line count based on available height and text style
  ///
  /// This is useful for determining how many lines of text can fit
  /// in a container of fixed height.
  static int calculateLineCount({
    required double availableHeight,
    required TextStyle style,
  }) {
    final fontSize = style.fontSize!;
    final lineHeight = style.height ?? 1.2;
    final lineHeightPx = fontSize * lineHeight;

    return (availableHeight / lineHeightPx).floor();
  }

  /// Calculates the appropriate font size to ensure text fits within constraints
  ///
  /// This is useful for responsive typography where text needs to fit
  /// within a specific width without overflowing.
  static double calculateFittingFontSize({
    required String text,
    required double maxWidth,
    required TextStyle style,
    required BuildContext context,
  }) {
    // Start with current font size
    double fontSize = style.fontSize!;

    // Create text painter to measure text width
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    // Measure text width with current font size
    textPainter.layout();
    double textWidth = textPainter.width;

    // If text is too wide, decrease font size until it fits
    if (textWidth > maxWidth) {
      while (textWidth > maxWidth && fontSize > 8.0) {
        // 8.0 is minimum readable size
        fontSize -= 0.5;
        textPainter.text = TextSpan(
          text: text,
          style: style.copyWith(fontSize: fontSize),
        );
        textPainter.layout();
        textWidth = textPainter.width;
      }
    }

    return fontSize;
  }
}
