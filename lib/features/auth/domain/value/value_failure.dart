import 'package:freezed_annotation/freezed_annotation.dart';
part 'value_failure.freezed.dart';

@freezed
sealed class ValueFailure with _$ValueFailure {
  const factory ValueFailure.invalidEmail(String failedValue) = InvalidEmail;
  const factory ValueFailure.shortPassword(String failedValue) = ShortPassword;
  const factory ValueFailure.missingLowercase(String failedValue) =
      MissingLowercase;
  const factory ValueFailure.missingUppercase(String failedValue) =
      MissingUppercase;
  const factory ValueFailure.missingNumber(String failedValue) = MissingNumber;
  const factory ValueFailure.invalidUsername(String failedValue) =
      InvalidUsername;
  const factory ValueFailure.shortUsername(String failedValue) = ShortUsername;
  const factory ValueFailure.longUsername(String failedValue) = LongUsername;
  const factory ValueFailure.invalidUsernameFormat(String failedValue) =
      InvalidUsernameFormat;
  const factory ValueFailure.passwordsDoNotMatch(String failedValue) =
      PasswordsDoNotMatch;
  const factory ValueFailure.empty(String failedValue) = Empty;
  const factory ValueFailure.shortName(String failedValue) = ShortName;
  const factory ValueFailure.longName(String failedValue) = LongName;
}

extension ValueFailureX on ValueFailure {
  String get userMessage => when(
    invalidEmail: (_) => 'Please enter a valid email address',
    shortPassword: (_) => 'Password must be at least 8 characters',
    missingLowercase: (_) =>
        'Password must include at least one lowercase letter',
    missingUppercase: (_) =>
        'Password must include at least one uppercase letter',
    missingNumber: (_) => 'Password must include at least one number',
    invalidUsername: (_) => 'Username must be 3–20 characters',
    shortUsername: (_) => 'Username must be at least 3 characters',
    longUsername: (_) => 'Username must be less than 20 characters',
    invalidUsernameFormat: (_) =>
        'Username can only contain letters, numbers, and underscores',
    passwordsDoNotMatch: (_) => 'Passwords do not match',
    empty: (_) => 'This field cannot be empty',
    shortName: (_) => 'Display name must be at least 2 characters',
    longName: (_) => 'Display name cannot exceed 50 characters',
  );
}
