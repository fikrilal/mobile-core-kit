import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class MonthlySalesRangeId extends MerchantReferenceId {
  const MonthlySalesRangeId._(super.value);

  static Either<MerchantValidationFailure, MonthlySalesRangeId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeRequired,
          path: 'business.monthlySalesRangeId',
        ),
      );
    }
    if (!reference.monthlySalesRangeExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeUnsupported,
          path: 'business.monthlySalesRangeId',
        ),
      );
    }
    return right(MonthlySalesRangeId._(id));
  }
}
