import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class EmailAddress {
  const EmailAddress._(this.value);

  final String value;

  static Either<MerchantValidationFailure, EmailAddress> create(
    String raw, {
    required String path,
    String emptyCode = MerchantValidationCodes.contactEmailRequired,
    String invalidCode = MerchantValidationCodes.contactEmailInvalid,
  }) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return left(MerchantValidationFailure(code: emptyCode, path: path));
    }
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(value)) {
      return left(MerchantValidationFailure(code: invalidCode, path: path));
    }
    return right(EmailAddress._(value));
  }
}
