import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class OwnershipPercentage {
  const OwnershipPercentage._(this.basisPoints);

  final int basisPoints;

  double get asPercent => basisPoints / 100;

  static Either<MerchantValidationFailure, OwnershipPercentage> create(
    String raw, {
    required String path,
  }) {
    final value = raw.trim();
    if (value.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageRequired,
          path: path,
        ),
      );
    }

    final match = RegExp(r'^(\d{1,3})(\.(\d{1,2}))?$').firstMatch(value);
    if (match == null) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageInvalid,
          path: path,
        ),
      );
    }

    final whole = int.parse(match.group(1)!);
    final fraction = match.group(3) ?? '';
    final basisPoints = whole * 100 + int.parse(fraction.padRight(2, '0'));

    if (basisPoints < 1 || basisPoints > 10000) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerPercentageInvalid,
          path: path,
        ),
      );
    }

    return right(OwnershipPercentage._(basisPoints));
  }
}
