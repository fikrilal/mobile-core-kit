import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/validation/validation_error_codes.dart';
part 'value_failure.freezed.dart';

@freezed
sealed class ValueFailure with _$ValueFailure {
  const factory ValueFailure.invalidEmail(String failedValue) = InvalidEmail;
  const factory ValueFailure.shortPassword(String failedValue) = ShortPassword;
  const factory ValueFailure.passwordsDoNotMatch(String failedValue) =
      PasswordsDoNotMatch;
  const factory ValueFailure.empty(String failedValue) = Empty;
  const factory ValueFailure.shortName(String failedValue) = ShortName;
  const factory ValueFailure.longName(String failedValue) = LongName;
}

extension ValueFailureX on ValueFailure {
  /// Stable, UI-agnostic error code for localization and telemetry.
  String get code => when(
    invalidEmail: (_) => ValidationErrorCodes.invalidEmail,
    shortPassword: (_) => ValidationErrorCodes.passwordTooShort,
    passwordsDoNotMatch: (_) => ValidationErrorCodes.passwordsDoNotMatch,
    empty: (_) => ValidationErrorCodes.required,
    shortName: (_) => ValidationErrorCodes.nameTooShort,
    longName: (_) => ValidationErrorCodes.nameTooLong,
  );
}
