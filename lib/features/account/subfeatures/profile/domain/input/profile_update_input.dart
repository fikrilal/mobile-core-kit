/// Raw profile form input submitted to the patch-me use case.
///
/// Values may be invalid. `ProfileDetails` owns the transition to validated
/// domain values before the repository boundary.
class ProfileUpdateInput {
  const ProfileUpdateInput({
    required this.givenName,
    this.familyName,
    this.displayName,
  });

  final String givenName;
  final String? familyName;
  final String? displayName;
}
