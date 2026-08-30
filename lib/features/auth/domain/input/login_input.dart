/// Raw email/password input submitted to the login use case.
///
/// Values may be invalid. `LoginCredentials` owns the transition to validated
/// domain values before the repository boundary.
class LoginInput {
  const LoginInput({required this.email, required this.password});

  final String email;
  final String password;
}
