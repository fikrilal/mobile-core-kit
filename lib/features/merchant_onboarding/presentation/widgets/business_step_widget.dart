import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/app_textfield.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/widgets/merchant_dropdown_field.dart';

typedef RegisterFocus = FocusNode Function(String path);

class BusinessStepWidget extends StatelessWidget {
  const BusinessStepWidget({
    super.key,
    required this.input,
    required this.reference,
    required this.cubit,
    required this.failures,
    required this.registerFocus,
  });

  final BusinessProfileInput input;
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

    final selectedType = reference.businessTypeById(input.businessTypeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          key: const ValueKey('business_legal_name'),
          focusNode: registerFocus('business.legalName'),
          initialValue: input.legalName,
          labelText: l10n.merchantOnboardingFieldLegalName,
          errorText: errorFor('business.legalName'),
          onChanged: cubit.businessLegalNameChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        MerchantDropdownField(
          key: const ValueKey('business_type'),
          focusNode: registerFocus('business.businessTypeId'),
          label: l10n.merchantOnboardingFieldBusinessType,
          value: input.businessTypeId,
          options: [
            for (final type in reference.businessTypes)
              ReferenceOptionEntity(id: type.id, label: type.label),
          ],
          errorText: errorFor('business.businessTypeId'),
          onChanged: cubit.businessTypeChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppTextField(
          key: const ValueKey('business_registration_number'),
          focusNode: registerFocus('business.registrationNumber'),
          initialValue: input.registrationNumber,
          labelText: l10n.merchantOnboardingFieldRegistrationNumber,
          hintText: selectedType?.requiresRegistrationNumber == true
              ? l10n.merchantOnboardingFieldRegistrationHint
              : null,
          errorText: errorFor('business.registrationNumber'),
          onChanged: cubit.businessRegistrationNumberChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        MerchantDropdownField(
          key: const ValueKey('business_industry'),
          focusNode: registerFocus('business.industryId'),
          label: l10n.merchantOnboardingFieldIndustry,
          value: input.industryId,
          options: reference.industries,
          errorText: errorFor('business.industryId'),
          onChanged: cubit.businessIndustryChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        MerchantDropdownField(
          key: const ValueKey('business_monthly_sales'),
          focusNode: registerFocus('business.monthlySalesRangeId'),
          label: l10n.merchantOnboardingFieldMonthlySales,
          value: input.monthlySalesRangeId,
          options: reference.monthlySalesRanges,
          errorText: errorFor('business.monthlySalesRangeId'),
          onChanged: cubit.businessMonthlySalesRangeChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppTextField.email(
          key: const ValueKey('business_contact_email'),
          focusNode: registerFocus('business.contactEmail'),
          initialValue: input.contactEmail,
          labelText: l10n.merchantOnboardingFieldContactEmail,
          errorText: errorFor('business.contactEmail'),
          onChanged: cubit.businessContactEmailChanged,
        ),
        const SizedBox(height: AppSpacing.space12),
        AppTextField(
          key: const ValueKey('business_contact_phone'),
          focusNode: registerFocus('business.contactPhone'),
          initialValue: input.contactPhone,
          labelText: l10n.merchantOnboardingFieldContactPhone,
          keyboardType: TextInputType.phone,
          errorText: errorFor('business.contactPhone'),
          onChanged: cubit.businessContactPhoneChanged,
        ),
      ],
    );
  }
}
