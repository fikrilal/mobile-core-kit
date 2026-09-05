import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class OwnerRowId {
  const OwnerRowId._(this.value);

  final String value;

  static Either<MerchantValidationFailure, OwnerRowId> create(
    String raw, {
    required String path,
  }) {
    final value = raw.trim();
    if (value.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownersRequired,
          path: path,
        ),
      );
    }
    return right(OwnerRowId._(value));
  }

  static OwnerRowId generate() {
    final values = List<int>.generate(16, (_) => _rowIdRandom.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return OwnerRowId._(
      '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}',
    );
  }

  static final Random _rowIdRandom = Random();
}
