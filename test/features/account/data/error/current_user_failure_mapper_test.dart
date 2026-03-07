import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/account/data/error/current_user_failure_mapper.dart';

void main() {
  group('mapCurrentUserFailure', () {
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
        mapCurrentUserFailure(failure),
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

      expect(
        mapCurrentUserFailure(failure),
        const AuthFailure.unauthenticated(),
      );
    });

    test('maps RATE_LIMITED code to tooManyRequests', () {
      final failure = ApiFailure(
        message: 'Too many requests',
        statusCode: 429,
        code: ApiErrorCodes.rateLimited,
      );

      expect(
        mapCurrentUserFailure(failure),
        const AuthFailure.tooManyRequests(),
      );
    });

    test('maps IDEMPOTENCY_IN_PROGRESS code to unexpected(message)', () {
      final failure = ApiFailure(
        message: 'In progress',
        statusCode: 409,
        code: ApiErrorCodes.idempotencyInProgress,
      );

      expect(
        mapCurrentUserFailure(failure),
        const AuthFailure.unexpected(
          message: ApiErrorCodes.idempotencyInProgress,
        ),
      );
    });

    test('maps CONFLICT code to unexpected(message)', () {
      final failure = ApiFailure(
        message: 'Conflict',
        statusCode: 409,
        code: ApiErrorCodes.conflict,
      );

      expect(
        mapCurrentUserFailure(failure),
        const AuthFailure.unexpected(message: ApiErrorCodes.conflict),
      );
    });

    test('maps INTERNAL code to serverError', () {
      final failure = ApiFailure(
        message: 'Internal',
        statusCode: 500,
        code: ApiErrorCodes.internal,
      );

      expect(mapCurrentUserFailure(failure), const AuthFailure.serverError());
    });

    test('falls back to status codes when code is missing', () {
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: 401)),
        const AuthFailure.unauthenticated(),
      );
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: 409)),
        const AuthFailure.unexpected(message: ApiErrorCodes.conflict),
      );
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: 429)),
        const AuthFailure.tooManyRequests(),
      );
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: 500)),
        const AuthFailure.serverError(),
      );
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: -1)),
        const AuthFailure.network(),
      );
      expect(
        mapCurrentUserFailure(ApiFailure(message: 'no', statusCode: -2)),
        const AuthFailure.network(),
      );
    });

    test('maps unexpected status to unexpected() (fallback)', () {
      final failure = ApiFailure(message: 'weird', statusCode: 418);
      expect(mapCurrentUserFailure(failure), const AuthFailure.unexpected());
    });
  });
}
