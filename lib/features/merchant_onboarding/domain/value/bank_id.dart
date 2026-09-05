import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class BankId extends MerchantReferenceId {
  const BankId._(super.value);

  static Either<MerchantValidationFailure, BankId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankRequired,
          path: 'settlement.bankId',
        ),
      );
    }
    if (reference.bankById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankUnsupported,
          path: 'settlement.bankId',
        ),
      );
    }
    return right(BankId._(id));
  }
}
