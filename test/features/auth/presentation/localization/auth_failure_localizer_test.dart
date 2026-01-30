import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/logout_failure_localizer.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('auth localizers', () {
    test('messageForAuthFailure maps common failures', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageForAuthFailure(const AuthFailure.network(), l10n),
        l10n.errorsOffline,
      );
      expect(
        messageForAuthFailure(const AuthFailure.invalidCredentials(), l10n),
        l10n.authErrorsInvalidCredentials,
      );
      expect(
        messageForAuthFailure(const AuthFailure.emailTaken(), l10n),
        l10n.authErrorsEmailTaken,
      );
      expect(
        messageForAuthFailure(const AuthFailure.emailNotVerified(), l10n),
        l10n.authErrorsEmailNotVerified,
      );
      expect(
        messageForAuthFailure(const AuthFailure.tooManyRequests(), l10n),
        l10n.errorsTooManyRequests,
      );
      expect(
        messageForAuthFailure(const AuthFailure.userSuspended(), l10n),
        l10n.authErrorsUserSuspended,
      );
      expect(
        messageForAuthFailure(const AuthFailure.serverError(), l10n),
        l10n.errorsServer,
      );
      expect(
        messageForAuthFailure(const AuthFailure.unexpected(), l10n),
        l10n.errorsUnexpected,
      );
      expect(
        messageForAuthFailure(
          const AuthFailure.validation(<ValidationError>[]),
          l10n,
        ),
        l10n.errorsValidation,
      );
    });

    test('messageForAuthFieldError handles email_taken', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageForAuthFieldError(
          const ValidationError(
            field: 'email',
            message: '',
            code: 'email_taken',
          ),
          l10n,
        ),
        l10n.authErrorsEmailTaken,
      );
    });

    test('messageForLogoutFailure maps logout failures', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        messageForLogoutFailure(LogoutFailure.failed, l10n),
        l10n.authErrorsLogoutFailed,
      );
    });
  });
}
