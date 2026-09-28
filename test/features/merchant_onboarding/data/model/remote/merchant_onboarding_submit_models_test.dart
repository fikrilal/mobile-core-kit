import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';

import '../../../domain/merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  test(
    'maps a validated application losslessly to basis points and strings via fromApplication',
    () {
      final application = MerchantOnboardingApplication.create(
        input: validInput(
          owners: [
            validOwnerInput(ownerRowId: 'row-1', ownershipPercentage: '33.33'),
            validOwnerInput(
              ownerRowId: 'row-2',
              fullName: 'Sari Dewi',
              ownershipPercentage: '66.67',
              email: 'sari@example.com',
              isPrimaryContact: false,
            ),
          ],
          settlement: validSettlementInput(
            accountNumber: '0012345678',
            holderTypeId: 'owner',
            ownerRowId: 'row-1',
            payoutScheduleId: 'weekly',
            bankId: 'demo_bank_beta',
          ),
        ),
        reference: reference,
      ).getRight().toNullable()!;

      final request = MerchantOnboardingSubmitRequestModel.fromApplication(
        application,
      );

      expect(request.business.legalName, 'Kopi Nusantara');
      expect(request.business.businessTypeId, 'sole_proprietorship');
      expect(request.business.registrationNumber, isNull);

      expect(request.owners, hasLength(2));
      expect(request.owners[0].ownershipBasisPoints, 3333);
      expect(request.owners[1].ownershipBasisPoints, 6667);
      expect(request.owners[0].isPrimaryContact, true);

      // Account number stays a string with leading zeroes.
      expect(request.settlement.accountNumber, '0012345678');
      expect(request.settlement.ownerRowId, 'row-1');
      expect(request.settlement.payoutScheduleId, 'weekly');

      expect(request.declarations.termsVersion, '2026-08-30');
      expect(request.declarations.informationAccurate, true);
    },
  );

  test(
    'omits nullable fields for non-owning roles and business-held accounts',
    () {
      final application = MerchantOnboardingApplication.create(
        input: validInput(
          owners: [
            validOwnerInput(
              ownerRowId: 'row-1',
              fullName: 'Budi Santoso',
              roleId: 'owner',
              ownershipPercentage: '100',
              isPrimaryContact: false,
            ),
            validOwnerInput(
              ownerRowId: 'row-2',
              fullName: 'Sari Dewi',
              roleId: 'director',
              ownershipPercentage: '',
              email: 'sari@example.com',
              isPrimaryContact: true,
            ),
          ],
          settlement: validSettlementInput(
            holderTypeId: 'business',
            ownerRowId: null,
          ),
        ),
        reference: reference,
      ).getRight().toNullable()!;

      final request = MerchantOnboardingSubmitRequestModel.fromApplication(
        application,
      );

      expect(request.owners[1].ownershipBasisPoints, isNull);
      expect(request.settlement.ownerRowId, isNull);
    },
  );
}
