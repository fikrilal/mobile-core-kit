/// Raw email/password input submitted to the registration use case.
///
/// Values may be invalid. `RegistrationCredentials` owns the transition to
/// validated domain values before the repository boundary.
class RegisterInput {
  const RegisterInput({required this.email, required this.password});

  final String email;
  final String password;
}
