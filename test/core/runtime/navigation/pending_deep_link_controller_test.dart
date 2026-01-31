import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/navigation/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';
import 'package:mobile_core_kit/core/runtime/navigation/pending_deep_link_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PendingDeepLinkController', () {
    test('last intent wins', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = PendingDeepLinkController(
        store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
        parser: DeepLinkParser(),
        now: () => DateTime(2026, 1, 1),
      );

      await controller.setPendingLocation('/home', source: 'test');
      await controller.setPendingLocation('/profile', source: 'test');

      expect(controller.pendingLocation, '/profile');
    });

    test('consumePendingLocationForRedirect clears pending', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = PendingDeepLinkController(
        store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
        parser: DeepLinkParser(),
        now: () => DateTime(2026, 1, 1),
      );

      await controller.setPendingLocation('/profile', source: 'test');
      final consumed = controller.consumePendingLocationForRedirect();

      expect(consumed, '/profile');
      expect(controller.pendingLocation, isNull);
    });

    test(
      'setPendingFromExternalUri parses and stores allowlisted https intent',
      () async {
        SharedPreferences.setMockInitialValues({});

        final controller = PendingDeepLinkController(
          store: PendingDeepLinkStore(prefs: SharedPreferences.getInstance()),
          parser: DeepLinkParser(),
          now: () => DateTime(2026, 1, 1),
        );

        await controller.setPendingFromExternalUri(
          Uri.parse('https://links.fikril.dev/profile?tab=security'),
        );

        expect(controller.pendingLocation, '/profile?tab=security');
      },
    );
  });
}
