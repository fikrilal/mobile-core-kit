import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_intent.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PendingDeepLinkStore', () {
    test('returns stored intent when within TTL', () async {
      SharedPreferences.setMockInitialValues({});

      final t0 = DateTime(2026, 1, 1, 0, 0);
      var now = t0;
      final store = PendingDeepLinkStore(
        prefs: SharedPreferences.getInstance(),
        ttl: const Duration(hours: 1),
        now: () => now,
      );

      await store.save(
        DeepLinkIntent(location: '/profile', receivedAt: t0, source: 'test'),
      );

      final loaded = await store.readValid();
      expect(loaded?.location, '/profile');
      expect(loaded?.source, 'test');

      now = t0.add(const Duration(minutes: 59));
      final loaded2 = await store.readValid();
      expect(loaded2?.location, '/profile');
    });

    test('expires and clears intent when TTL is reached', () async {
      SharedPreferences.setMockInitialValues({});

      final t0 = DateTime(2026, 1, 1, 0, 0);
      var now = t0;
      final store = PendingDeepLinkStore(
        prefs: SharedPreferences.getInstance(),
        ttl: const Duration(hours: 1),
        now: () => now,
      );

      await store.save(
        DeepLinkIntent(location: '/home', receivedAt: t0, source: 'test'),
      );

      now = t0.add(const Duration(hours: 1));
      final expired = await store.readValid();
      expect(expired, isNull);

      // Confirm it was cleared.
      final expiredAgain = await store.readValid();
      expect(expiredAgain, isNull);
    });
  });
}
