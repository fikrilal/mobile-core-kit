abstract class AppLaunchService {
  /// Returns true if user should see the first-time onboarding screen.
  /// Defaults to true on fresh installs (no stored flag).
  Future<bool> shouldShowOnboarding();

  /// Mark the first-time onboarding as seen so it won't show again.
  Future<void> markOnboardingSeen();
}
