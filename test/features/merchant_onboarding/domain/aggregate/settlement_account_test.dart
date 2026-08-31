import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/settlement_account.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

import '../merchant_test_fixtures.dart';

void main() {
  final reference = buildReferenceData();

  test('constructs a valid business-held settlement with normalization', () {
    final result = SettlementAccount.create(
      input: validSettlementInput(accountNumber: ' 0123 4567 89 '),
      reference: reference,
    );

    final settlement = result.getRight().toNullable()!;
    expect(settlement.bankId.value, 'demo_bank_alpha');
    expect(settlement.accountHolderName.value, 'Budi Santoso');
    expect(settlement.accountNumber.value, '0123456789');
    expect(settlement.ownerRowId, isNull);
    expect(settlement.payoutScheduleId.value, 'daily');
  });

  test('requires an owner reference for owner-held accounts', () {
    final failures = SettlementAccount.create(
      input: validSettlementInput(holderTypeId: 'owner', ownerRowId: null),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.any(
        (f) =>
            f.code == MerchantValidationCodes.settlementOwnerRequired &&
            f.path == 'settlement.ownerRowId',
      ),
      true,
    );
  });

  test('accepts an owner reference for owner-held accounts', () {
    final result = SettlementAccount.create(
      input: validSettlementInput(
        holderTypeId: 'owner',
        ownerRowId: 'row-1',
        payoutScheduleId: 'weekly',
        bankId: 'demo_bank_beta',
      ),
      reference: reference,
    );

    expect(result.getRight().toNullable()!.ownerRowId!.value, 'row-1');
  });

  test('rejects an owner reference on business-held accounts', () {
    final failures = SettlementAccount.create(
      input: validSettlementInput(ownerRowId: 'row-1'),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.any(
        (f) => f.code == MerchantValidationCodes.settlementOwnerNotAllowed,
      ),
      true,
    );
  });

  test('rejects a payout schedule unsupported by the selected bank', () {
    final failures = SettlementAccount.create(
      input: validSettlementInput(bankId: 'demo_bank_beta'),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.any(
        (f) =>
            f.code ==
                MerchantValidationCodes.settlementScheduleUnsupportedByBank &&
            f.path == 'settlement.payoutScheduleId',
      ),
      true,
    );
  });

  test('rejects missing and unknown catalog ids', () {
    final failures = SettlementAccount.create(
      input: validSettlementInput(
        bankId: null,
        holderTypeId: 'unknown_holder',
        payoutScheduleId: 'hourly',
      ),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.map((f) => f.code),
      containsAll([
        MerchantValidationCodes.settlementBankRequired,
        MerchantValidationCodes.settlementHolderTypeUnsupported,
        MerchantValidationCodes.settlementScheduleUnsupported,
      ]),
    );
  });

  test('applies holder-type conditional with whitespace-normalized ids', () {
    // ' owner ' normalizes to owner, so the owner reference requirement must
    // still apply.
    final failures = SettlementAccount.create(
      input: validSettlementInput(holderTypeId: ' owner ', ownerRowId: null),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.any(
        (f) => f.code == MerchantValidationCodes.settlementOwnerRequired,
      ),
      true,
    );
  });

  test(
    'applies bank schedule compatibility with whitespace-normalized ids',
    () {
      // ' demo_bank_beta ' normalizes to demo_bank_beta (weekly only).
      final failures = SettlementAccount.create(
        input: validSettlementInput(
          bankId: ' demo_bank_beta ',
          payoutScheduleId: 'daily',
        ),
        reference: reference,
      ).getLeft().toNullable()!;

      expect(
        failures.any(
          (f) =>
              f.code ==
              MerchantValidationCodes.settlementScheduleUnsupportedByBank,
        ),
        true,
      );
    },
  );

  test('rejects malformed account numbers and holder names', () {
    final failures = SettlementAccount.create(
      input: validSettlementInput(
        accountHolderName: 'A',
        accountNumber: '12ab',
      ),
      reference: reference,
    ).getLeft().toNullable()!;

    expect(
      failures.map((f) => f.code),
      containsAll([
        MerchantValidationCodes.settlementHolderNameInvalid,
        MerchantValidationCodes.settlementAccountNumberInvalid,
      ]),
    );
  });
}
