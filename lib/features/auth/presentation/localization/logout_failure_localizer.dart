import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

String messageForLogoutFailure(LogoutFailure failure, AppLocalizations l10n) {
  return switch (failure) {
    LogoutFailure.failed => l10n.authErrorsLogoutFailed,
  };
}
