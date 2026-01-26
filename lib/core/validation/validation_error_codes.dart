abstract final class ValidationErrorCodes {
  static const invalidEmail = 'invalid_email';
  static const required = 'required';

  static const passwordTooShort = 'password_too_short';
  static const passwordSameAsCurrent = 'password_same_as_current';
  static const passwordsDoNotMatch = 'passwords_do_not_match';
  static const currentPasswordInvalid = 'current_password_invalid';

  static const passwordResetTokenInvalid = 'password_reset_token_invalid';
  static const passwordResetTokenExpired = 'password_reset_token_expired';

  static const nameTooShort = 'name_too_short';
  static const nameTooLong = 'name_too_long';

  // Legacy / backend-provided (best-effort support).
  static const weakPassword = 'weak_password';
  static const invalidFirstName = 'invalid_first_name';
  static const invalidLastName = 'invalid_last_name';
}
