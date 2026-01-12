import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_error_codes.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_failure_mapper.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

void main() {
  group('mapAuthFailure', () {
    test('maps VALIDATION_FAILED code to validation', () {
      final failure = ApiFailure(
        message: 'Validation failed',
        statusCode: 400,
        code: ApiErrorCodes.validationFailed,
        validationErrors: const [
          ValidationError(field: 'email', message: 'Invalid email'),
        ],
      );

      expect(
        mapAuthFailure(failure),
        const AuthFailure.validation([
          ValidationError(field: 'email', message: 'Invalid email'),
        ]),
      );
    });

    test('prefers AUTH_INVALID_CREDENTIALS code over 401 status fallback', () {
      final failure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
        code: AuthErrorCodes.invalidCredentials,
      );

      expect(mapAuthFailure(failure), const AuthFailure.invalidCredentials());
    });

    test('maps legacy INVALID_CREDENTIALS to invalidCredentials', () {
      final failure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
        code: AuthErrorCodes.legacyInvalidCredentials,
      );

      expect(mapAuthFailure(failure), const AuthFailure.invalidCredentials());
    });

    test('maps AUTH_EMAIL_ALREADY_EXISTS to emailTaken', () {
      final failure = ApiFailure(
        message: 'Email already exists',
        statusCode: 409,
        code: AuthErrorCodes.emailAlreadyExists,
      );

      expect(mapAuthFailure(failure), const AuthFailure.emailTaken());
    });

    test('maps legacy INVALID_REFRESH_TOKEN to unauthenticated', () {
      final failure = ApiFailure(
        message: 'Invalid refresh token',
        statusCode: 401,
        code: AuthErrorCodes.invalidRefreshToken,
      );

      expect(mapAuthFailure(failure), const AuthFailure.unauthenticated());
    });

    test('maps AUTH_REFRESH_TOKEN_* codes to unauthenticated', () {
      const codes = [
        AuthErrorCodes.refreshTokenInvalid,
        AuthErrorCodes.refreshTokenExpired,
        AuthErrorCodes.refreshTokenReused,
        AuthErrorCodes.sessionRevoked,
      ];

      for (final code in codes) {
        final failure = ApiFailure(
          message: 'Refresh failed',
          statusCode: 401,
          code: code,
        );
        expect(mapAuthFailure(failure), const AuthFailure.unauthenticated());
      }
    });

    test('maps EMAIL_NOT_VERIFIED to emailNotVerified', () {
      final failure = ApiFailure(
        message: 'Email not verified',
        statusCode: 403,
        code: AuthErrorCodes.emailNotVerified,
      );

      expect(mapAuthFailure(failure), const AuthFailure.emailNotVerified());
    });

    test('maps RATE_LIMITED code to tooManyRequests', () {
      final failure = ApiFailure(
        message: 'Too many requests',
        statusCode: 429,
        code: ApiErrorCodes.rateLimited,
      );

      expect(mapAuthFailure(failure), const AuthFailure.tooManyRequests());
    });

    test('falls back to status codes when code is missing', () {
      expect(
        mapAuthFailure(ApiFailure(message: 'no', statusCode: 401)),
        const AuthFailure.unauthenticated(),
      );
      expect(
        mapAuthFailure(ApiFailure(message: 'no', statusCode: 429)),
        const AuthFailure.tooManyRequests(),
      );
      expect(
        mapAuthFailure(ApiFailure(message: 'no', statusCode: 409)),
        const AuthFailure.emailTaken(),
      );
      expect(
        mapAuthFailure(ApiFailure(message: 'no', statusCode: -1)),
        const AuthFailure.network(),
      );
      expect(
        mapAuthFailure(ApiFailure(message: 'no', statusCode: -2)),
        const AuthFailure.network(),
      );
    });

    test('maps 400/422 to validation failure with errors (fallback)', () {
      final failure = ApiFailure(
        message: 'Invalid payload',
        statusCode: 422,
        validationErrors: const [
          ValidationError(field: 'password', message: 'Too short'),
        ],
      );

      expect(
        mapAuthFailure(failure),
        const AuthFailure.validation([
          ValidationError(field: 'password', message: 'Too short'),
        ]),
      );
    });

    test('maps 5xx to serverError (fallback)', () {
      final failure = ApiFailure(message: 'Server exploded', statusCode: 503);
      expect(mapAuthFailure(failure), const AuthFailure.serverError());
    });

    test('maps unexpected status to unexpected() (fallback)', () {
      final failure = ApiFailure(message: 'weird', statusCode: 418);
      expect(mapAuthFailure(failure), const AuthFailure.unexpected());
    });
  });

  group('mapAuthFailureForRefresh', () {
    test('treats null statusCode as unauthenticated (fail closed)', () {
      final failure = ApiFailure(message: 'timeout/no response');
      expect(mapAuthFailureForRefresh(failure), const AuthFailure.unauthenticated());
    });

    test('does not treat offline (-1) as unauthenticated', () {
      final failure = ApiFailure(message: 'No internet connection', statusCode: -1);
      expect(mapAuthFailureForRefresh(failure), const AuthFailure.network());
    });

    test('treats timeout (-2) as unauthenticated (unknown outcome)', () {
      final failure = ApiFailure(message: 'Timeout', statusCode: -2);
      expect(mapAuthFailureForRefresh(failure), const AuthFailure.unauthenticated());
    });
  });

  group('mapAuthFailureForGoogle', () {
    test('maps 401 to invalidCredentials (fallback)', () {
      final failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      expect(
        mapAuthFailureForGoogle(failure),
        const AuthFailure.invalidCredentials(),
      );
    });

    test('maps UNAUTHORIZED code to invalidCredentials', () {
      final failure = ApiFailure(
        message: 'Unauthorized',
        statusCode: 401,
        code: ApiErrorCodes.unauthorized,
      );
      expect(
        mapAuthFailureForGoogle(failure),
        const AuthFailure.invalidCredentials(),
      );
    });

    test('maps INVALID_CREDENTIALS code to invalidCredentials', () {
      final failure = ApiFailure(
        message: 'Invalid token',
        statusCode: 401,
        code: AuthErrorCodes.invalidCredentials,
      );
      expect(
        mapAuthFailureForGoogle(failure),
        const AuthFailure.invalidCredentials(),
      );
    });
  });
}
