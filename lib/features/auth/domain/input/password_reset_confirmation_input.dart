/// Raw reset-token/new-password input submitted to the reset-confirm use
/// case.
///
/// Values may be invalid. `PasswordResetCredentials` owns the transition to
/// validated domain values before the repository boundary.
class PasswordResetConfirmationInput {
  const PasswordResetConfirmationInput({
    required this.token,
    required this.newPassword,
  });

  final String token;
  final String newPassword;
}
