import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../styles/accessible_text_style.dart';
import '../tokens/type_metrics.dart';

TextStyle _textThemeBodyLarge(BuildContext context) =>
    Theme.of(context).textTheme.bodyLarge ?? const TextStyle();

TextStyle _textThemeBodyMedium(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

TextStyle _textThemeBodySmall(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall ?? const TextStyle();

/// A component optimized for multi-line body text with proper paragraph formatting.
///
/// This component handles proper line length, paragraph spacing, and other
/// typographic refinements needed for comfortable reading of longer text blocks.
class Paragraph extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final TextStyle Function(BuildContext) getStyle;
  final Color? color;
  final TextStyle? style;
  final bool selectable;
  final bool applyAccessibility;
  final bool constrainWidth;
  final double? paragraphSpacing;

  // Layout and Spacing
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  // Typography Enhancement
  final double? letterSpacing;
  final double? wordSpacing;
  final double? lineHeight;
  final TextScaler? textScaler;
  final Locale? locale;
  final StrutStyle? strutStyle;

  // Text Decoration
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final List<Shadow>? shadows;

  // Interaction
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final MouseCursor? mouseCursor;

  // Advanced Text Rendering
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final ui.TextDirection? textDirection;

  // Accessibility and Semantics
  final String? semanticsLabel;
  final bool excludeFromSemantics;
  final String? tooltip;

  // Selection and Interaction
  final TextSelectionControls? selectionControls;
  final bool enableInteractiveSelection;
  final void Function(TextSelection, SelectionChangedCause?)?
  onSelectionChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showCursor;
  final Color? cursorColor;
  final double? cursorWidth;
  final Radius? cursorRadius;

  /// Creates a paragraph with large body text.
  const Paragraph.large(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
    this.constrainWidth = true,
    this.paragraphSpacing,
    // Layout and Spacing
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    // Typography Enhancement
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.textScaler,
    this.locale,
    this.strutStyle,
    // Text Decoration
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
    // Interaction
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    // Advanced Text Rendering
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textDirection,
    // Accessibility and Semantics
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.tooltip,
    // Selection and Interaction
    this.selectionControls,
    this.enableInteractiveSelection = true,
    this.onSelectionChanged,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodyLarge;

  /// Creates a paragraph with medium (default) body text.
  const Paragraph(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
    this.constrainWidth = true,
    this.paragraphSpacing,
    // Layout and Spacing
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    // Typography Enhancement
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.textScaler,
    this.locale,
    this.strutStyle,
    // Text Decoration
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
    // Interaction
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    // Advanced Text Rendering
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textDirection,
    // Accessibility and Semantics
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.tooltip,
    // Selection and Interaction
    this.selectionControls,
    this.enableInteractiveSelection = true,
    this.onSelectionChanged,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodyMedium;

  /// Creates a paragraph with small body text.
  const Paragraph.small(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
    this.constrainWidth = true,
    this.paragraphSpacing,
    // Layout and Spacing
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    // Typography Enhancement
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.textScaler,
    this.locale,
    this.strutStyle,
    // Text Decoration
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
    // Interaction
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    // Advanced Text Rendering
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textDirection,
    // Accessibility and Semantics
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.tooltip,
    // Selection and Interaction
    this.selectionControls,
    this.enableInteractiveSelection = true,
    this.onSelectionChanged,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodySmall;

  /// Creates a paragraph with custom text style.
  const Paragraph.custom(
    this.text, {
    required this.getStyle,
    super.key,
    this.textAlign = TextAlign.start,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
    this.constrainWidth = true,
    this.paragraphSpacing,
    // Layout and Spacing
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    // Typography Enhancement
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.textScaler,
    this.locale,
    this.strutStyle,
    // Text Decoration
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
    // Interaction
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    // Advanced Text Rendering
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textDirection,
    // Accessibility and Semantics
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.tooltip,
    // Selection and Interaction
    this.selectionControls,
    this.enableInteractiveSelection = true,
    this.onSelectionChanged,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Get the responsive base style
    TextStyle baseStyle = getStyle(context);

    // Apply accessibility adjustments if requested
    if (applyAccessibility) {
      baseStyle = AccessibleTextStyles.applyAccessibility(context, baseStyle);
    }

    // Apply custom style overrides if provided
    if (style != null) {
      baseStyle = baseStyle.merge(style);
    }

    // Apply additional typography enhancements
    baseStyle = baseStyle.copyWith(
      color: color ?? baseStyle.color,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      wordSpacing: wordSpacing ?? baseStyle.wordSpacing,
      height: lineHeight ?? baseStyle.height,
      decoration: decoration ?? baseStyle.decoration,
      decorationColor: decorationColor ?? baseStyle.decorationColor,
      decorationStyle: decorationStyle ?? baseStyle.decorationStyle,
      decorationThickness: decorationThickness ?? baseStyle.decorationThickness,
      shadows: shadows ?? baseStyle.shadows,
    );

    // Build the paragraph text widget
    Widget textWidget;
    if (selectable) {
      textWidget = SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: maxLines,
        strutStyle: strutStyle,
        showCursor: showCursor,
        autofocus: autofocus,
        focusNode: focusNode,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        onSelectionChanged: onSelectionChanged,
        cursorColor: cursorColor,
        cursorWidth: cursorWidth ?? 2.0,
        cursorRadius: cursorRadius,
        onTap: onTap,
        semanticsLabel: semanticsLabel,
      );
    } else {
      textWidget = Text(
        text,
        style: baseStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        strutStyle: strutStyle,
      );
    }

    // Wrap with gesture detection if interaction callbacks are provided
    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      textWidget = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: textWidget,
      );
    }

    // Wrap with mouse region for hover and cursor effects
    if (onHover != null || mouseCursor != null) {
      textWidget = MouseRegion(
        onEnter: onHover != null ? (_) => onHover!(true) : null,
        onExit: onHover != null ? (_) => onHover!(false) : null,
        cursor: mouseCursor ?? MouseCursor.defer,
        child: textWidget,
      );
    }

    // Wrap with focus for focus change detection
    if (onFocusChange != null) {
      textWidget = Focus(onFocusChange: onFocusChange, child: textWidget);
    }

    // Apply tooltip if provided
    if (tooltip != null) {
      textWidget = Tooltip(message: tooltip!, child: textWidget);
    }

    // Apply semantics exclusion if requested
    if (excludeFromSemantics) {
      textWidget = ExcludeSemantics(child: textWidget);
    }

    // Apply paragraph spacing if specified
    if (paragraphSpacing != null) {
      textWidget = Padding(
        padding: EdgeInsets.only(bottom: paragraphSpacing!),
        child: textWidget,
      );
    }

    // Apply padding if specified
    if (padding != null) {
      textWidget = Padding(padding: padding!, child: textWidget);
    }

    // Apply margin if specified
    if (margin != null) {
      textWidget = Container(margin: margin, child: textWidget);
    }

    // Apply width, height, and alignment constraints
    if (width != null || height != null || alignment != null) {
      textWidget = Container(
        width: width,
        height: height,
        alignment: alignment,
        child: textWidget,
      );
    }

    // If width constraining is requested, wrap in a container with ideal width
    if (constrainWidth) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final idealWidth = _calculateIdealWidth(
            constraints: constraints,
            media: MediaQuery.of(context),
            fontSize: baseStyle.fontSize ?? 14.0,
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: idealWidth),
              child: textWidget,
            ),
          );
        },
      );
    }

    return textWidget;
  }

  /// Calculates the ideal width for a paragraph based on font size
  /// and character count guidelines for optimal readability
  double _calculateIdealWidth({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required double fontSize,
  }) {
    final availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : media.size.width;

    final safeAvailableWidth = availableWidth.isFinite && availableWidth > 0
        ? availableWidth
        : 0.0;

    final idealCharWidth = TypeMetrics.getIdealTextContainerWidth(fontSize);
    return idealCharWidth < safeAvailableWidth
        ? idealCharWidth
        : safeAvailableWidth;
  }
}
