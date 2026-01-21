import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_localizer.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// User-facing localization for the auth feature.
///
/// Note: [AuthFailure.serverError] / [AuthFailure.unexpected] may carry an
/// optional message payload (typically raw backend text). This template does
/// not surface that payload in UI by default; prefer mapping to typed failures
/// and localizable error codes instead.
String messageForAuthFailure(AuthFailure failure, AppLocalizations l10n) {
  return failure.when(
    network: () => l10n.errorsOffline,
    cancelled: () => l10n.errorsUnexpected,
    unauthenticated: () => l10n.errorsUnauthenticated,
    emailTaken: () => l10n.authErrorsEmailTaken,
    emailNotVerified: () => l10n.authErrorsEmailNotVerified,
    validation: (_) => l10n.errorsValidation,
    invalidCredentials: () => l10n.authErrorsInvalidCredentials,
    tooManyRequests: () => l10n.errorsTooManyRequests,
    userSuspended: () => l10n.authErrorsUserSuspended,
    serverError: (_) => l10n.errorsServer,
    unexpected: (_) => l10n.errorsUnexpected,
  );
}

String messageForAuthFieldError(ValidationError error, AppLocalizations l10n) {
  final code = error.code?.toLowerCase();
  if (code == 'email_taken') return l10n.authErrorsEmailTaken;
  return messageForValidationError(error, l10n);
}

String messageForLogoutFailure(LogoutFailure failure, AppLocalizations l10n) {
  return switch (failure) {
    LogoutFailure.failed => l10n.authErrorsLogoutFailed,
  };
}
