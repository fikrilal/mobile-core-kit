import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';

/// Pure mapping from remote reference models to the immutable domain
/// snapshot. Malformed assumptions (unknown flags) are rejected safely by
/// returning null so the caller can surface a domain failure.
MerchantReferenceData? merchantReferenceDataFromDto(
  MerchantReferenceDataDto dto,
) {
  return MerchantReferenceData(
    businessTypes: [
      for (final option in dto.businessTypes)
        BusinessTypeOption(
          id: option.id,
          label: option.label,
          requiresRegistrationNumber: option.requiresRegistrationNumber,
        ),
    ],
    industries: [
      for (final option in dto.industries)
        ReferenceOption(id: option.id, label: option.label),
    ],
    monthlySalesRanges: [
      for (final option in dto.monthlySalesRanges)
        ReferenceOption(id: option.id, label: option.label),
    ],
    ownerRoles: [
      for (final option in dto.ownerRoles)
        OwnerRoleOption(
          id: option.id,
          label: option.label,
          contributesOwnership: option.contributesOwnership,
        ),
    ],
    banks: [
      for (final option in dto.banks)
        BankOption(
          id: option.id,
          label: option.label,
          supportedScheduleIds: option.supportedPayoutScheduleIds.toSet(),
        ),
    ],
    holderTypes: [
      for (final option in dto.accountHolderTypes)
        AccountHolderTypeOption(
          id: option.id,
          label: option.label,
          requiresOwnerReference: option.requiresOwnerReference,
        ),
    ],
    payoutSchedules: [
      for (final option in dto.payoutSchedules)
        ReferenceOption(id: option.id, label: option.label),
    ],
    termsVersion: dto.termsVersion,
  );
}
