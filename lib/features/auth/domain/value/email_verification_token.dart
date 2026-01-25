import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';

class EmailVerificationToken {
  final String value;
  const EmailVerificationToken._(this.value);

  static Either<ValueFailure, EmailVerificationToken> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return left(ValueFailure.empty(input));
    return right(EmailVerificationToken._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailVerificationToken && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

