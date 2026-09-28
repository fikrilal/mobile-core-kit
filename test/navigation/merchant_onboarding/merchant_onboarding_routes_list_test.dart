import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/navigation/merchant_onboarding/merchant_onboarding_routes.dart';
import 'package:mobile_core_kit/navigation/merchant_onboarding/merchant_onboarding_routes_list.dart';

void main() {
  test('merchant onboarding route list exposes the isolated demo route', () {
    expect(merchantOnboardingRoutes, hasLength(1));
    expect(merchantOnboardingRoutes.single.path, MerchantOnboardingRoutes.root);
  });
}
