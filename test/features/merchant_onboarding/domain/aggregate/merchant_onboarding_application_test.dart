import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

import '../merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  MerchantReferenceDataEntity referenceWith({required String termsVersion}) =>
      MerchantReferenceDataEntity(
        businessTypes: reference.businessTypes,
        industries: reference.industries,
        monthlySalesRanges: reference.monthlySalesRanges,
        ownerRoles: reference.ownerRoles,
        banks: reference.banks,
        holderTypes: reference.holderTypes,
        payoutSchedules: reference.payoutSchedules,
        termsVersion: termsVersion,
      );

  test('constructs a complete valid application (acceptance scenario 1)', () {
    final result = MerchantOnboardingApplication.create(
      input: validInput(),
      reference: reference,
    );

    expect(result.isRight(), true);
    final application = result.getRight().toNullable()!;
    expect(application.business.legalName.value, 'Kopi Nusantara');
    expect(application.owners.rows, hasLength(1));
    expect(application.settlement.accountNumber.masked, '****6789');
    expect(application.declarations.termsVersion.value, '2026-08-30');
  });

  test('rejects an owner-held settlement referencing an unknown owner row', () {
    final result = MerchantOnboardingApplication.create(
      input: validInput(
        settlement: validSettlementInput(
          holderTypeId: 'owner',
          ownerRowId: 'missing-row',
          payoutScheduleId: 'weekly',
          bankId: 'demo_bank_beta',
        ),
      ),
      reference: reference,
    );

    final failures = result.getLeft().toNullable()!;
    expect(
      failures.any(
        (f) => f.code == MerchantValidationCodes.settlementOwnerUnknown,
      ),
      true,
    );
  });

  test('aggregates failures across steps in step order', () {
    final result = MerchantOnboardingApplication.create(
      input: MerchantOnboardingInput(
        business: validBusinessInput(legalName: ''),
        owners: [validOwnerInput(ownershipPercentage: '50')],
        settlement: validSettlementInput(bankId: null),
        declarations: const DeclarationsInput(),
      ),
      reference: reference,
    );

    final failures = result.getLeft().toNullable()!;
    expect(failures.first.code, 'business.legal_name.required');
    expect(failures.any((f) => f.code == 'owners.total.invalid'), true);
    expect(failures.any((f) => f.code == 'settlement.bank.required'), true);
    expect(
      failures.any(
        (f) => f.code == 'declarations.information_accurate.required',
      ),
      true,
    );
  });

  test('validated aggregates are immutable', () {
    final application = MerchantOnboardingApplication.create(
      input: validInput(),
      reference: reference,
    ).getRight().toNullable()!;

    // List mutators must throw: a validated application cannot be made
    // invalid after construction.
    expect(() => application.owners.rows.clear(), throwsUnsupportedError);
    expect(
      () => application.owners.rows.add(application.owners.rows.first),
      throwsUnsupportedError,
    );
  });

  test('raw input and reference snapshot lists are immutable', () {
    final input = MerchantOnboardingInput(owners: [validOwnerInput()]);
    final referenceData = buildReferenceData();

    expect(() => input.owners.clear(), throwsUnsupportedError);
    expect(() => referenceData.businessTypes.clear(), throwsUnsupportedError);
  });

  test('bank supported schedules are defensively copied', () {
    // Mutating the caller's set after snapshot construction must not change
    // the bank's validated schedule rule.
    final mutableSchedules = {'daily', 'weekly'};
    final bank = BankOptionEntity(
      id: 'demo_bank_gamma',
      label: 'Demo Bank Gamma',
      supportedScheduleIds: mutableSchedules,
    );

    mutableSchedules.clear();
    mutableSchedules.add('hourly');

    expect(bank.supportedScheduleIds, {'daily', 'weekly'});
    expect(() => bank.supportedScheduleIds.clear(), throwsUnsupportedError);
  });

  test('rejects a stale terms version against the snapshot', () {
    final result = MerchantOnboardingApplication.create(
      input: validInput(),
      reference: referenceWith(termsVersion: '2027-01-01'),
    );

    final failures = result.getLeft().toNullable()!;
    expect(
      failures.any(
        (f) => f.code == MerchantValidationCodes.declarationsTermsVersionStale,
      ),
      true,
    );
  });
}
