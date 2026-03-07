import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

const String _usersCannotDeleteLastAdmin = 'USERS_CANNOT_DELETE_LAST_ADMIN';

String messageForAccountDeletionFailure(
  AuthFailure failure,
  AppLocalizations l10n,
) {
  return failure.maybeWhen(
    unexpected: (code) {
      return switch (code) {
        _usersCannotDeleteLastAdmin => l10n.accountDeletionErrorLastAdmin,
        ApiErrorCodes.idempotencyInProgress =>
          l10n.accountDeletionErrorInProgress,
        ApiErrorCodes.conflict => l10n.accountDeletionErrorAlreadyRequested,
        _ => l10n.errorsUnexpected,
      };
    },
    orElse: () => messageForAuthFailure(failure, l10n),
  );
}
