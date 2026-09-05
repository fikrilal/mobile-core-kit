import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class IndustryId extends MerchantReferenceId {
  const IndustryId._(super.value);

  static Either<MerchantValidationFailure, IndustryId> create(
    String? raw,
    MerchantReferenceDataEntity reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryRequired,
          path: 'business.industryId',
        ),
      );
    }
    if (!reference.industryExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryUnsupported,
          path: 'business.industryId',
        ),
      );
    }
    return right(IndustryId._(id));
  }
}
