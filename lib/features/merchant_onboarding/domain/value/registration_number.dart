import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class RegistrationNumber {
  const RegistrationNumber._(this.value);

  final String value;

  static Either<MerchantValidationFailure, RegistrationNumber> create(
    String raw,
  ) {
    final value = raw.trim().toUpperCase();
    if (value.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessRegistrationRequired,
          path: 'business.registrationNumber',
        ),
      );
    }
    if (!RegExp(r'^[A-Z0-9-]{4,30}$').hasMatch(value)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessRegistrationInvalid,
          path: 'business.registrationNumber',
        ),
      );
    }
    return right(RegistrationNumber._(value));
  }
}
