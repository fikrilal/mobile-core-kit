import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/checkbox/app_checkbox_tile.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/app_textfield.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/models/owner_move_direction.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_dropdown_field.dart';

class MerchantOwnerRowCard extends StatelessWidget {
  const MerchantOwnerRowCard({
    super.key,
    required this.row,
    required this.index,
    required this.reference,
    required this.cubit,
    required this.failures,
    required this.registerFocus,
  });

  final OwnerInput row;
  final int index;
  final MerchantReferenceDataEntity reference;
  final MerchantOnboardingCubit cubit;
  final List<MerchantValidationFailure> failures;
  final RegisterFocus registerFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rowPath = 'owners.${row.ownerRowId}';

    String? errorFor(String path) {
      final failure = failures.where((f) => f.path == path).firstOrNull;
      return failure == null
          ? null
          : messageForMerchantValidationFailure(failure, l10n);
    }

    return Container(
      key: ValueKey('owner_card_${row.ownerRowId}'),
      margin: const EdgeInsets.only(bottom: AppSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.radius12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText.titleMedium(
                  l10n.merchantOnboardingOwnerN(n: index + 1),
                ),
              ),
              IconButton(
                key: ValueKey('owner_up_${row.ownerRowId}'),
                visualDensity: VisualDensity.compact,
                iconSize: AppSizing.iconSizeCompact,
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: l10n.merchantOnboardingActionMoveUp,
                onPressed: index == 0
                    ? null
                    : () => cubit.ownerMoved(
                        row.ownerRowId,
                        OwnerMoveDirection.up,
                      ),
              ),
              IconButton(
                key: ValueKey('owner_down_${row.ownerRowId}'),
                visualDensity: VisualDensity.compact,
                iconSize: AppSizing.iconSizeCompact,
                icon: const Icon(Icons.arrow_downward_rounded),
                tooltip: l10n.merchantOnboardingActionMoveDown,
                onPressed: () =>
                    cubit.ownerMoved(row.ownerRowId, OwnerMoveDirection.down),
              ),
              IconButton(
                key: ValueKey('owner_remove_${row.ownerRowId}'),
                visualDensity: VisualDensity.compact,
                iconSize: AppSizing.iconSizeCompact,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                ),
                tooltip: l10n.merchantOnboardingActionRemoveOwner,
                onPressed: () => cubit.ownerRemoved(row.ownerRowId),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          AppTextField(
            key: ValueKey('owner_name_${row.ownerRowId}'),
            focusNode: registerFocus('$rowPath.fullName'),
            initialValue: row.fullName,
            labelText: l10n.merchantOnboardingFieldOwnerName,
            errorText: errorFor('$rowPath.fullName'),
            onChanged: (value) => cubit.ownerNameChanged(row.ownerRowId, value),
          ),
          const SizedBox(height: AppSpacing.space16),
          MerchantDropdownField(
            key: ValueKey('owner_role_${row.ownerRowId}'),
            focusNode: registerFocus('$rowPath.roleId'),
            label: l10n.merchantOnboardingFieldOwnerRole,
            value: row.roleId,
            options: [
              for (final roleOption in reference.ownerRoles)
                ReferenceOptionEntity(
                  id: roleOption.id,
                  label: roleOption.label,
                ),
            ],
            errorText: errorFor('$rowPath.roleId'),
            onChanged: (id) => cubit.ownerRoleChanged(row.ownerRowId, id),
          ),
          const SizedBox(height: AppSpacing.space16),
          AppTextField(
            key: ValueKey('owner_percentage_${row.ownerRowId}'),
            focusNode: registerFocus('$rowPath.ownershipPercentage'),
            initialValue: row.ownershipPercentage,
            labelText: l10n.merchantOnboardingFieldOwnershipPercentage,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: errorFor('$rowPath.ownershipPercentage'),
            onChanged: (value) =>
                cubit.ownerPercentageChanged(row.ownerRowId, value),
          ),
          const SizedBox(height: AppSpacing.space16),
          AppTextField.email(
            key: ValueKey('owner_email_${row.ownerRowId}'),
            focusNode: registerFocus('$rowPath.email'),
            initialValue: row.email,
            labelText: l10n.merchantOnboardingFieldOwnerEmail,
            errorText: errorFor('$rowPath.email'),
            onChanged: (value) =>
                cubit.ownerEmailChanged(row.ownerRowId, value),
          ),
          const SizedBox(height: AppSpacing.space8),
          AppCheckboxTile(
            key: ValueKey('owner_primary_${row.ownerRowId}'),
            value: row.isPrimaryContact,
            label: l10n.merchantOnboardingFieldPrimaryContact,
            onChanged: (value) =>
                cubit.ownerPrimaryToggled(row.ownerRowId, value ?? false),
          ),
        ],
      ),
    );
  }
}
