import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/merchant_reference_id.dart';

class OwnerRoleId extends MerchantReferenceId {
  const OwnerRoleId._(super.value);

  static Either<MerchantValidationFailure, OwnerRoleId> create(
    String? raw,
    MerchantReferenceDataEntity reference, {
    required String path,
  }) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerRoleRequired,
          path: path,
        ),
      );
    }
    if (reference.ownerRoleById(id) == null) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerRoleUnsupported,
          path: path,
        ),
      );
    }
    return right(OwnerRoleId._(id));
  }
}
