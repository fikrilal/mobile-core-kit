import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';

class FamilyName {
  final String value;

  const FamilyName._(this.value);

  static Either<ValueFailure, FamilyName> create(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(input));
    }

    if (trimmed.length < 2) {
      return left(ValueFailure.shortName(input));
    }

    if (trimmed.length > 50) {
      return left(ValueFailure.longName(input));
    }

    return right(FamilyName._(trimmed));
  }

  static Either<ValueFailure, FamilyName?> createOptional(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return right(null);
    return create(input).map((v) => v);
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FamilyName && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
