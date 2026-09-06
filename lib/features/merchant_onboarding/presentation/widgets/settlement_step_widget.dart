import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/app_textfield.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_dropdown_field.dart';

class SettlementStepWidget extends StatelessWidget {
  const SettlementStepWidget({
    super.key,
    required this.input,
    required this.owners,
    required this.reference,
    required this.cubit,
    required this.failures,
    required this.registerFocus,
  });

  final SettlementInput input;
  final List<OwnerInput> owners;
  final MerchantReferenceDataEntity reference;
  final MerchantOnboardingCubit cubit;
  final List<MerchantValidationFailure> failures;
  final RegisterFocus registerFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String? errorFor(String path) {
      final failure = failures.where((f) => f.path == path).firstOrNull;
      return failure == null
          ? null
          : messageForMerchantValidationFailure(failure, l10n);
    }

    final holderType = reference.holderTypeById(input.holderTypeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MerchantDropdownField(
          key: const ValueKey('settlement_bank'),
          focusNode: registerFocus('settlement.bankId'),
          label: l10n.merchantOnboardingFieldBank,
          value: input.bankId,
          options: [
            for (final bank in reference.banks)
              ReferenceOptionEntity(id: bank.id, label: bank.label),
          ],
          errorText: errorFor('settlement.bankId'),
          onChanged: cubit.settlementBankChanged,
        ),
        const SizedBox(height: AppSpacing.space16),
        AppTextField(
          key: const ValueKey('settlement_holder_name'),
          focusNode: registerFocus('settlement.accountHolderName'),
          initialValue: input.accountHolderName,
          labelText: l10n.merchantOnboardingFieldAccountHolderName,
          errorText: errorFor('settlement.accountHolderName'),
          onChanged: cubit.settlementHolderNameChanged,
        ),
        const SizedBox(height: AppSpacing.space16),
        AppTextField(
          key: const ValueKey('settlement_account_number'),
          focusNode: registerFocus('settlement.accountNumber'),
          initialValue: input.accountNumber,
          labelText: l10n.merchantOnboardingFieldAccountNumber,
          keyboardType: TextInputType.number,
          errorText: errorFor('settlement.accountNumber'),
          onChanged: cubit.settlementAccountNumberChanged,
        ),
        const SizedBox(height: AppSpacing.space16),
        MerchantDropdownField(
          key: const ValueKey('settlement_holder_type'),
          focusNode: registerFocus('settlement.holderTypeId'),
          label: l10n.merchantOnboardingFieldHolderType,
          value: input.holderTypeId,
          options: [
            for (final type in reference.holderTypes)
              ReferenceOptionEntity(id: type.id, label: type.label),
          ],
          errorText: errorFor('settlement.holderTypeId'),
          onChanged: cubit.settlementHolderTypeChanged,
        ),
        if (holderType?.requiresOwnerReference == true) ...[
          const SizedBox(height: AppSpacing.space16),
          MerchantDropdownField(
            key: const ValueKey('settlement_owner_reference'),
            focusNode: registerFocus('settlement.ownerRowId'),
            label: l10n.merchantOnboardingFieldOwnerReference,
            value: input.ownerRowId,
            options: [
              for (final owner in owners)
                ReferenceOptionEntity(
                  id: owner.ownerRowId,
                  label: owner.fullName,
                ),
            ],
            errorText: errorFor('settlement.ownerRowId'),
            onChanged: cubit.settlementOwnerReferenceChanged,
          ),
        ],
        const SizedBox(height: AppSpacing.space16),
        MerchantDropdownField(
          key: const ValueKey('settlement_payout_schedule'),
          focusNode: registerFocus('settlement.payoutScheduleId'),
          label: l10n.merchantOnboardingFieldPayoutSchedule,
          value: input.payoutScheduleId,
          options: reference.payoutSchedules,
          errorText: errorFor('settlement.payoutScheduleId'),
          onChanged: cubit.settlementPayoutScheduleChanged,
        ),
      ],
    );
  }
}
