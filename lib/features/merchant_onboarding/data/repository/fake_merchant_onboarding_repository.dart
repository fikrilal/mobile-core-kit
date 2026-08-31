import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

/// Deterministic fake adapter standing in for the future backend. It serves
/// the documented demo catalogs and returns a stable, non-sensitive
/// application id. It performs no remote bank or eligibility checks and never
/// sees raw form primitives.
class FakeMerchantOnboardingRepository implements MerchantOnboardingRepository {
  FakeMerchantOnboardingRepository({MerchantReferenceData? referenceData})
    : _referenceData = referenceData ?? demoReferenceData();

  final MerchantReferenceData _referenceData;

  /// Stable demo application id; contains no entered values.
  static const String demoApplicationId = 'demo-merchant-application-0001';

  /// Code-owned demo reference data matching the plan's catalog table.
  static MerchantReferenceData demoReferenceData() => MerchantReferenceData(
    businessTypes: [
      BusinessTypeOption(
        id: 'sole_proprietorship',
        label: 'Sole proprietorship',
        requiresRegistrationNumber: false,
      ),
      BusinessTypeOption(
        id: 'private_company',
        label: 'Private company',
        requiresRegistrationNumber: true,
      ),
    ],
    industries: [
      ReferenceOption(id: 'retail', label: 'Retail'),
      ReferenceOption(id: 'food_beverage', label: 'Food & beverage'),
      ReferenceOption(
        id: 'professional_services',
        label: 'Professional services',
      ),
      ReferenceOption(id: 'digital_services', label: 'Digital services'),
    ],
    monthlySalesRanges: [
      ReferenceOption(id: 'under_10m_idr', label: '< IDR 10 million'),
      ReferenceOption(id: '10m_to_50m_idr', label: 'IDR 10-50 million'),
      ReferenceOption(id: '50m_to_250m_idr', label: 'IDR 50-250 million'),
      ReferenceOption(id: 'above_250m_idr', label: '> IDR 250 million'),
    ],
    ownerRoles: [
      OwnerRoleOption(id: 'owner', label: 'Owner', contributesOwnership: true),
      OwnerRoleOption(
        id: 'director',
        label: 'Director',
        contributesOwnership: false,
      ),
    ],
    banks: [
      BankOption(
        id: 'demo_bank_alpha',
        label: 'Demo Bank Alpha',
        supportedScheduleIds: {'daily', 'weekly'},
      ),
      BankOption(
        id: 'demo_bank_beta',
        label: 'Demo Bank Beta',
        supportedScheduleIds: {'weekly'},
      ),
    ],
    holderTypes: [
      AccountHolderTypeOption(
        id: 'business',
        label: 'Business',
        requiresOwnerReference: false,
      ),
      AccountHolderTypeOption(
        id: 'owner',
        label: 'Owner',
        requiresOwnerReference: true,
      ),
    ],
    payoutSchedules: [
      ReferenceOption(id: 'daily', label: 'Daily'),
      ReferenceOption(id: 'weekly', label: 'Weekly'),
    ],
    termsVersion: '2026-08-30',
  );

  @override
  Future<Either<MerchantOnboardingFailure, MerchantReferenceData>>
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
}
