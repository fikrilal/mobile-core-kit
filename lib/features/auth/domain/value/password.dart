import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

class Password {
  final String value;
  const Password._(this.value);

  static Either<ValueFailure, Password> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(input));
    }
    if (trimmed.length < 8) {
      return left(ValueFailure.shortPassword(input));
    }
    return right(Password._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Password && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
