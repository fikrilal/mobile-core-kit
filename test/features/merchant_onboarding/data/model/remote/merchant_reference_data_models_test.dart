import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_reference_data_models.dart';

void main() {
  test(
    'maps every catalog metadata field into the domain snapshot via toDomain',
    () {
      const model = MerchantReferenceDataModel(
        businessTypes: [
          MerchantBusinessTypeOptionModel(
            id: 'private_company',
            label: 'Private company',
            requiresRegistrationNumber: true,
          ),
          MerchantBusinessTypeOptionModel(
            id: 'sole_proprietorship',
            label: 'Sole proprietorship',
            requiresRegistrationNumber: false,
          ),
        ],
        industries: [MerchantLabeledOptionModel(id: 'retail', label: 'Retail')],
        monthlySalesRanges: [
          MerchantLabeledOptionModel(id: '10m_to_50m_idr', label: 'IDR 10-50m'),
        ],
        ownerRoles: [
          MerchantOwnerRoleOptionModel(
            id: 'owner',
            label: 'Owner',
            contributesOwnership: true,
          ),
        ],
        banks: [
          MerchantBankOptionModel(
            id: 'demo_bank_alpha',
            label: 'Demo Bank Alpha',
            supportedPayoutScheduleIds: ['daily', 'weekly'],
          ),
        ],
        accountHolderTypes: [
          MerchantAccountHolderTypeOptionModel(
            id: 'owner',
            label: 'Owner',
            requiresOwnerReference: true,
          ),
        ],
        payoutSchedules: [
          MerchantLabeledOptionModel(id: 'weekly', label: 'Weekly'),
        ],
        termsVersion: '2026-08-30',
      );

      final reference = model.toDomain();

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
    },
  );
}
