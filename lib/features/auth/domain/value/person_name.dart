import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

/// A human name field used for registration/profile (e.g., first/last name).
class PersonName {
  final String value;
  const PersonName._(this.value);

  static Either<ValueFailure, PersonName> create(String input) {
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

    return right(PersonName._(trimmed));
  }
}
