import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// Localizes network-layer [ApiFailure] into safe, user-friendly copy.
///
/// Notes:
/// - Prefer mapping by RFC7807 `code` (more stable), fall back to HTTP status.
/// - Avoid surfacing raw backend `message` by default (may be unlocalized or
///   contain implementation details).
String messageFor(ApiFailure failure, AppLocalizations l10n) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.validationFailed:
        return l10n.errorsValidation;
      case ApiErrorCodes.unauthorized:
        return l10n.errorsUnauthenticated;
      case ApiErrorCodes.forbidden:
        return l10n.errorsForbidden;
      case ApiErrorCodes.rateLimited:
        return l10n.errorsTooManyRequests;
      case ApiErrorCodes.internal:
        return l10n.errorsServer;
      case ApiErrorCodes.conflict:
        // Conflict is feature-specific; keep it generic at the core level.
        return l10n.errorsUnexpected;
    }
  }

  final statusCode = failure.statusCode;
  switch (statusCode) {
    case -1:
      return l10n.errorsOffline;
    case -2:
      return l10n.errorsTimeout;
    case 400:
    case 422:
      return (failure.validationErrors?.isNotEmpty ?? false)
          ? l10n.errorsValidation
          : l10n.errorsUnexpected;
    case 401:
      return l10n.errorsUnauthenticated;
    case 403:
      return l10n.errorsForbidden;
    case 429:
      return l10n.errorsTooManyRequests;
    default:
      if ((statusCode ?? 0) >= 500) return l10n.errorsServer;
      return l10n.errorsUnexpected;
  }
}
