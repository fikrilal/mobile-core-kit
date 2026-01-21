import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';

part 'auth_failure.freezed.dart';

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.network() = _NetworkFailure;

  /// User intentionally cancelled a sign-in flow (e.g. dismiss Google account picker).
  const factory AuthFailure.cancelled() = _CancelledFailure;

  /// Session is missing/expired or the user is not authenticated.
  ///
  /// Use this for protected endpoints that return 401 (e.g. `GET /users/me`),
  /// not for login failures (use [invalidCredentials] instead).
  const factory AuthFailure.unauthenticated() = _UnauthenticatedFailure;
  const factory AuthFailure.emailTaken() = _EmailTakenFailure;
  const factory AuthFailure.emailNotVerified() = _EmailNotVerifiedFailure;
  const factory AuthFailure.validation(List<ValidationError> errors) =
      _ValidationFailure;
  // Login
  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.tooManyRequests() = _RateLimited;
  const factory AuthFailure.userSuspended() = _UserSuspendedFailure;
  const factory AuthFailure.serverError([String? message]) = _ServerError;
  const factory AuthFailure.unexpected({String? message}) = _UnexpectedFailure;
}
