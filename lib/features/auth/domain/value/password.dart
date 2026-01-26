import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class Password {
  final String value;
  const Password._(this.value);

  static Either<ValueFailure, Password> create(String input) {
    if (input.trim().isEmpty) {
      return left(ValueFailure.empty(input));
    }
    // Backend policy: min length 10 (see `PasswordRegisterRequestDto`,
    // `ChangePasswordRequestDto`).
    if (input.length < 10) {
      return left(ValueFailure.shortPassword(input));
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
