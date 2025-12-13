import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/system/state_opacities.dart';
import '../common/app_haptic_feedback.dart';
import 'checkbox_variants.dart';

class AppCheckbox extends StatelessWidget {
  /// The current value of the checkbox
  /// - true: checked
  /// - false: unchecked
  /// - null: indeterminate (tristate)
  final bool? value;

  /// Called when the value of the checkbox should change
  final ValueChanged<bool?>? onChanged;

  /// The size of the checkbox
  final CheckboxSize size;

  /// The visual variant of the checkbox
  final CheckboxVariant variant;

  /// Whether the checkbox is enabled
  final bool enabled;

  /// Whether the checkbox supports tristate (indeterminate)
  final bool tristate;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Custom colors override
  final Color? activeColor;
  final Color? checkColor;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Internal padding around the checkbox (does not affect tap target)
  final EdgeInsetsGeometry? padding;

  /// Tooltip message
  final String? tooltip;

  /// Focus node for keyboard navigation
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  /// Opt-in haptic feedback on toggle.
  final bool enableFeedback;
  final AppHapticFeedback? hapticFeedback;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = CheckboxSize.medium,
    this.variant = CheckboxVariant.primary,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  });

  /// Small checkbox
  const AppCheckbox.small({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = CheckboxVariant.primary,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  }) : size = CheckboxSize.small;

  /// Medium checkbox (default)
  const AppCheckbox.medium({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = CheckboxVariant.primary,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  }) : size = CheckboxSize.medium;

  /// Large checkbox
  const AppCheckbox.large({
    super.key,
    required this.value,
    required this.onChanged,
    this.variant = CheckboxVariant.primary,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  }) : size = CheckboxSize.large;

  /// Primary variant checkbox
  const AppCheckbox.primary({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = CheckboxSize.medium,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  }) : variant = CheckboxVariant.primary;

  /// Secondary variant checkbox
  const AppCheckbox.secondary({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = CheckboxSize.medium,
    this.enabled = true,
    this.tristate = false,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.margin,
    this.padding,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = false,
    this.hapticFeedback,
  }) : variant = CheckboxVariant.secondary;

  void _triggerHaptic() {
    if (!enableFeedback || hapticFeedback == null) return;

    switch (hapticFeedback!) {
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

  @override
  Widget build(BuildContext context) {
    assert(
      tristate || value != null,
      'AppCheckbox: value cannot be null when tristate is false.',
    );

    final scheme = Theme.of(context).colorScheme;
    final isEnabled = enabled && onChanged != null;

    final active = activeColor ?? _activeColorForVariant(scheme);
    final check = checkColor ?? _checkColorForVariant(scheme);

    final scale = _scaleForSize(size);

    final side = BorderSide(
      width: 2,
      color: isEnabled
          ? scheme.outline
          : scheme.onSurface.withValues(alpha: StateOpacities.disabledContent),
    );

    final fillColor = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return scheme.onSurface.withValues(
          alpha: StateOpacities.disabledContainer,
        );
      }
      if (states.contains(WidgetState.selected)) return active;
      return Colors.transparent;
    });

    final overlayColor = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.focused)) {
        return active.withValues(alpha: StateOpacities.focus);
      }
      if (states.contains(WidgetState.hovered)) {
        return scheme.onSurface.withValues(alpha: StateOpacities.hover);
      }
      if (states.contains(WidgetState.pressed)) {
        return scheme.onSurface.withValues(alpha: StateOpacities.pressed);
      }
      return null;
    });

    final checkbox = Transform.scale(
      scale: scale,
      transformHitTests: false,
      child: Checkbox(
        value: value,
        tristate: tristate,
        onChanged: isEnabled
            ? (next) {
                _triggerHaptic();
                onChanged?.call(next);
              }
            : null,
        autofocus: autofocus,
        focusNode: focusNode,
        semanticLabel: semanticLabel,
        fillColor: fillColor,
        checkColor: check,
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: active, width: 2);
          }
          return side;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        overlayColor: overlayColor,
      ),
    );

    Widget result = checkbox;

    if (padding != null) {
      result = Padding(padding: padding!, child: result);
    }
    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }

    return result;
  }

  Color _activeColorForVariant(ColorScheme scheme) {
    switch (variant) {
      case CheckboxVariant.primary:
        return scheme.primary;
      case CheckboxVariant.secondary:
        return scheme.secondary;
    }
  }

  Color _checkColorForVariant(ColorScheme scheme) {
    switch (variant) {
      case CheckboxVariant.primary:
        return scheme.onPrimary;
      case CheckboxVariant.secondary:
        return scheme.onSecondary;
    }
  }

  double _scaleForSize(CheckboxSize size) {
    switch (size) {
      case CheckboxSize.small:
        return 0.9;
      case CheckboxSize.medium:
        return 1.0;
      case CheckboxSize.large:
        return 1.1;
    }
  }
}
