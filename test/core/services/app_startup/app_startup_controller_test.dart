import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';

class _MockAppLaunchService extends Mock implements AppLaunchService {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

class _FakeConnectivityService implements ConnectivityService {
  _FakeConnectivityService({required NetworkStatus initialStatus})
      : _currentStatus = initialStatus;

  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();

  NetworkStatus _currentStatus;

  void emit(NetworkStatus status) {
    if (_currentStatus == status) return;
    _currentStatus = status;
    _controller.add(status);
  }

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  Stream<NetworkStatus> get networkStatusStream => _controller.stream;

  @override
  bool get isConnected => _currentStatus == NetworkStatus.online;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> checkConnectivity() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('AppStartupController hydration', () {
    setUpAll(() {
      registerFallbackValue(
        const UserEntity(id: 'fallback', email: 'fallback@example.com'),
      );
    });

    test(
      'retries hydration when connectivity becomes online after transient failure',
      () async {
        final appLaunch = _MockAppLaunchService();
        when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);
        when(() => appLaunch.markOnboardingSeen()).thenAnswer((_) async {});

        final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
        final sessionManager = _MockSessionManager();
        when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
        when(() => sessionManager.isAuthenticated).thenReturn(true);
        when(() => sessionManager.isAuthPending).thenReturn(true);
        when(
          () => sessionManager.logout(reason: any(named: 'reason')),
        ).thenAnswer((_) async {});
        when(() => sessionManager.setUser(any())).thenAnswer((_) async {});

        const user = UserEntity(id: 'u1', email: 'user@example.com');
        final getMe = _MockGetMeUseCase();
        var calls = 0;
        when(() => getMe()).thenAnswer((_) async {
          calls += 1;
          if (calls == 1) return left(const AuthFailure.network());
          return right(user);
        });

        final connectivity = _FakeConnectivityService(
          initialStatus: NetworkStatus.offline,
        );

        final controller = AppStartupController(
          appLaunch: appLaunch,
          connectivity: connectivity,
          sessionManager: sessionManager,
          getMe: getMe,
        );

        await controller.initialize();
        await pumpEventQueue();

        verifyNever(() => sessionManager.logout(reason: any(named: 'reason')));
        verifyNever(() => sessionManager.setUser(any()));
        expect(calls, 1);

        connectivity.emit(NetworkStatus.online);
        await pumpEventQueue();

        verify(() => sessionManager.setUser(user)).called(1);
        expect(calls, 2);

        controller.dispose();
        await connectivity.dispose();
        sessionNotifier.dispose();
      },
    );

    test('throttles rapid non-forced hydration attempts', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);
      when(() => appLaunch.markOnboardingSeen()).thenAnswer((_) async {});

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.isAuthenticated).thenReturn(true);
      when(() => sessionManager.isAuthPending).thenReturn(true);
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});

      final getMe = _MockGetMeUseCase();
      var calls = 0;
      when(() => getMe()).thenAnswer((_) async {
        calls += 1;
        return left(const AuthFailure.network());
      });

      final connectivity = _FakeConnectivityService(
        initialStatus: NetworkStatus.offline,
      );

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();
      await pumpEventQueue();
      expect(calls, 1);

      // Session changes should not re-trigger hydration immediately (cooldown).
      sessionNotifier.value = const AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
      );
      await pumpEventQueue();

      expect(calls, 1);

      controller.dispose();
      await connectivity.dispose();
      sessionNotifier.dispose();
    });
  });
}
