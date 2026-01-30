import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/services/push/fcm_token_provider.dart';
import 'package:mobile_core_kit/core/services/push/push_error_codes.dart';
import 'package:mobile_core_kit/core/services/push/push_platform.dart';
import 'package:mobile_core_kit/core/services/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/services/push/push_token_sync_service.dart';
import 'package:mobile_core_kit/core/services/push/push_token_sync_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionManager extends Mock implements SessionManager {}

class _MockFcmTokenProvider extends Mock implements FcmTokenProvider {}

class _MockPushTokenRegistrar extends Mock implements PushTokenRegistrar {}

class _MockPushTokenSyncStore extends Mock implements PushTokenSyncStore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(PushPlatform.android);
  });

  group('PushTokenSyncService', () {
    late ValueNotifier<AuthSessionEntity?> sessionNotifier;
    late _MockSessionManager sessionManager;
    late _MockFcmTokenProvider tokenProvider;
    late _MockPushTokenRegistrar registrar;
    late _MockPushTokenSyncStore store;
    late StreamController<String> tokenRefreshController;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      sessionManager = _MockSessionManager();
      tokenProvider = _MockFcmTokenProvider();
      registrar = _MockPushTokenRegistrar();
      store = _MockPushTokenSyncStore();
      tokenRefreshController = StreamController<String>.broadcast();

      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(
        () => sessionManager.refreshToken,
      ).thenAnswer((_) => sessionNotifier.value?.tokens.refreshToken);

      when(
        () => tokenProvider.onTokenRefresh,
      ).thenAnswer((_) => tokenRefreshController.stream);

      when(
        () => store.readPushNotConfiguredUntil(),
      ).thenAnswer((_) async => null);
      when(() => store.clearPushNotConfiguredUntil()).thenAnswer((_) async {});
      when(
        () => store.isDeduped(
          sessionKey: any(named: 'sessionKey'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => store.writeLastSent(
          sessionKey: any(named: 'sessionKey'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => store.writePushNotConfiguredUntil(any()),
      ).thenAnswer((_) async {});
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await tokenRefreshController.close();
      sessionNotifier.dispose();
    });

    test('session active + token present → upserts once on init', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      when(() => tokenProvider.getToken()).thenAnswer((_) async => 'token1');
      when(
        () => registrar.upsert(
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(data: const ApiNoData()));

      final service = PushTokenSyncService(
        sessionManager: sessionManager,
        tokenProvider: tokenProvider,
        registrar: registrar,
        store: store,
        now: () => DateTime(2026, 1, 24),
      );

      await service.init();
      service.dispose();

      verify(
        () => registrar.upsert(platform: PushPlatform.android, token: 'token1'),
      ).called(1);
      verify(
        () => store.writeLastSent(sessionKey: 'rt1', token: 'token1'),
      ).called(1);
    });

    test('token refresh while session active → upserts', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      when(() => tokenProvider.getToken()).thenAnswer((_) async => 'token1');
      when(
        () => registrar.upsert(
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(data: const ApiNoData()));

      final service = PushTokenSyncService(
        sessionManager: sessionManager,
        tokenProvider: tokenProvider,
        registrar: registrar,
        store: store,
        now: () => DateTime(2026, 1, 24),
      );

      await service.init();

      clearInteractions(registrar);
      clearInteractions(store);

      tokenRefreshController.add('token2');
      await untilCalled(
        () => registrar.upsert(
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      );
      await pumpEventQueue();

      service.dispose();

      verify(
        () => registrar.upsert(platform: PushPlatform.android, token: 'token2'),
      ).called(1);
      verify(
        () => store.writeLastSent(sessionKey: 'rt1', token: 'token2'),
      ).called(1);
    });

    test('PUSH_NOT_CONFIGURED sets cooldown', () async {
      sessionNotifier.value = _session(refreshToken: 'rt1');

      final now = DateTime(2026, 1, 24, 10);
      when(() => tokenProvider.getToken()).thenAnswer((_) async => 'token1');
      when(
        () => registrar.upsert(
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      ).thenAnswer(
        (_) async => ApiResponse.error(
          code: PushErrorCodes.pushNotConfigured,
          statusCode: 501,
        ),
      );

      final service = PushTokenSyncService(
        sessionManager: sessionManager,
        tokenProvider: tokenProvider,
        registrar: registrar,
        store: store,
        now: () => now,
      );

      await service.init();
      service.dispose();

      verify(
        () => store.writePushNotConfiguredUntil(
          now.add(const Duration(hours: 24)),
        ),
      ).called(1);
      verifyNever(
        () => store.writeLastSent(sessionKey: 'rt1', token: 'token1'),
      );
    });
  });
}

AuthSessionEntity _session({required String refreshToken}) {
  return AuthSessionEntity(
    tokens: AuthTokensEntity(
      accessToken: 'at_$refreshToken',
      refreshToken: refreshToken,
      tokenType: 'Bearer',
      expiresIn: 3600,
      expiresAt: DateTime(2026, 1, 24),
    ),
  );
}
