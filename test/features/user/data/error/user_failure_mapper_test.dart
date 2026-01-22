import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/error/user_failure_mapper.dart';

void main() {
  group('mapUserFailure', () {
    test('maps VALIDATION_FAILED code to validation', () {
      final failure = ApiFailure(
        message: 'Validation failed',
        statusCode: 400,
        code: ApiErrorCodes.validationFailed,
        validationErrors: const [
          ValidationError(field: 'profile.givenName', message: 'Required'),
        ],
      );

      expect(
        mapUserFailure(failure),
        const AuthFailure.validation([
          ValidationError(field: 'profile.givenName', message: 'Required'),
        ]),
      );
    });

    test('maps UNAUTHORIZED code to unauthenticated', () {
      final failure = ApiFailure(
        message: 'Unauthorized',
        statusCode: 401,
        code: ApiErrorCodes.unauthorized,
      );

      expect(mapUserFailure(failure), const AuthFailure.unauthenticated());
    });

    test('maps RATE_LIMITED code to tooManyRequests', () {
      final failure = ApiFailure(
        message: 'Too many requests',
        statusCode: 429,
        code: ApiErrorCodes.rateLimited,
      );

      expect(mapUserFailure(failure), const AuthFailure.tooManyRequests());
    });

    test('falls back to status codes when code is missing', () {
      expect(
        mapUserFailure(ApiFailure(message: 'no', statusCode: 401)),
        const AuthFailure.unauthenticated(),
      );
      expect(
        mapUserFailure(ApiFailure(message: 'no', statusCode: 429)),
        const AuthFailure.tooManyRequests(),
      );
      expect(
        mapUserFailure(ApiFailure(message: 'no', statusCode: 500)),
        const AuthFailure.serverError(),
      );
      expect(
        mapUserFailure(ApiFailure(message: 'no', statusCode: -1)),
        const AuthFailure.network(),
      );
      expect(
        mapUserFailure(ApiFailure(message: 'no', statusCode: -2)),
        const AuthFailure.network(),
      );
    });

    test('maps unexpected status to unexpected() (fallback)', () {
      final failure = ApiFailure(message: 'weird', statusCode: 418);
      expect(mapUserFailure(failure), const AuthFailure.unexpected());
    });
  });
}
