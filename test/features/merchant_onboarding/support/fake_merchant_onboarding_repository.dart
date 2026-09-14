import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

/// Deterministic fake adapter standing in for the future backend. It serves
/// the documented demo catalogs and returns a stable, non-sensitive
/// application id. It performs no remote bank or eligibility checks and never
/// sees raw form primitives.
class FakeMerchantOnboardingRepository implements MerchantOnboardingRepository {
  FakeMerchantOnboardingRepository({MerchantReferenceDataEntity? referenceData})
    : _referenceData = referenceData ?? demoReferenceData();

  final MerchantReferenceDataEntity _referenceData;

  /// Stable demo application id; contains no entered values.
  static const String demoApplicationId = 'demo-merchant-application-0001';

  /// Code-owned demo reference data matching the plan's catalog table.
  static MerchantReferenceDataEntity
  demoReferenceData() => MerchantReferenceDataEntity(
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

  @override
  Future<Either<MerchantOnboardingFailure, MerchantReferenceDataEntity>>
  loadReferenceData() async {
    return right(_referenceData);
  }

  @override
  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>>
  submitApplication(MerchantOnboardingApplication application) async {
    return right(
      const MerchantApplicationReceipt(applicationId: demoApplicationId),
    );
  }

  /// Remote reference model mirroring [demoReferenceData] for repository tests.
  static MerchantReferenceDataModel demoReferenceDataModel() {
    final reference = demoReferenceData();
    return MerchantReferenceDataModel(
      businessTypes: [
        for (final option in reference.businessTypes)
          MerchantBusinessTypeOptionModel(
            id: option.id,
            label: option.label,
            requiresRegistrationNumber: option.requiresRegistrationNumber,
          ),
      ],
      industries: [
        for (final option in reference.industries)
          MerchantLabeledOptionModel(id: option.id, label: option.label),
      ],
      monthlySalesRanges: [
        for (final option in reference.monthlySalesRanges)
          MerchantLabeledOptionModel(id: option.id, label: option.label),
      ],
      ownerRoles: [
        for (final option in reference.ownerRoles)
          MerchantOwnerRoleOptionModel(
            id: option.id,
            label: option.label,
            contributesOwnership: option.contributesOwnership,
          ),
      ],
      banks: [
        for (final option in reference.banks)
          MerchantBankOptionModel(
            id: option.id,
            label: option.label,
            supportedPayoutScheduleIds: option.supportedScheduleIds.toList(),
          ),
      ],
      accountHolderTypes: [
        for (final option in reference.holderTypes)
          MerchantAccountHolderTypeOptionModel(
            id: option.id,
            label: option.label,
            requiresOwnerReference: option.requiresOwnerReference,
          ),
      ],
      payoutSchedules: [
        for (final option in reference.payoutSchedules)
          MerchantLabeledOptionModel(id: option.id, label: option.label),
      ],
      termsVersion: reference.termsVersion,
    );
  }
}
