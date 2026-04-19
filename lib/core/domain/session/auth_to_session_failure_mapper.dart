import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';

SessionFailure mapAuthFailureToSessionFailure(AuthFailure failure) {
  return failure.when(
    network: () => const SessionFailure.network(),
    cancelled: () => const SessionFailure.unexpected(),
    unauthenticated: () => const SessionFailure.unauthenticated(),
    passwordNotSet: () => const SessionFailure.unexpected(),
    emailTaken: () => const SessionFailure.unexpected(),
    emailNotVerified: () => const SessionFailure.unexpected(),
    oidcLinkRequired: () => const SessionFailure.unexpected(),
    validation: (_) => const SessionFailure.unexpected(),
    invalidCredentials: () => const SessionFailure.unexpected(),
    tooManyRequests: () => const SessionFailure.tooManyRequests(),
    userSuspended: () => const SessionFailure.unexpected(),
    serverError: (message) => SessionFailure.serverError(message),
    unexpected: (message) => SessionFailure.unexpected(message),
  );
}
