import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class PayoutScheduleId extends MerchantReferenceId {
  const PayoutScheduleId._(super.value);

  static Either<MerchantValidationFailure, PayoutScheduleId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleRequired,
          path: 'settlement.payoutScheduleId',
        ),
      );
    }
    if (!reference.payoutScheduleExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleUnsupported,
          path: 'settlement.payoutScheduleId',
        ),
      );
    }
    return right(PayoutScheduleId._(id));
  }
}
