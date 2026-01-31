import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/push/push_token_sync_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushTokenSyncStore', () {
    test('stores hashes only for lastSent', () async {
      SharedPreferences.setMockInitialValues({});

      final store = PushTokenSyncStore(prefs: SharedPreferences.getInstance());

      await store.writeLastSent(sessionKey: 'rt1', token: 'token_abc');

      final sessionHash = await store.readLastSentSessionHash();
      final tokenHash = await store.readLastSentTokenHash();

      expect(sessionHash, isNotNull);
      expect(tokenHash, isNotNull);
      expect(sessionHash, isNot('rt1'));
      expect(tokenHash, isNot('token_abc'));

      final hex64 = RegExp(r'^[0-9a-f]{16}$');
      expect(hex64.hasMatch(sessionHash!), true);
      expect(hex64.hasMatch(tokenHash!), true);
    });

    test('dedupes when session+token match lastSent', () async {
      SharedPreferences.setMockInitialValues({});

      final store = PushTokenSyncStore(prefs: SharedPreferences.getInstance());

      await store.writeLastSent(sessionKey: 'rt1', token: 't1');

      expect(await store.isDeduped(sessionKey: 'rt1', token: 't1'), true);
      expect(await store.isDeduped(sessionKey: 'rt1', token: 't2'), false);
      expect(await store.isDeduped(sessionKey: 'rt2', token: 't1'), false);
    });

    test('clears lastSent hashes', () async {
      SharedPreferences.setMockInitialValues({});

      final store = PushTokenSyncStore(prefs: SharedPreferences.getInstance());

      await store.writeLastSent(sessionKey: 'rt1', token: 't1');
      await store.clearLastSent();

      expect(await store.readLastSentSessionHash(), isNull);
      expect(await store.readLastSentTokenHash(), isNull);
    });

    test('writes and clears pushNotConfiguredUntil', () async {
      SharedPreferences.setMockInitialValues({});

      final store = PushTokenSyncStore(prefs: SharedPreferences.getInstance());

      final until = DateTime(2026, 1, 24, 10);
      await store.writePushNotConfiguredUntil(until);

      expect(await store.readPushNotConfiguredUntil(), until);

      await store.clearPushNotConfiguredUntil();
      expect(await store.readPushNotConfiguredUntil(), isNull);
    });
  });
}
