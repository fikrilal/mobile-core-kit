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
      case ApiErrorCodes.conflict:
        return AuthFailure.unexpected(message: failure.message);
      case AuthErrorCodes.invalidCredentials:
      case AuthErrorCodes.legacyInvalidCredentials:
        return const AuthFailure.invalidCredentials();
      case AuthErrorCodes.emailAlreadyExists:
        return const AuthFailure.emailTaken();
      case AuthErrorCodes.invalidRefreshToken:
      case AuthErrorCodes.refreshTokenInvalid:
      case AuthErrorCodes.refreshTokenExpired:
      case AuthErrorCodes.refreshTokenReused:
      case AuthErrorCodes.sessionRevoked:
        return const AuthFailure.unauthenticated();
      case AuthErrorCodes.emailNotVerified:
      case AuthErrorCodes.oidcEmailNotVerified:
        return const AuthFailure.emailNotVerified();
      case AuthErrorCodes.userSuspended:
        return AuthFailure.unexpected(message: failure.message);
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
    case -2:
      return const AuthFailure.network();
    default:
      if ((failure.statusCode ?? 0) >= 500) {
        return const AuthFailure.serverError();
      }
      return const AuthFailure.unexpected();
  }
}

/// Mapping for refresh token calls.
///
/// Backend contract:
/// - Refresh tokens rotate only on a successful 200 refresh.
/// - Refresh reuse detection is strict, so if the client cannot prove whether
///   the refresh succeeded (e.g., timeout/no response), it must fail closed and
///   force re-auth to avoid accidental reuse.
AuthFailure mapAuthFailureForRefresh(ApiFailure failure) {
  // Unknown outcome: the request may have been accepted but we did not receive a
  // response (e.g. receive timeout). Treat as session-fatal to avoid retrying a
  // potentially rotated refresh token.
  if (failure.statusCode == null || failure.statusCode == -2) {
    return const AuthFailure.unauthenticated();
  }
  return mapAuthFailure(failure);
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
      case AuthErrorCodes.legacyInvalidCredentials:
        return const AuthFailure.invalidCredentials();
      case AuthErrorCodes.emailNotVerified:
      case AuthErrorCodes.oidcEmailNotVerified:
        return const AuthFailure.emailNotVerified();
      case AuthErrorCodes.oidcTokenInvalid:
        return const AuthFailure.invalidCredentials();
      case AuthErrorCodes.userSuspended:
        return AuthFailure.unexpected(message: failure.message);
      case ApiErrorCodes.unauthorized:
        return const AuthFailure.invalidCredentials();
      case ApiErrorCodes.forbidden:
      case ApiErrorCodes.conflict:
      case ApiErrorCodes.internal:
        return AuthFailure.unexpected(message: failure.message);
      case ApiErrorCodes.rateLimited:
        return const AuthFailure.tooManyRequests();
    }
  }

  switch (failure.statusCode) {
    case 401:
      return const AuthFailure.invalidCredentials();
    case 403:
    case 409:
      return AuthFailure.unexpected(message: failure.message);
    case 400:
      return AuthFailure.validation(failure.validationErrors ?? const []);
    case 429:
      return const AuthFailure.tooManyRequests();
    case -1:
    case -2:
      return const AuthFailure.network();
    default:
      if ((failure.statusCode ?? 0) >= 500) {
        return const AuthFailure.serverError();
      }
      return const AuthFailure.unexpected();
  }
}
