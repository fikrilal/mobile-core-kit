import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../styles/accessible_text_style.dart';

TextStyle _textThemeDisplayLarge(BuildContext context) =>
    Theme.of(context).textTheme.displayLarge ?? const TextStyle();

TextStyle _textThemeDisplayMedium(BuildContext context) =>
    Theme.of(context).textTheme.displayMedium ?? const TextStyle();

TextStyle _textThemeDisplaySmall(BuildContext context) =>
    Theme.of(context).textTheme.displaySmall ?? const TextStyle();

TextStyle _textThemeHeadlineLarge(BuildContext context) =>
    Theme.of(context).textTheme.headlineLarge ?? const TextStyle();

TextStyle _textThemeHeadlineMedium(BuildContext context) =>
    Theme.of(context).textTheme.headlineMedium ?? const TextStyle();

TextStyle _textThemeHeadlineSmall(BuildContext context) =>
    Theme.of(context).textTheme.headlineSmall ?? const TextStyle();

TextStyle _textThemeTitleLarge(BuildContext context) =>
    Theme.of(context).textTheme.titleLarge ?? const TextStyle();

TextStyle _textThemeTitleMedium(BuildContext context) =>
    Theme.of(context).textTheme.titleMedium ?? const TextStyle();

TextStyle _textThemeTitleSmall(BuildContext context) =>
    Theme.of(context).textTheme.titleSmall ?? const TextStyle();

TextStyle _textThemeBodyLarge(BuildContext context) =>
    Theme.of(context).textTheme.bodyLarge ?? const TextStyle();

TextStyle _textThemeBodyMedium(BuildContext context) =>
    Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

TextStyle _textThemeBodySmall(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall ?? const TextStyle();

TextStyle _textThemeLabelLarge(BuildContext context) =>
    Theme.of(context).textTheme.labelLarge ?? const TextStyle();

TextStyle _textThemeLabelMedium(BuildContext context) =>
    Theme.of(context).textTheme.labelMedium ?? const TextStyle();

TextStyle _textThemeLabelSmall(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall ?? const TextStyle();

/// A reusable text component that provides responsive and accessible typography.
///
/// This component encapsulates typography best practices and ensures consistent
/// text appearance throughout the app, with built-in support for responsiveness
/// and accessibility.
class AppText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final TextStyle? style;
  final Color? color;
  final bool selectable;
  final TextStyle Function(BuildContext)? getStyle;
  final bool applyAccessibility;

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
  final bool? softWrap;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final ui.TextDirection? textDirection;

  // Accessibility and Semantics
  final String? semanticsLabel;
  final bool excludeFromSemantics;
  final String? tooltip;

  // Selection and Interaction (for selectable text)
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

  /// Constructor for display large text
  const AppText.displayLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeDisplayLarge;

  /// Constructor for display medium text
  const AppText.displayMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeDisplayMedium;

  /// Constructor for display small text
  const AppText.displaySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeDisplaySmall;

  /// Constructor for headline large text
  const AppText.headlineLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeHeadlineLarge;

  /// Constructor for headline medium text
  const AppText.headlineMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeHeadlineMedium;

  /// Constructor for headline small text
  const AppText.headlineSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeHeadlineSmall;

  /// Constructor for title large text
  const AppText.titleLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeTitleLarge;

  /// Constructor for title medium text
  const AppText.titleMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeTitleMedium;

  /// Constructor for title small text
  const AppText.titleSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeTitleSmall;

  /// Constructor for body large text
  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodyLarge;

  /// Constructor for body medium text
  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodyMedium;

  /// Constructor for body small text
  const AppText.bodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeBodySmall;

  /// Constructor for label large text
  const AppText.labelLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeLabelLarge;

  /// Constructor for label medium text
  const AppText.labelMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeLabelMedium;

  /// Constructor for label small text
  const AppText.labelSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  }) : getStyle = _textThemeLabelSmall;

  /// Custom constructor for any text style
  const AppText.custom(
    this.text, {
    required this.getStyle,
    super.key,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.color,
    this.style,
    this.selectable = false,
    this.applyAccessibility = true,
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
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth,
    this.cursorRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Get the responsive base style
    TextStyle baseStyle = getStyle!(context);

    // Apply accessibility adjustments if requested
    if (applyAccessibility) {
      baseStyle = AccessibleTextStyles.applyAccessibility(context, baseStyle);
    }

    // Apply custom style overrides if provided
    if (style != null) {
      baseStyle = baseStyle.merge(style);
    }

    // Apply color override if provided
    if (color != null) {
      baseStyle = baseStyle.copyWith(color: color);
    }

    // Apply typography enhancements
    if (letterSpacing != null ||
        wordSpacing != null ||
        decoration != null ||
        decorationColor != null ||
        decorationStyle != null ||
        decorationThickness != null ||
        shadows != null) {
      baseStyle = baseStyle.copyWith(
        letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
        wordSpacing: wordSpacing ?? baseStyle.wordSpacing,
        decoration: decoration ?? baseStyle.decoration,
        decorationColor: decorationColor ?? baseStyle.decorationColor,
        decorationStyle: decorationStyle ?? baseStyle.decorationStyle,
        decorationThickness:
            decorationThickness ?? baseStyle.decorationThickness,
        shadows: shadows ?? baseStyle.shadows,
      );
    }

    // Apply line height if specified
    if (lineHeight != null) {
      baseStyle = baseStyle.copyWith(height: lineHeight);
    }

    Widget textWidget;

    // Use selectable text if requested, otherwise regular text
    if (selectable) {
      textWidget = SelectableText(
        text,
        style: baseStyle,
        textAlign: textAlign,
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
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        strutStyle: strutStyle,
        textDirection: textDirection,
        locale: locale,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
      );
    }

    // Wrap with gesture detector for interactions
    if (onTap != null || onLongPress != null || onDoubleTap != null) {
      textWidget = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        child: textWidget,
      );
    }

    // Wrap with mouse region for hover effects
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

    // Add tooltip if specified
    if (tooltip != null) {
      textWidget = Tooltip(message: tooltip!, child: textWidget);
    }

    // Handle semantics exclusion
    if (excludeFromSemantics) {
      textWidget = ExcludeSemantics(child: textWidget);
    }

    // Apply padding if specified
    if (padding != null) {
      textWidget = Padding(padding: padding!, child: textWidget);
    }

    // Apply margin if specified
    if (margin != null) {
      textWidget = Container(margin: margin, child: textWidget);
    }

    // Apply width, height, and alignment if specified
    if (width != null || height != null || alignment != null) {
      textWidget = Container(
        width: width,
        height: height,
        alignment: alignment,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
