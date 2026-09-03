/// Endpoint constants for the merchant-onboarding feature (core API host).
///
/// Paths exclude the `/v1` prefix because the core host base URL already
/// carries it (see `BuildConfigValues._devHosts` / `_stagingHosts`).
class MerchantOnboardingEndpoint {
  MerchantOnboardingEndpoint._();

  static const String referenceData = '/merchant-onboarding/reference-data';
  static const String applications = '/merchant-onboarding/applications';
}
