abstract final class ValidationErrorCodes {
  static const invalidEmail = 'invalid_email';
  static const required = 'required';

  static const passwordTooShort = 'password_too_short';
  static const passwordsDoNotMatch = 'passwords_do_not_match';

  static const nameTooShort = 'name_too_short';
  static const nameTooLong = 'name_too_long';

  // Legacy / backend-provided (best-effort support).
  static const weakPassword = 'weak_password';
  static const invalidFirstName = 'invalid_first_name';
  static const invalidLastName = 'invalid_last_name';
}

