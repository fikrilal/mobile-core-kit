import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';

/// Maps network-layer [ApiFailure] into auth-domain [AuthFailure] for user feature calls.
///
/// This mirrors the pattern used in `features/auth`:
/// keep repository implementations orchestration-only and extract failure mapping
/// into a dedicated file for readability + unit testing.
AuthFailure mapUserFailure(ApiFailure f) {
  final code = f.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.validationFailed:
        return AuthFailure.validation(f.validationErrors ?? const []);
      case ApiErrorCodes.unauthorized:
        return const AuthFailure.unauthenticated();
      case ApiErrorCodes.conflict:
      case ApiErrorCodes.idempotencyInProgress:
        return AuthFailure.unexpected(message: code);
      case ApiErrorCodes.internal:
        return const AuthFailure.serverError();
      case ApiErrorCodes.rateLimited:
        return const AuthFailure.tooManyRequests();
    }
  }

  switch (f.statusCode) {
    case 401:
      return const AuthFailure.unauthenticated();
    case 409:
      return const AuthFailure.unexpected(message: ApiErrorCodes.conflict);
    case 429:
      return const AuthFailure.tooManyRequests();
    case 500:
      return const AuthFailure.serverError();
    case -1:
    case -2:
      return const AuthFailure.network();
    default:
      return const AuthFailure.unexpected();
  }
}
