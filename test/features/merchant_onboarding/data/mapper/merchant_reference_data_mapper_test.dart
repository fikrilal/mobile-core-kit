import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/mapper/merchant_reference_data_mapper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';

void main() {
  test('maps every catalog metadata field into the domain snapshot', () {
    final dto = MerchantReferenceDataDto(
      businessTypes: const [
        MerchantBusinessTypeOptionDto(
          id: 'private_company',
          label: 'Private company',
          requiresRegistrationNumber: true,
        ),
        MerchantBusinessTypeOptionDto(
          id: 'sole_proprietorship',
          label: 'Sole proprietorship',
          requiresRegistrationNumber: false,
        ),
      ],
      industries: const [
        MerchantLabeledOptionDto(id: 'retail', label: 'Retail'),
      ],
      monthlySalesRanges: const [
        MerchantLabeledOptionDto(id: '10m_to_50m_idr', label: 'IDR 10-50m'),
      ],
      ownerRoles: const [
        MerchantOwnerRoleOptionDto(
          id: 'owner',
          label: 'Owner',
          contributesOwnership: true,
        ),
      ],
      banks: const [
        MerchantBankOptionDto(
          id: 'demo_bank_alpha',
          label: 'Demo Bank Alpha',
          supportedPayoutScheduleIds: ['daily', 'weekly'],
        ),
      ],
      accountHolderTypes: const [
        MerchantAccountHolderTypeOptionDto(
          id: 'owner',
          label: 'Owner',
          requiresOwnerReference: true,
        ),
      ],
      payoutSchedules: const [
        MerchantLabeledOptionDto(id: 'weekly', label: 'Weekly'),
      ],
      termsVersion: '2026-08-30',
    );

    final reference = merchantReferenceDataFromDto(dto)!;

    expect(
      reference.businessTypes
          .firstWhere((o) => o.id == 'private_company')
          .requiresRegistrationNumber,
      true,
    );
    expect(reference.ownerRoles.first.contributesOwnership, true);
    expect(reference.banks.first.supportedScheduleIds, {'daily', 'weekly'});
    expect(reference.holderTypes.first.requiresOwnerReference, true);
    expect(reference.termsVersion, '2026-08-30');
  });
}
