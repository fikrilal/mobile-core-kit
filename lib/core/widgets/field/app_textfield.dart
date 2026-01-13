import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/app_haptic_feedback.dart';
import 'field_styles.dart';
import 'field_variants.dart';

class AppTextField extends StatefulWidget {
  // Core
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  final FieldVariant variant;
  final FieldSize size;
  final FieldType fieldType;

  /// Optional visual override to show success/warning states.
  final FieldState? visualState;

  final bool enabled;
  final bool readOnly;

  // Text / labels
  final String? labelText;
  final LabelPosition labelPosition;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool expands;

  final TextAlign textAlign;
  final TextCapitalization textCapitalization;

  // Input formatting & validation
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool enableInteractiveSelection;
  final Iterable<String>? autofillHints;

  // Prefix & Suffix
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final Widget? prefix;
  final Widget? suffix;

  // Visual overrides
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? cursorColor;
  final EdgeInsets? contentPadding;

  // Accessibility
  final String? semanticLabel;
  final String? tooltip;
  final bool excludeFromSemantics;
  final String? restorationId;

  // Focus & interaction
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  final bool enableFeedback;
  final AppHapticFeedback? hapticFeedback;

  const AppTextField({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.fieldType = FieldType.text,
    this.visualState,
    this.enabled = true,
    this.readOnly = false,
    // Text / labels
    this.labelText,
    this.labelPosition = LabelPosition.above,
    this.hintText,
    this.helperText,
    this.errorText,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.expands = false,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    // Input formatting & validation
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autovalidateMode,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enableInteractiveSelection = true,
    this.autofillHints,
    // Prefix & Suffix
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    // Visual overrides
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.cursorColor,
    this.contentPadding,
    // Accessibility
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.restorationId,
    // Focus & interaction
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback = true,
    this.hapticFeedback,
  });

  const AppTextField.email({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.visualState,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.labelPosition = LabelPosition.above,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.cursorColor,
    this.contentPadding,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.restorationId,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback = true,
    this.hapticFeedback,
  }) : fieldType = FieldType.email,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       expands = false,
       textAlign = TextAlign.start,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       autocorrect = false,
       enableSuggestions = true,
       enableInteractiveSelection = true,
       autofillHints = const [AutofillHints.email];

  const AppTextField.password({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.visualState,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.labelPosition = LabelPosition.above,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    TextInputAction? textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.cursorColor,
    this.contentPadding,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.restorationId,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback = true,
    this.hapticFeedback,
  }) : fieldType = FieldType.password,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       expands = false,
       textAlign = TextAlign.start,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       keyboardType = TextInputType.visiblePassword,
       textInputAction = textInputAction ?? TextInputAction.done,
       autocorrect = false,
       enableSuggestions = false,
       enableInteractiveSelection = true,
       autofillHints = const [AutofillHints.password];

  const AppTextField.multiline({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.variant = FieldVariant.outline,
    this.size = FieldSize.medium,
    this.visualState,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.labelPosition = LabelPosition.above,
    this.hintText,
    this.helperText,
    this.errorText,
    this.maxLines = 3,
    this.minLines = 3,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.cursorColor,
    this.contentPadding,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.restorationId,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback = true,
    this.hapticFeedback,
  }) : fieldType = FieldType.multiline,
       expands = false,
       textAlign = TextAlign.start,
       textCapitalization = TextCapitalization.sentences,
       inputFormatters = null,
       keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       autocorrect = true,
       enableSuggestions = true,
       enableInteractiveSelection = true,
       autofillHints = null;

  const AppTextField.search({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.variant = FieldVariant.outline,
    this.labelPosition = LabelPosition.above,
    this.size = FieldSize.medium,
    this.visualState,
    this.enabled = true,
    this.readOnly = false,
    this.labelText,
    this.hintText = 'Search...',
    this.helperText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.prefixIcon = const Icon(Icons.search),
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.suffix,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.cursorColor,
    this.contentPadding,
    this.semanticLabel,
    this.tooltip,
    this.excludeFromSemantics = false,
    this.restorationId,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.enableFeedback = true,
    this.hapticFeedback,
  }) : fieldType = FieldType.search,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       expands = false,
       textAlign = TextAlign.start,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search,
       autocorrect = true,
       enableSuggestions = true,
       enableInteractiveSelection = true,
       autofillHints = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  FieldState _currentState = FieldState.enabled;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _obscureText = widget.fieldType == FieldType.password;
    _updateFieldState();
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller =
          widget.controller ?? TextEditingController(text: widget.initialValue);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }

    _updateFieldState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    widget.onFocusChange?.call(_focusNode.hasFocus);
    _updateFieldState();
  }

  void _updateFieldState() {
    final override = widget.visualState;
    FieldState next;

    if (override != null) {
      next = override;
    } else if (!widget.enabled) {
      next = FieldState.disabled;
    } else if (widget.errorText != null) {
      next = FieldState.error;
    } else {
      next = FieldState.enabled;
    }

    if (next != _currentState) {
      setState(() => _currentState = next);
    }
  }

  void _triggerHapticFeedback() {
    if (!widget.enableFeedback || widget.hapticFeedback == null) return;

    switch (widget.hapticFeedback!) {
      case AppHapticFeedback.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case AppHapticFeedback.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case AppHapticFeedback.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case AppHapticFeedback.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case AppHapticFeedback.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
    _triggerHapticFeedback();
  }

  Widget _buildPasswordToggle() {
    if (widget.fieldType != FieldType.password) return const SizedBox.shrink();

    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility : Icons.visibility_off,
        size: FieldStyles.getSizeConfig(widget.size).iconSize,
      ),
      onPressed: _toggleObscureText,
      tooltip: _obscureText ? 'Show password' : 'Hide password',
    );
  }

  Widget? _buildSuffixIcon() {
    final passwordToggle = _buildPasswordToggle();

    if (widget.suffixIcon != null && widget.fieldType == FieldType.password) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [widget.suffixIcon!, passwordToggle],
      );
    }

    if (widget.fieldType == FieldType.password) {
      return passwordToggle;
    }

    return widget.suffixIcon;
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;

    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.password:
        return TextInputType.visiblePassword;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.multiline:
        return TextInputType.multiline;
      case FieldType.search:
      case FieldType.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    switch (widget.fieldType) {
      case FieldType.number:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case FieldType.phone:
        formatters.add(
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\\-\\s()]')),
        );
        break;
      default:
        break;
    }

    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }

    return formatters;
  }

  @override
  Widget build(BuildContext context) {
    final decoration = FieldStyles.getInputDecoration(
      context: context,
      variant: widget.variant,
      size: widget.size,
      state: _currentState,
      labelText: widget.labelPosition == LabelPosition.floating
          ? widget.labelText
          : null,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      fillColor: widget.fillColor,
      borderColor: widget.borderColor,
    );

    final textStyle = FieldStyles.getTextStyle(
      context: context,
      size: widget.size,
      state: _currentState,
      textColor: widget.textColor,
    );

    Widget textField = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: decoration.copyWith(
        prefix: widget.prefix,
        suffix: widget.suffix,
        contentPadding: widget.contentPadding ?? decoration.contentPadding,
      ),
      style: textStyle,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      obscuringCharacter: '•',
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      readOnly: widget.readOnly,
      maxLength: widget.maxLength,
      inputFormatters: _getInputFormatters(),
      enabled: widget.enabled,
      cursorColor: widget.cursorColor,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      autofillHints: widget.autofillHints,
      restorationId: widget.restorationId,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      onTap: () {
        widget.onTap?.call();
        _triggerHapticFeedback();
      },
      onFieldSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );

    if (widget.tooltip != null) {
      textField = Tooltip(message: widget.tooltip!, child: textField);
    }

    if (widget.excludeFromSemantics) {
      textField = ExcludeSemantics(child: textField);
    } else {
      textField = Semantics(
        label: widget.semanticLabel ?? widget.labelText,
        textField: true,
        enabled: widget.enabled,
        child: textField,
      );
    }

    if (widget.labelPosition == LabelPosition.above &&
        widget.labelText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.labelText!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _currentState == FieldState.error
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          textField,
        ],
      );
    }

    return textField;
  }
}
