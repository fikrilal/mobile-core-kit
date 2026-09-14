import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/trimmed_name_validator.dart';

class LegalBusinessName {
  const LegalBusinessName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, LegalBusinessName> create(
    String raw,
  ) {
    final failure = validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.businessLegalNameRequired,
      invalidCode: MerchantValidationCodes.businessLegalNameInvalid,
      path: 'business.legalName',
    );
    if (failure != null) return left(failure);
    return right(LegalBusinessName._(raw.trim()));
  }
}
