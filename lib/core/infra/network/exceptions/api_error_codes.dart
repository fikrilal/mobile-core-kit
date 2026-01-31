/// Centralized backend error codes (RFC7807 `code`) used across the app.
///
/// Prefer mapping by `ApiFailure.code` first, and fall back to HTTP status codes
/// for resilience (some backends might omit `code`).
///
/// Backend source of truth: `backend-core-kit/docs/standards/error-codes.md`
class ApiErrorCodes {
  ApiErrorCodes._();

  /// Backend validation failed (field errors may be present).
  static const String validationFailed = 'VALIDATION_FAILED';

  /// Authentication/authorization failure.
  static const String unauthorized = 'UNAUTHORIZED';

  /// Authorization failure.
  static const String forbidden = 'FORBIDDEN';

  /// Resource not found.
  static const String notFound = 'NOT_FOUND';

  /// Conflict (e.g. duplicate resource).
  static const String conflict = 'CONFLICT';

  /// Idempotency key is currently being processed (safe retry may succeed later).
  static const String idempotencyInProgress = 'IDEMPOTENCY_IN_PROGRESS';

  /// Internal server error.
  static const String internal = 'INTERNAL';

  /// Rate-limit exceeded.
  static const String rateLimited = 'RATE_LIMITED';
}
