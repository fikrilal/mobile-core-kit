import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class TermsVersion {
  const TermsVersion._(this.value);

  final String value;

  static Either<MerchantValidationFailure, TermsVersion> create(
    String raw,
    MerchantReferenceDataEntity reference,
  ) {
    final value = raw.trim();
    if (value.isEmpty || value != reference.termsVersion) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.declarationsTermsVersionStale,
          path: 'declarations.termsVersion',
        ),
      );
    }
    return right(TermsVersion._(value));
  }
}
