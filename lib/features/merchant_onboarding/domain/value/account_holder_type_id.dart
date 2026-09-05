import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class AccountHolderTypeId extends MerchantReferenceId {
  const AccountHolderTypeId._(super.value);

  static Either<MerchantValidationFailure, AccountHolderTypeId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeRequired,
          path: 'settlement.holderTypeId',
        ),
      );
    }
    if (reference.holderTypeById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeUnsupported,
          path: 'settlement.holderTypeId',
        ),
      );
    }
    return right(AccountHolderTypeId._(id));
  }
}
