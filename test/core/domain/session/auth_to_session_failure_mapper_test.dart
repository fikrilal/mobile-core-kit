import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/auth_to_session_failure_mapper.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';

void main() {
  group('mapAuthFailureToSessionFailure', () {
    test('maps unauthenticated to unauthenticated', () {
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.unauthenticated()),
        const SessionFailure.unauthenticated(),
      );
    });

    test('maps tooManyRequests to tooManyRequests', () {
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.tooManyRequests()),
        const SessionFailure.tooManyRequests(),
      );
    });

    test('maps network to network', () {
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.network()),
        const SessionFailure.network(),
      );
    });

    test('maps serverError to serverError with message', () {
      expect(
        mapAuthFailureToSessionFailure(
          const AuthFailure.serverError('backend_down'),
        ),
        const SessionFailure.serverError('backend_down'),
      );
    });

    test('maps unexpected to unexpected with message', () {
      expect(
        mapAuthFailureToSessionFailure(
          const AuthFailure.unexpected(message: 'weird'),
        ),
        const SessionFailure.unexpected('weird'),
      );
    });

    test('maps all other auth failures to unexpected', () {
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.validation([])),
        const SessionFailure.unexpected(),
      );
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.emailNotVerified()),
        const SessionFailure.unexpected(),
      );
      expect(
        mapAuthFailureToSessionFailure(const AuthFailure.oidcLinkRequired()),
        const SessionFailure.unexpected(),
      );
    });
  });
}
