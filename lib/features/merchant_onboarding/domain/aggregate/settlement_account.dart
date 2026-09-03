import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_value_objects.dart';

class SettlementAccount {
  const SettlementAccount._({
    required this.bankId,
    required this.accountHolderName,
    required this.accountNumber,
    required this.holderTypeId,
    required this.ownerRowId,
    required this.payoutScheduleId,
  });

  final BankId bankId;
  final BankAccountHolderName accountHolderName;
  final BankAccountNumber accountNumber;
  final AccountHolderTypeId holderTypeId;

  final OwnerRowId? ownerRowId;
  final PayoutScheduleId payoutScheduleId;

  static Either<List<MerchantValidationFailure>, SettlementAccount> create({
    required SettlementInput input,
    required MerchantReferenceData reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    BankId? bankId;
    BankAccountHolderName? accountHolderName;
    BankAccountNumber? accountNumber;
    AccountHolderTypeId? holderTypeId;
    OwnerRowId? ownerRowId;
    PayoutScheduleId? payoutScheduleId;

    BankId.create(input.bankId, reference).fold(errors.add, (v) => bankId = v);

    BankAccountHolderName.create(
      input.accountHolderName,
    ).fold(errors.add, (v) => accountHolderName = v);

    BankAccountNumber.create(
      input.accountNumber,
    ).fold(errors.add, (v) => accountNumber = v);

    AccountHolderTypeId.create(
      input.holderTypeId,
      reference,
    ).fold(errors.add, (v) => holderTypeId = v);

    final holderType = holderTypeId == null
        ? null
        : reference.holderTypeById(holderTypeId!.value);
    if (holderType != null) {
      final ownerRaw = input.ownerRowId?.trim() ?? '';
      if (holderType.requiresOwnerReference) {
        if (ownerRaw.isEmpty) {
          errors.add(
            const MerchantValidationFailure(
              code: MerchantValidationCodes.settlementOwnerRequired,
              path: 'settlement.ownerRowId',
            ),
          );
        } else {
          OwnerRowId.create(
            ownerRaw,
            path: 'settlement.ownerRowId',
          ).fold(errors.add, (v) => ownerRowId = v);
        }
      } else if (ownerRaw.isNotEmpty) {
        errors.add(
          const MerchantValidationFailure(
            code: MerchantValidationCodes.settlementOwnerNotAllowed,
            path: 'settlement.ownerRowId',
          ),
        );
      }
    }

    PayoutScheduleId.create(
      input.payoutScheduleId,
      reference,
    ).fold(errors.add, (v) => payoutScheduleId = v);

    final bank = bankId == null ? null : reference.bankById(bankId!.value);
    if (bank != null && payoutScheduleId != null) {
      if (!bank.supportedScheduleIds.contains(payoutScheduleId!.value)) {
        errors.add(
          const MerchantValidationFailure(
            code: MerchantValidationCodes.settlementScheduleUnsupportedByBank,
            path: 'settlement.payoutScheduleId',
          ),
        );
      }
    }

    if (errors.isNotEmpty) return left(errors);

    return right(
      SettlementAccount._(
        bankId: bankId!,
        accountHolderName: accountHolderName!,
        accountNumber: accountNumber!,
        holderTypeId: holderTypeId!,
        ownerRowId: ownerRowId,
        payoutScheduleId: payoutScheduleId!,
      ),
    );
  }
}
