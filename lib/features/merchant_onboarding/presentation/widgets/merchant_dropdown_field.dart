import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
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
    this.optionLabel,
  });

  final String label;
  final String? value;
  final List<ReferenceOptionEntity> options;
  final ValueChanged<String?> onChanged;
  final FocusNode? focusNode;
  final String? errorText;
  final String? Function(ReferenceOptionEntity)? optionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          label,
          color: errorText != null ? scheme.error : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: AppSpacing.space8),
        DropdownButtonFormField<String>(
          key: ValueKey('dropdown_$label'),
          focusNode: focusNode,
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
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
