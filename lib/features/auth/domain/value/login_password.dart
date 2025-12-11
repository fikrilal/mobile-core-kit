import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

class LoginPassword {
  final String value;
  const LoginPassword._(this.value);

  static Either<ValueFailure, LoginPassword> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(input));
    }
    return right(LoginPassword._(trimmed));
  }
}
