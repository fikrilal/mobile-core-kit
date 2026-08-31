import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';

/// Pure mapping from the validated application aggregate to the wire submit
/// request. Ownership is converted losslessly to integer basis points
/// (already exact on the domain type; no floating point is involved) and the
/// account number is transported as a string so leading zeroes survive.
MerchantOnboardingSubmitRequestDto
merchantOnboardingSubmitRequestFromApplication(
  MerchantOnboardingApplication application,
) {
  return MerchantOnboardingSubmitRequestDto(
    business: MerchantBusinessInputDto(
      legalName: application.business.legalName.value,
      businessTypeId: application.business.businessTypeId.value,
      registrationNumber: application.business.registrationNumber?.value,
      industryId: application.business.industryId.value,
      monthlySalesRangeId: application.business.monthlySalesRangeId.value,
      contactEmail: application.business.contactEmail.value,
      contactPhone: application.business.contactPhone.value,
    ),
    owners: [
      for (final row in application.owners.rows)
        MerchantOwnerInputDto(
          ownerRowId: row.id.value,
          fullName: row.fullName.value,
          roleId: row.roleId.value,
          ownershipBasisPoints: row.percentage?.basisPoints,
          email: row.email.value,
          isPrimaryContact: row.isPrimaryContact,
        ),
    ],
    settlement: MerchantSettlementInputDto(
      bankId: application.settlement.bankId.value,
      accountHolderName: application.settlement.accountHolderName.value,
      accountNumber: application.settlement.accountNumber.value,
      holderTypeId: application.settlement.holderTypeId.value,
      ownerRowId: application.settlement.ownerRowId?.value,
      payoutScheduleId: application.settlement.payoutScheduleId.value,
    ),
    declarations: MerchantDeclarationsInputDto(
      informationAccurate: application.declarations.informationAccurate,
      authorizedToSubmit: application.declarations.authorizedToSubmit,
      termsAccepted: application.declarations.termsAccepted,
      termsVersion: application.declarations.termsVersion.value,
    ),
  );
}
