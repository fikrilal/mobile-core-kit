import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class GivenName {
  final String value;

  const GivenName._(this.value);

  static Either<ValueFailure, GivenName> create(String input) {
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

    return right(GivenName._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GivenName && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
