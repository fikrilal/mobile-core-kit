import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';

/// Demo reference data matching the plan's catalog table exactly.
MerchantReferenceDataEntity buildReferenceData() => MerchantReferenceDataEntity(
  businessTypes: [
    BusinessTypeOptionEntity(
      id: 'sole_proprietorship',
      label: 'Sole proprietorship',
      requiresRegistrationNumber: false,
    ),
    BusinessTypeOptionEntity(
      id: 'private_company',
      label: 'Private company',
      requiresRegistrationNumber: true,
    ),
  ],
  industries: [
    ReferenceOptionEntity(id: 'retail', label: 'Retail'),
    ReferenceOptionEntity(id: 'food_beverage', label: 'Food & beverage'),
    ReferenceOptionEntity(
      id: 'professional_services',
      label: 'Professional services',
    ),
    ReferenceOptionEntity(id: 'digital_services', label: 'Digital services'),
  ],
  monthlySalesRanges: [
    ReferenceOptionEntity(id: 'under_10m_idr', label: '< IDR 10 million'),
    ReferenceOptionEntity(id: '10m_to_50m_idr', label: 'IDR 10-50 million'),
    ReferenceOptionEntity(id: '50m_to_250m_idr', label: 'IDR 50-250 million'),
    ReferenceOptionEntity(id: 'above_250m_idr', label: '> IDR 250 million'),
  ],
  ownerRoles: [
    OwnerRoleOptionEntity(
      id: 'owner',
      label: 'Owner',
      contributesOwnership: true,
    ),
    OwnerRoleOptionEntity(
      id: 'director',
      label: 'Director',
      contributesOwnership: false,
    ),
  ],
  banks: [
    BankOptionEntity(
      id: 'demo_bank_alpha',
      label: 'Demo Bank Alpha',
      supportedScheduleIds: {'daily', 'weekly'},
    ),
    BankOptionEntity(
      id: 'demo_bank_beta',
      label: 'Demo Bank Beta',
      supportedScheduleIds: {'weekly'},
    ),
  ],
  holderTypes: [
    AccountHolderTypeOptionEntity(
      id: 'business',
      label: 'Business',
      requiresOwnerReference: false,
    ),
    AccountHolderTypeOptionEntity(
      id: 'owner',
      label: 'Owner',
      requiresOwnerReference: true,
    ),
  ],
  payoutSchedules: [
    ReferenceOptionEntity(id: 'daily', label: 'Daily'),
    ReferenceOptionEntity(id: 'weekly', label: 'Weekly'),
  ],
  termsVersion: '2026-08-30',
);

BusinessProfileInput validBusinessInput({
  String legalName = 'Kopi Nusantara',
  String? businessTypeId = 'sole_proprietorship',
  String registrationNumber = '',
  String? industryId = 'retail',
  String? monthlySalesRangeId = '10m_to_50m_idr',
  String contactEmail = 'contact@kopinusantara.id',
  String contactPhone = '+62 812-3456-7890',
}) {
  return BusinessProfileInput(
    legalName: legalName,
    businessTypeId: businessTypeId,
    registrationNumber: registrationNumber,
    industryId: industryId,
    monthlySalesRangeId: monthlySalesRangeId,
    contactEmail: contactEmail,
    contactPhone: contactPhone,
  );
}

OwnerInput validOwnerInput({
  String ownerRowId = 'row-1',
  String fullName = 'Budi Santoso',
  String? roleId = 'owner',
  String ownershipPercentage = '100',
  String email = 'budi@example.com',
  bool isPrimaryContact = true,
}) {
  return OwnerInput(
    ownerRowId: ownerRowId,
    fullName: fullName,
    roleId: roleId,
    ownershipPercentage: ownershipPercentage,
    email: email,
    isPrimaryContact: isPrimaryContact,
  );
}

SettlementInput validSettlementInput({
  String? bankId = 'demo_bank_alpha',
  String accountHolderName = 'Budi Santoso',
  String accountNumber = '0123456789',
  String? holderTypeId = 'business',
  String? ownerRowId,
  String? payoutScheduleId = 'daily',
}) {
  return SettlementInput(
    bankId: bankId,
    accountHolderName: accountHolderName,
    accountNumber: accountNumber,
    holderTypeId: holderTypeId,
    ownerRowId: ownerRowId,
    payoutScheduleId: payoutScheduleId,
  );
}

const acceptedDeclarationsInput = DeclarationsInput(
  informationAccurate: true,
  authorizedToSubmit: true,
  termsAccepted: true,
  termsVersion: '2026-08-30',
);

MerchantOnboardingInput validInput({
  BusinessProfileInput? business,
  List<OwnerInput>? owners,
  SettlementInput? settlement,
}) {
  return MerchantOnboardingInput(
    business: business ?? validBusinessInput(),
    owners: owners ?? [validOwnerInput()],
    settlement: settlement ?? validSettlementInput(),
    declarations: acceptedDeclarationsInput,
  );
}
