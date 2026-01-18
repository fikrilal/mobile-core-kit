import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

import 'validation_error.dart';
import 'validation_error_codes.dart';

/// Localizes a field-level [ValidationError] into user-facing copy.
///
/// Prefer mapping by stable `code`, and fall back to server-provided `message`.
String messageForValidationError(ValidationError error, AppLocalizations l10n) {
  final code = error.code?.toLowerCase();
  if (code != null) {
    switch (code) {
      case ValidationErrorCodes.invalidEmail:
        return l10n.validationInvalidEmail;
      case ValidationErrorCodes.required:
        return l10n.validationRequired;
      case ValidationErrorCodes.passwordTooShort:
      case ValidationErrorCodes.weakPassword:
        return l10n.validationPasswordTooShort;
      case ValidationErrorCodes.passwordsDoNotMatch:
        return l10n.validationPasswordsDoNotMatch;
      case ValidationErrorCodes.nameTooShort:
      case ValidationErrorCodes.invalidFirstName:
      case ValidationErrorCodes.invalidLastName:
        return l10n.validationNameTooShort;
      case ValidationErrorCodes.nameTooLong:
        return l10n.validationNameTooLong;
    }
  }

  if (error.message.isNotEmpty) return error.message;
  return l10n.errorsValidation;
}

