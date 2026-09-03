import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/checkbox/app_checkbox_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/business_step_widget.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

class ReviewStepWidget extends StatelessWidget {
  const ReviewStepWidget({
    super.key,
    required this.input,
    required this.reference,
    required this.cubit,
    required this.failures,
    required this.registerFocus,
  });

  final MerchantOnboardingInput input;
  final MerchantReferenceData reference;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewSection(
          title: l10n.merchantOnboardingStepBusiness,
          onEdit: () =>
              cubit.editStepRequested(MerchantOnboardingStep.business),
          children: [
            _ReviewRow(
              label: l10n.merchantOnboardingFieldLegalName,
              value: input.business.legalName,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldBusinessType,
              value: reference
                  .businessTypeById(input.business.businessTypeId)
                  ?.label,
            ),
            if (input.business.registrationNumber.isNotEmpty)
              _ReviewRow(
                label: l10n.merchantOnboardingFieldRegistrationNumber,
                value: input.business.registrationNumber,
              ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldIndustry,
              value: reference.industryById(input.business.industryId)?.label,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldMonthlySales,
              value: reference
                  .monthlySalesRangeById(input.business.monthlySalesRangeId)
                  ?.label,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldContactEmail,
              value: input.business.contactEmail,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldContactPhone,
              value: input.business.contactPhone,
            ),
          ],
        ),
        _ReviewSection(
          title: l10n.merchantOnboardingStepOwners,
          onEdit: () => cubit.editStepRequested(MerchantOnboardingStep.owners),
          children: [
            for (final (index, owner) in input.owners.indexed) ...[
              _ReviewRow(
                label: l10n.merchantOnboardingOwnerN(n: index + 1),
                value:
                    '${owner.fullName} — ${owner.roleId ?? l10n.merchantOnboardingNotProvided}'
                    '${owner.isPrimaryContact ? ' • ${l10n.merchantOnboardingFieldPrimaryContact}' : ''}',
              ),
              if (owner.ownershipPercentage.isNotEmpty)
                _ReviewRow(
                  label: l10n.merchantOnboardingFieldOwnershipPercentage,
                  value: '${owner.ownershipPercentage}%',
                ),
            ],
          ],
        ),
        _ReviewSection(
          title: l10n.merchantOnboardingStepSettlement,
          onEdit: () =>
              cubit.editStepRequested(MerchantOnboardingStep.settlement),
          children: [
            _ReviewRow(
              label: l10n.merchantOnboardingFieldBank,
              value: reference.bankById(input.settlement.bankId)?.label,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldAccountHolderName,
              value: input.settlement.accountHolderName,
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldAccountNumber,
              value: _maskAccountNumber(input.settlement.accountNumber, l10n),
            ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldHolderType,
              value: reference
                  .holderTypeById(input.settlement.holderTypeId)
                  ?.label,
            ),
            if (input.settlement.ownerRowId != null)
              _ReviewRow(
                label: l10n.merchantOnboardingFieldOwnerReference,
                value: input.owners
                    .where((o) => o.ownerRowId == input.settlement.ownerRowId)
                    .firstOrNull
                    ?.fullName,
              ),
            _ReviewRow(
              label: l10n.merchantOnboardingFieldPayoutSchedule,
              value: reference
                  .payoutScheduleById(input.settlement.payoutScheduleId)
                  ?.label,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),
        AppText.titleMedium(l10n.merchantOnboardingStepReview),
        const SizedBox(height: AppSpacing.space4),
        AppText.bodySmall(
          l10n.merchantOnboardingTermsVersionLabel(
            version: reference.termsVersion,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        AppCheckboxTile(
          key: const ValueKey('declaration_information_accurate'),
          focusNode: registerFocus('declarations.informationAccurate'),
          value: input.declarations.informationAccurate,
          label: l10n.merchantOnboardingDeclarationInformationAccurate,
          helperText: errorFor('declarations.informationAccurate'),
          onChanged: (value) =>
              cubit.declarationInformationAccurateToggled(value ?? false),
        ),
        AppCheckboxTile(
          key: const ValueKey('declaration_authorized_to_submit'),
          focusNode: registerFocus('declarations.authorizedToSubmit'),
          value: input.declarations.authorizedToSubmit,
          label: l10n.merchantOnboardingDeclarationAuthorizedToSubmit,
          helperText: errorFor('declarations.authorizedToSubmit'),
          onChanged: (value) =>
              cubit.declarationAuthorizedToSubmitToggled(value ?? false),
        ),
        AppCheckboxTile(
          key: const ValueKey('declaration_terms_accepted'),
          focusNode: registerFocus('declarations.termsAccepted'),
          value: input.declarations.termsAccepted,
          label: l10n.merchantOnboardingDeclarationTermsAccepted,
          helperText: errorFor('declarations.termsAccepted'),
          onChanged: (value) =>
              cubit.declarationTermsAcceptedToggled(value ?? false),
        ),
      ],
    );
  }

  String _maskAccountNumber(String raw, AppLocalizations l10n) {
    final digits = raw.replaceAll(' ', '');
    if (digits.isEmpty) return l10n.merchantOnboardingNotProvided;
    if (digits.length <= 4) return digits;
    return '****${digits.substring(digits.length - 4)}';
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.onEdit,
    required this.children,
  });

  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: AppText.titleMedium(title)),
            TextButton(
              onPressed: onEdit,
              child: Text(context.l10n.merchantOnboardingActionEdit),
            ),
          ],
        ),
        ...children,
        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AppText.bodySmall(
              label,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            flex: 3,
            child: AppText.bodyMedium(
              (value == null || value!.isEmpty)
                  ? context.l10n.merchantOnboardingNotProvided
                  : value!,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
