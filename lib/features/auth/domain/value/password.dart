import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

class Password {
  final String value;
  const Password._(this.value);

  static Either<ValueFailure, Password> create(String input) {
    if (input.length < 8) {
      return left(ValueFailure.shortPassword(input));
    }

    // Specific checks for clearer messages
    if (!RegExp(r'[a-z]').hasMatch(input)) {
      return left(ValueFailure.missingLowercase(input));
    }
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return left(ValueFailure.missingUppercase(input));
    }
    if (!RegExp(r'\d').hasMatch(input)) {
      return left(ValueFailure.missingNumber(input));
    }

    return right(Password._(input));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Password && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
