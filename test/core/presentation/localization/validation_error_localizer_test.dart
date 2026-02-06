import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/presentation/localization/validation_error_localizer.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('messageForValidationError', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test('maps known codes for ${locale.toString()}', () async {
        final l10n = await AppLocalizations.delegate.load(locale);

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'email',
              message: '',
              code: ValidationErrorCodes.invalidEmail,
            ),
            l10n,
          ),
          l10n.validationInvalidEmail,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'any',
              message: '',
              code: ValidationErrorCodes.required,
            ),
            l10n,
          ),
          l10n.validationRequired,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'password',
              message: '',
              code: ValidationErrorCodes.passwordTooShort,
            ),
            l10n,
          ),
          l10n.validationPasswordTooShort,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'password',
              message: '',
              code: ValidationErrorCodes.passwordsDoNotMatch,
            ),
            l10n,
          ),
          l10n.validationPasswordsDoNotMatch,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'token',
              message: '',
              code: ValidationErrorCodes.passwordResetTokenInvalid,
            ),
            l10n,
          ),
          l10n.validationPasswordResetTokenInvalid,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'token',
              message: '',
              code: ValidationErrorCodes.passwordResetTokenExpired,
            ),
            l10n,
          ),
          l10n.validationPasswordResetTokenExpired,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'firstName',
              message: '',
              code: ValidationErrorCodes.nameTooShort,
            ),
            l10n,
          ),
          l10n.validationNameTooShort,
        );

        expect(
          messageForValidationError(
            const ValidationError(
              field: 'firstName',
              message: '',
              code: ValidationErrorCodes.nameTooLong,
            ),
            l10n,
          ),
          l10n.validationNameTooLong,
        );
      });
    }

    test('falls back to message when code is unknown', () async {
      const locale = Locale('en');
      final l10n = await AppLocalizations.delegate.load(locale);

      expect(
        messageForValidationError(
          const ValidationError(
            field: 'email',
            message: 'Backend says no',
            code: 'unknown_code',
          ),
          l10n,
        ),
        'Backend says no',
      );
    });

    test(
      'falls back to errorsValidation when both code and message are empty',
      () async {
        const locale = Locale('en');
        final l10n = await AppLocalizations.delegate.load(locale);

        expect(
          messageForValidationError(
            const ValidationError(field: 'email', message: '', code: 'unknown'),
            l10n,
          ),
          l10n.errorsValidation,
        );
      },
    );
  });
}
