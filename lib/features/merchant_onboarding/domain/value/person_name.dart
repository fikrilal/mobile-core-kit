import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/trimmed_name_validator.dart';

class PersonName {
  const PersonName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, PersonName> create(
    String raw, {
    required String path,
  }) {
    final failure = validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.ownerNameRequired,
      invalidCode: MerchantValidationCodes.ownerNameInvalid,
      path: path,
    );
    if (failure != null) return left(failure);
    return right(PersonName._(raw.trim()));
  }
}
