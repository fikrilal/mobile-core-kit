import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

class PhoneNumber {
  const PhoneNumber._(this.value);

  final String value;

  static Either<MerchantValidationFailure, PhoneNumber> create(
    String raw, {
    required String path,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.contactPhoneRequired,
          path: path,
        ),
      );
    }

    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[\s\-().]'), '');
    final digitCount = hasPlus ? digits.length - 1 : digits.length;
    final allDigits = RegExp(r'^\+?\d+$').hasMatch(digits);
    final nationalNumber = hasPlus ? digits.substring(1) : digits;

    final hasCountryCode =
        digitCount >= 8 && digitCount <= 15 && !nationalNumber.startsWith('0');

    if (!allDigits || !hasCountryCode) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.contactPhoneInvalid,
          path: path,
        ),
      );
    }

    final value = hasPlus ? digits : '+$digits';
    return right(PhoneNumber._(value));
  }
}
