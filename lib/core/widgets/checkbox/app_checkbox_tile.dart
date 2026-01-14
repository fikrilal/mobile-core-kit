import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens/spacing.dart';
import '../../theme/system/state_opacities.dart';
import '../../theme/typography/components/text.dart';
import '../common/app_haptic_feedback.dart';
import 'app_checkbox.dart';
import 'checkbox_variants.dart';

class AppCheckboxTile extends StatelessWidget {
  const AppCheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.helperText,
    this.size = CheckboxSize.medium,
    this.variant = CheckboxVariant.primary,
    this.enabled = true,
    this.tristate = false,
    this.enableFeedback = false,
    this.hapticFeedback,
    this.semanticLabel,
    this.padding,
    this.checkboxOnTrailing = false,
    this.focusNode,
    this.autofocus = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;

  final String label;
  final String? helperText;

  final CheckboxSize size;
  final CheckboxVariant variant;

  final bool enabled;
  final bool tristate;

  final bool enableFeedback;
  final AppHapticFeedback? hapticFeedback;

  final String? semanticLabel;

  final EdgeInsetsGeometry? padding;
  final bool checkboxOnTrailing;

  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    assert(
      tristate || value != null,
      'AppCheckboxTile: value cannot be null when tristate is false.',
    );

    final scheme = Theme.of(context).colorScheme;
    final isEnabled = enabled && onChanged != null;

    final effectivePadding =
        padding ??
        const EdgeInsets.symmetric(vertical: AppSpacing.space8, horizontal: 0);

    final labelColor = isEnabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: StateOpacities.disabledContent);
    final helperColor = isEnabled
        ? scheme.onSurfaceVariant
        : scheme.onSurfaceVariant.withValues(
            alpha: StateOpacities.disabledContent,
          );

    final checkbox = AppCheckbox(
      value: value,
      onChanged: isEnabled ? onChanged : null,
      size: size,
      variant: variant,
      enabled: enabled,
      tristate: tristate,
      semanticLabel: semanticLabel ?? label,
      autofocus: autofocus,
      focusNode: focusNode,
      enableFeedback: enableFeedback,
      hapticFeedback: hapticFeedback,
    );

    final labelWidget = AppText.bodyMedium(
      label,
      color: labelColor,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );

    final helperWidget = helperText == null
        ? null
        : AppText.bodySmall(helperText!, color: helperColor);

    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelWidget,
          if (helperWidget != null) ...[
            const SizedBox(height: AppSpacing.space2),
            helperWidget,
          ],
        ],
      ),
    );

    final children = checkboxOnTrailing
        ? <Widget>[
            textColumn,
            const SizedBox(width: AppSpacing.space12),
            checkbox,
          ]
        : <Widget>[
            checkbox,
            const SizedBox(width: AppSpacing.space12),
            textColumn,
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? _handleTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.space8),
        child: Padding(
          padding: effectivePadding,
          child: MergeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    if (!enabled || onChanged == null) return;

    if (!tristate) {
      _triggerHaptic();
      onChanged?.call(!(value ?? false));
      return;
    }

    final next = switch (value) {
      false => true,
      true => null,
      null => false,
    };
    _triggerHaptic();
    onChanged?.call(next);
  }

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
}
