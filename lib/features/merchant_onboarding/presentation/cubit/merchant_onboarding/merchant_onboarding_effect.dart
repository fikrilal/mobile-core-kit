/// One-shot effects for the merchant-onboarding flow. Focus requests, discard
/// confirmation, route leaving, and success navigation are never durable
/// state flags.
sealed class MerchantOnboardingEffect {
  const MerchantOnboardingEffect();
}

final class MerchantFocusFieldEffect extends MerchantOnboardingEffect {
  const MerchantFocusFieldEffect(this.path);

  final String path;
}

final class MerchantConfirmDiscardEffect extends MerchantOnboardingEffect {
  const MerchantConfirmDiscardEffect();
}

final class MerchantLeaveEffect extends MerchantOnboardingEffect {
  const MerchantLeaveEffect();
}

final class MerchantSubmittedEffect extends MerchantOnboardingEffect {
  const MerchantSubmittedEffect(this.applicationId);

  final String applicationId;
}
