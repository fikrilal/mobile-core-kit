import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';

class ResetToken {
  final String value;
  const ResetToken._(this.value);

  static Either<ValueFailure, ResetToken> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(input));
    }
    return right(ResetToken._(trimmed));
  }
}
