import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/validation/validation_error.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.network() = _NetworkFailure;
  const factory AuthFailure.emailTaken() = _EmailTakenFailure;
  const factory AuthFailure.validation(List<ValidationError> errors) =
      _ValidationFailure;
  // Login
  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.tooManyRequests() = _RateLimited;
  const factory AuthFailure.serverError([String? message]) = _ServerError;
  const factory AuthFailure.unexpected({String? message}) = _UnexpectedFailure;
}

extension AuthFailureX on AuthFailure {
  /// Human-readable message for generic snackbars, dialogs, etc.
  String get userMessage => when(
    network: () => 'Please check your internet connection and try again.',
    emailTaken: () => 'Email already in use.',
    validation: (_) => 'Please fix the highlighted errors',
    invalidCredentials: () => 'Invalid email or password',
    tooManyRequests: () => 'Too many requests. Please try again later.',
    serverError: (message) =>
        message ?? 'Server error. Please try again later.',
    unexpected: (message) =>
        message ?? 'Something went wrong. Please try again.',
  );
}
