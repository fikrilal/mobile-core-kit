import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

class ConfirmPassword {
  final String value;
  const ConfirmPassword._(this.value);

  static Either<ValueFailure, ConfirmPassword> create(
    String originalPassword,
    String confirmPassword,
  ) {
    final trimmed = confirmPassword.trim();

    // check if empty
    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(confirmPassword));
    }

    // check if passwords match
    if (trimmed != originalPassword) {
      return left(ValueFailure.passwordsDoNotMatch(confirmPassword));
    }

    return right(ConfirmPassword._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmPassword && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
