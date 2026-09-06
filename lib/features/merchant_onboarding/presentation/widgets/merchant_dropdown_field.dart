import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field_styles.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field_variants.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';

class MerchantDropdownField extends StatelessWidget {
  const MerchantDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.focusNode,
    this.errorText,
    this.hintText,
    this.optionLabel,
  });

  final String label;
  final String? value;
  final List<ReferenceOptionEntity> options;
  final ValueChanged<String?> onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final String? hintText;
  final String? Function(ReferenceOptionEntity)? optionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = errorText != null;
    final decoration = FieldStyles.getInputDecoration(
      context: context,
      variant: FieldVariant.outline,
      size: FieldSize.medium,
      state: isError ? FieldState.error : FieldState.enabled,
      hintText: hintText,
      errorText: errorText,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isError
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        DropdownButtonFormField<String>(
          key: ValueKey('dropdown_$label'),
          focusNode: focusNode,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: decoration,
          borderRadius: BorderRadius.circular(AppRadii.radius12),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.id,
                child: Text(
                  optionLabel?.call(option) ?? option.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
