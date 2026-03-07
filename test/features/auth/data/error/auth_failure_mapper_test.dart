import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_error_codes.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_failure_mapper.dart';

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

    test('maps AUTH_EMAIL_VERIFICATION_TOKEN_* codes to unexpected', () {
      const codes = [
        AuthErrorCodes.emailVerificationTokenInvalid,
        AuthErrorCodes.emailVerificationTokenExpired,
      ];

      for (final code in codes) {
        final failure = ApiFailure(
          message: 'Invalid/expired verification token',
          statusCode: 400,
          code: code,
        );

        expect(mapAuthFailure(failure), const AuthFailure.unexpected());
      }
    });

    test('maps AUTH_PASSWORD_NOT_SET to passwordNotSet', () {
      final failure = ApiFailure(
        message: 'Password not set',
        statusCode: 409,
        code: AuthErrorCodes.passwordNotSet,
      );

      expect(mapAuthFailure(failure), const AuthFailure.passwordNotSet());
    });

    test('maps AUTH_CURRENT_PASSWORD_INVALID to field validation', () {
      final failure = ApiFailure(
        message: 'Current password invalid',
        statusCode: 400,
        code: AuthErrorCodes.currentPasswordInvalid,
      );

      expect(
        mapAuthFailure(failure),
        const AuthFailure.validation([
          ValidationError(
            field: 'currentPassword',
            message: '',
            code: ValidationErrorCodes.currentPasswordInvalid,
          ),
        ]),
      );
    });

    test(
      'maps AUTH_PASSWORD_RESET_TOKEN_* codes to token field validation',
      () {
        const cases = [
          (
            AuthErrorCodes.passwordResetTokenInvalid,
            ValidationErrorCodes.passwordResetTokenInvalid,
          ),
          (
            AuthErrorCodes.passwordResetTokenExpired,
            ValidationErrorCodes.passwordResetTokenExpired,
          ),
        ];

        for (final (apiCode, validationCode) in cases) {
          final failure = ApiFailure(
            message: 'Reset token error',
            statusCode: 400,
            code: apiCode,
          );

          expect(
            mapAuthFailure(failure),
            AuthFailure.validation([
              ValidationError(
                field: 'token',
                message: 'Reset token error',
                code: validationCode,
              ),
            ]),
          );
        }
      },
    );

    test('maps RATE_LIMITED code to tooManyRequests', () {
      final failure = ApiFailure(
        message: 'Too many requests',
        statusCode: 429,
        code: ApiErrorCodes.rateLimited,
      );

      expect(mapAuthFailure(failure), const AuthFailure.tooManyRequests());
    });

    test('maps CONFLICT code to unexpected(message)', () {
      final failure = ApiFailure(
        message: 'Conflict',
        statusCode: 409,
        code: ApiErrorCodes.conflict,
      );

      expect(
        mapAuthFailure(failure),
        const AuthFailure.unexpected(message: ApiErrorCodes.conflict),
      );
    });

    test('maps IDEMPOTENCY_IN_PROGRESS code to unexpected(message)', () {
      final failure = ApiFailure(
        message: 'In progress',
        statusCode: 409,
        code: ApiErrorCodes.idempotencyInProgress,
      );

      expect(
        mapAuthFailure(failure),
        const AuthFailure.unexpected(
          message: ApiErrorCodes.idempotencyInProgress,
        ),
      );
    });

    test('maps INTERNAL code to serverError', () {
      final failure = ApiFailure(
        message: 'Internal',
        statusCode: 500,
        code: ApiErrorCodes.internal,
      );

      expect(mapAuthFailure(failure), const AuthFailure.serverError());
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
        const AuthFailure.unexpected(message: ApiErrorCodes.conflict),
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
      expect(
        mapAuthFailureForRefresh(failure),
        const AuthFailure.unauthenticated(),
      );
    });

    test('does not treat offline (-1) as unauthenticated', () {
      final failure = ApiFailure(
        message: 'No internet connection',
        statusCode: -1,
      );
      expect(mapAuthFailureForRefresh(failure), const AuthFailure.network());
    });

    test('treats timeout (-2) as unauthenticated (unknown outcome)', () {
      final failure = ApiFailure(message: 'Timeout', statusCode: -2);
      expect(
        mapAuthFailureForRefresh(failure),
        const AuthFailure.unauthenticated(),
      );
    });
  });

  group('mapAuthFailureForOidcExchange', () {
    test('maps 401 to invalidCredentials (fallback)', () {
      final failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      expect(
        mapAuthFailureForOidcExchange(failure),
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
        mapAuthFailureForOidcExchange(failure),
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
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.invalidCredentials(),
      );
    });

    test('maps AUTH_OIDC_LINK_REQUIRED to oidcLinkRequired', () {
      final failure = ApiFailure(
        message: 'Link required',
        statusCode: 409,
        code: AuthErrorCodes.oidcLinkRequired,
      );
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.oidcLinkRequired(),
      );
    });

    test('maps CONFLICT code to oidcLinkRequired', () {
      final failure = ApiFailure(
        message: 'Conflict',
        statusCode: 409,
        code: ApiErrorCodes.conflict,
      );
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.oidcLinkRequired(),
      );
    });

    test('maps 409 fallback to oidcLinkRequired', () {
      final failure = ApiFailure(message: 'Conflict', statusCode: 409);
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.oidcLinkRequired(),
      );
    });

    test('maps AUTH_USER_SUSPENDED to userSuspended', () {
      final failure = ApiFailure(
        message: 'Suspended',
        statusCode: 403,
        code: AuthErrorCodes.userSuspended,
      );
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.userSuspended(),
      );
    });

    test('maps FORBIDDEN code to userSuspended for OIDC exchange', () {
      final failure = ApiFailure(
        message: 'Forbidden',
        statusCode: 403,
        code: ApiErrorCodes.forbidden,
      );
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.userSuspended(),
      );
    });

    test('maps 403 fallback to userSuspended for OIDC exchange', () {
      final failure = ApiFailure(message: 'Forbidden', statusCode: 403);
      expect(
        mapAuthFailureForOidcExchange(failure),
        const AuthFailure.userSuspended(),
      );
    });
  });
}
