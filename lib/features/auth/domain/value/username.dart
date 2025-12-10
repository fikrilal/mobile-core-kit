import 'package:fpdart/fpdart.dart';
import 'value_failure.dart';

/// Generic username value object that can be reused if a project
/// chooses to have usernames. Not wired into the core auth flow.
class Username {
  final String value;
  const Username._(this.value);

  static Either<ValueFailure, Username> create(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return left(ValueFailure.empty(input));
    }

    if (trimmed.length < 3) {
      return left(ValueFailure.shortUsername(input));
    }

    if (trimmed.length > 20) {
      return left(ValueFailure.longUsername(input));
    }

    final validFormat = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validFormat.hasMatch(trimmed)) {
      return left(ValueFailure.invalidUsernameFormat(input));
    }

    return right(Username._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Username && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
