import '../../../../../core/network/exceptions/api_error_codes.dart';
import '../../../../../core/network/exceptions/api_failure.dart';
import '../../domain/failure/auth_failure.dart';
import 'auth_error_codes.dart';

/// Maps network-layer [ApiFailure] into auth-domain [AuthFailure].
///
/// This template extracts the mapping into a dedicated file to keep repository
/// implementations orchestration-only and make the mapping easy to unit test.
///
/// If a feature is light, it is also fine to keep the mapping inline inside the
/// repository implementation to avoid extra indirection.
AuthFailure mapAuthFailure(ApiFailure failure) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.validationFailed:
        return AuthFailure.validation(failure.validationErrors ?? const []);
      case AuthErrorCodes.invalidCredentials:
        return const AuthFailure.invalidCredentials();
      case AuthErrorCodes.invalidRefreshToken:
        return const AuthFailure.unauthenticated();
      case AuthErrorCodes.emailNotVerified:
        return const AuthFailure.emailNotVerified();
      case ApiErrorCodes.unauthorized:
        return const AuthFailure.unauthenticated();
      case ApiErrorCodes.rateLimited:
        return const AuthFailure.tooManyRequests();
    }
  }

  switch (failure.statusCode) {
    case 401:
      return const AuthFailure.unauthenticated();
    case 429:
      return const AuthFailure.tooManyRequests();
    case 409:
      return const AuthFailure.emailTaken();
    case 422:
    case 400:
      return AuthFailure.validation(failure.validationErrors ?? const []);
    case -1:
      return const AuthFailure.network();
    default:
      if ((failure.statusCode ?? 0) >= 500) {
        return const AuthFailure.serverError();
      }
      return const AuthFailure.unexpected();
  }
}

/// Mapping for Google token exchange.
///
/// This endpoint often returns 401/UNAUTHORIZED for invalid/expired Google ID
/// tokens, which is closer to "invalid credentials" than "unauthenticated".
AuthFailure mapAuthFailureForGoogle(ApiFailure failure) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.validationFailed:
        return AuthFailure.validation(failure.validationErrors ?? const []);
      case AuthErrorCodes.invalidCredentials:
        return const AuthFailure.invalidCredentials();
      case AuthErrorCodes.emailNotVerified:
        return const AuthFailure.emailNotVerified();
      case ApiErrorCodes.unauthorized:
        return const AuthFailure.invalidCredentials();
      case ApiErrorCodes.rateLimited:
        return const AuthFailure.tooManyRequests();
    }
  }

  switch (failure.statusCode) {
    case 401:
      return const AuthFailure.invalidCredentials();
    case 400:
      return AuthFailure.validation(failure.validationErrors ?? const []);
    case 429:
      return const AuthFailure.tooManyRequests();
    case -1:
      return const AuthFailure.network();
    default:
      if ((failure.statusCode ?? 0) >= 500) {
        return const AuthFailure.serverError();
      }
      return const AuthFailure.unexpected();
  }
}
