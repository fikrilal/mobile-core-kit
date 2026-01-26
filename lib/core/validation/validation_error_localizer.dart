import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

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
      case ValidationErrorCodes.passwordSameAsCurrent:
        return l10n.validationPasswordSameAsCurrent;
      case ValidationErrorCodes.passwordsDoNotMatch:
        return l10n.validationPasswordsDoNotMatch;
      case ValidationErrorCodes.currentPasswordInvalid:
        return l10n.validationCurrentPasswordInvalid;
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
