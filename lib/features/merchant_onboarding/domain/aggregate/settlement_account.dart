import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/bank_account_holder_name.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/bank_account_number.dart';

class SettlementAccount {
  const SettlementAccount._({
    required this.bankId,
    required this.accountHolderName,
    required this.accountNumber,
    required this.holderTypeId,
    required this.ownerRowId,
    required this.payoutScheduleId,
  });

  final String bankId;
  final BankAccountHolderName accountHolderName;
  final BankAccountNumber accountNumber;
  final String holderTypeId;

  final String? ownerRowId;
  final String payoutScheduleId;

  static Either<List<MerchantValidationFailure>, SettlementAccount> create({
    required SettlementInput input,
    required MerchantReferenceDataEntity reference,
  }) {
    final errors = <MerchantValidationFailure>[];
    String? bankId;
    BankAccountHolderName? accountHolderName;
    BankAccountNumber? accountNumber;
    String? holderTypeId;
    String? ownerRowId;
    String? payoutScheduleId;

    final rawBankId = input.bankId?.trim() ?? '';
    if (rawBankId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankRequired,
          path: 'settlement.bankId',
        ),
      );
    } else if (reference.bankById(rawBankId) == null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankUnsupported,
          path: 'settlement.bankId',
        ),
      );
    } else {
      bankId = rawBankId;
    }

    BankAccountHolderName.create(
      input.accountHolderName,
    ).fold(errors.add, (v) => accountHolderName = v);

    BankAccountNumber.create(
      input.accountNumber,
    ).fold(errors.add, (v) => accountNumber = v);

    final rawHolderTypeId = input.holderTypeId?.trim() ?? '';
    if (rawHolderTypeId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeRequired,
          path: 'settlement.holderTypeId',
        ),
      );
    } else if (reference.holderTypeById(rawHolderTypeId) == null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeUnsupported,
          path: 'settlement.holderTypeId',
        ),
      );
    } else {
      holderTypeId = rawHolderTypeId;
    }

    final holderType = holderTypeId == null
        ? null
        : reference.holderTypeById(holderTypeId);
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
          ownerRowId = ownerRaw;
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

    final rawPayoutScheduleId = input.payoutScheduleId?.trim() ?? '';
    if (rawPayoutScheduleId.isEmpty) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleRequired,
          path: 'settlement.payoutScheduleId',
        ),
      );
    } else if (reference.payoutScheduleById(rawPayoutScheduleId) == null) {
      errors.add(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleUnsupported,
          path: 'settlement.payoutScheduleId',
        ),
      );
    } else {
      payoutScheduleId = rawPayoutScheduleId;
    }

    final bank = bankId == null ? null : reference.bankById(bankId);
    if (bank != null && payoutScheduleId != null) {
      if (!bank.supportedScheduleIds.contains(payoutScheduleId)) {
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
