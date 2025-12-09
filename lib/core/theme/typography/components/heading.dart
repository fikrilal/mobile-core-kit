import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../styles/accessible_text_style.dart';
import '../styles/responsive_text_styles.dart';

/// A semantic heading component that follows proper heading hierarchy.
///
/// This component creates semantically correct headings (h1, h2, h3, etc.)
/// with appropriate styling, providing both visual hierarchy and proper
/// semantics for accessibility.
class Heading extends StatelessWidget {
  final String text;
  final int level;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final TextOverflow overflow;
  final TextStyle? style;
  final bool applyAccessibility;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final String? fontFamily;
  final List<Shadow>? shadows;
  final Paint? foreground;
  final Paint? background;
  final Locale? locale;
  final bool softWrap;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final VoidCallback? onTap;
  final GestureRecognizer? recognizer;
  final String? semanticsLabel;
  final bool excludeFromSemantics;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final bool selectable;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final DragStartBehavior dragStartBehavior;
  final ScrollPhysics? scrollPhysics;
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Creates a heading of the specified level (1-6).
  ///
  /// Level 1 is the most prominent heading, level 6 is the least prominent.
  /// This matches HTML heading hierarchy (h1-h6).
  const Heading(
    this.text, {
    required this.level,
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : assert(
         level >= 1 && level <= 6,
         'Heading level must be between 1 and 6',
       );

  /// Creates a level 1 heading (most prominent).
  const Heading.h1(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 1;

  /// Creates a level 2 heading.
  const Heading.h2(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 2;

  /// Creates a level 3 heading.
  const Heading.h3(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 3;

  /// Creates a level 4 heading.
  const Heading.h4(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 4;

  /// Creates a level 5 heading.
  const Heading.h5(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 5;

  /// Creates a level 6 heading (least prominent).
  const Heading.h6(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.applyAccessibility = true,
    this.padding,
    this.margin,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontWeight,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.fontFamily,
    this.shadows,
    this.foreground,
    this.background,
    this.locale,
    this.softWrap = true,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.onTap,
    this.recognizer,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.textDirection,
    this.textScaler,
    this.selectable = false,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrollPhysics,
    this.magnifierConfiguration,
    super.key,
  }) : level = 6;

  @override
  Widget build(BuildContext context) {
    // Get base style
    TextStyle baseStyle = _getStyleForLevel()(context);

    // Apply accessibility adjustments
    if (applyAccessibility) {
      baseStyle = AccessibleTextStyles.applyAccessibility(context, baseStyle);
    }

    // Apply individual style properties
    baseStyle = baseStyle.copyWith(
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      shadows: shadows,
      foreground: foreground,
      background: background,
      locale: locale,
    );

    // Merge with custom style if provided
    if (style != null) {
      baseStyle = baseStyle.merge(style);
    }

    Widget textWidget;

    if (selectable) {
      textWidget = SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        textDirection: textDirection,
        textScaler: textScaler,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        dragStartBehavior: dragStartBehavior,
        scrollPhysics: scrollPhysics,
        magnifierConfiguration: magnifierConfiguration,
      );
    } else {
      textWidget = Text(
        text,
        style: baseStyle,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
        textDirection: textDirection,
        textScaler: textScaler,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        locale: locale,
      );
    }

    // Add tap functionality if needed
    if (onTap != null && !selectable) {
      textWidget = GestureDetector(onTap: onTap, child: textWidget);
    }

    // Apply padding and margin
    if (padding != null) {
      textWidget = Padding(padding: padding!, child: textWidget);
    }

    if (margin != null) {
      textWidget = Container(margin: margin, child: textWidget);
    }

    // Apply semantics
    return Semantics(
      header: true,
      label: semanticsLabel ?? 'Heading level $level, $text',
      excludeSemantics: excludeFromSemantics,
      child: textWidget,
    );
  }

  /// Maps heading levels to the appropriate text styles
  TextStyle Function(BuildContext) _getStyleForLevel() {
    switch (level) {
      case 1:
        return ResponsiveTextStyles.displayLarge;
      case 2:
        return ResponsiveTextStyles.displayMedium;
      case 3:
        return ResponsiveTextStyles.displaySmall;
      case 4:
        return ResponsiveTextStyles.headlineLarge;
      case 5:
        return ResponsiveTextStyles.headlineMedium;
      case 6:
        return ResponsiveTextStyles.headlineSmall;
      default:
        return ResponsiveTextStyles.displayLarge;
    }
  }
}
