import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';

class EmailAddress {
  final String value;
  const EmailAddress._(this.value);

  static Either<ValueFailure, EmailAddress> create(String input) {
    final trimmed = input.trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (regex.hasMatch(trimmed)) {
      return right(EmailAddress._(trimmed));
    } else {
      return left(ValueFailure.invalidEmail(input));
    }
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EmailAddress && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
