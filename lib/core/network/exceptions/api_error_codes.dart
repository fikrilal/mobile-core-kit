/// Centralized backend error codes (RFC7807 `code`) used across the app.
///
/// Prefer mapping by `ApiFailure.code` first, and fall back to HTTP status codes
/// for resilience (some backends might omit `code`).
class ApiErrorCodes {
  ApiErrorCodes._();

  /// Backend validation failed (field errors may be present).
  static const String validationFailed = 'VALIDATION_FAILED';

  /// Authentication/authorization failure.
  static const String unauthorized = 'UNAUTHORIZED';

  /// Rate-limit exceeded.
  static const String rateLimited = 'RATE_LIMITED';
}
