/// Raw current/new password input submitted to the change-password use case.
///
/// Values may be invalid. `PasswordChangeCredentials` owns the transition to
/// validated domain values before the repository boundary.
class ChangePasswordInput {
  const ChangePasswordInput({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}
