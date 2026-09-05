import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class BusinessTypeId extends MerchantReferenceId {
  const BusinessTypeId._(super.value);

  static Either<MerchantValidationFailure, BusinessTypeId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeRequired,
          path: 'business.businessTypeId',
        ),
      );
    }
    if (reference.businessTypeById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeUnsupported,
          path: 'business.businessTypeId',
        ),
      );
    }
    return right(BusinessTypeId._(id));
  }
}
