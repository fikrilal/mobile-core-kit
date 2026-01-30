import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';

class LoginPassword {
  final String value;
  const LoginPassword._(this.value);

  static Either<ValueFailure, LoginPassword> create(String input) {
    if (input.trim().isEmpty) {
      return left(ValueFailure.empty(input));
    }
    return right(LoginPassword._(input));
  }
}
