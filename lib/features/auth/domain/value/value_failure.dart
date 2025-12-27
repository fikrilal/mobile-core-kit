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
    passwordsDoNotMatch: (_) => 'Passwords do not match',
    empty: (_) => 'This field cannot be empty',
    shortName: (_) => 'Must be at least 2 characters',
    longName: (_) => 'Cannot exceed 50 characters',
  );
}
