import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

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
