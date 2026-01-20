import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppLaunchService extends Mock implements AppLaunchService {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UserEntity(id: 'id', email: 'email@example.com'));
  });

  group('AppStartupController.initialize', () {
    test('does not block on restoring cached user', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => true);

      final connectivity = _MockConnectivityService();
      when(
        () => connectivity.networkStatusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.init()).thenAnswer((_) async {});
      when(() => sessionManager.isAuthPending).thenReturn(false);

      final restoreCompleter = Completer<void>();
      when(
        () => sessionManager.restoreCachedUserIfNeeded(),
      ).thenAnswer((_) => restoreCompleter.future);

      final getMe = _MockGetMeUseCase();

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();
      expect(controller.isReady, true);

      controller.dispose();
      sessionNotifier.dispose();
    });

    test('fails open when SessionManager.init times out', () {
      fakeAsync((async) {
        final appLaunch = _MockAppLaunchService();
        when(
          () => appLaunch.shouldShowOnboarding(),
        ).thenAnswer((_) async => false);

        final connectivity = _MockConnectivityService();
        when(
          () => connectivity.networkStatusStream,
        ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

        final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
        final sessionManager = _MockSessionManager();
        when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
        when(() => sessionManager.isAuthPending).thenReturn(false);
        when(
          () => sessionManager.restoreCachedUserIfNeeded(),
        ).thenAnswer((_) async {});

        final initCompleter = Completer<void>();
        when(
          () => sessionManager.init(),
        ).thenAnswer((_) => initCompleter.future);

        final getMe = _MockGetMeUseCase();

        final controller = AppStartupController(
          appLaunch: appLaunch,
          connectivity: connectivity,
          sessionManager: sessionManager,
          getMe: getMe,
          sessionInitTimeout: const Duration(milliseconds: 10),
          onboardingReadTimeout: const Duration(milliseconds: 10),
        );

        var completed = false;
        controller.initialize().then((_) => completed = true);

        async.flushMicrotasks();
        expect(controller.status, AppStartupStatus.initializing);
        expect(completed, false);

        async.elapse(const Duration(milliseconds: 15));
        async.flushMicrotasks();

        expect(completed, true);
        expect(controller.isReady, true);
        expect(controller.shouldShowOnboarding, false);

        controller.dispose();
        sessionNotifier.dispose();
      });
    });

    test('fails open when shouldShowOnboarding times out', () {
      fakeAsync((async) {
        final appLaunch = _MockAppLaunchService();
        final onboardingCompleter = Completer<bool>();
        when(
          () => appLaunch.shouldShowOnboarding(),
        ).thenAnswer((_) => onboardingCompleter.future);

        final connectivity = _MockConnectivityService();
        when(
          () => connectivity.networkStatusStream,
        ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

        final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
        final sessionManager = _MockSessionManager();
        when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
        when(() => sessionManager.isAuthPending).thenReturn(false);
        when(() => sessionManager.init()).thenAnswer((_) async {});
        when(
          () => sessionManager.restoreCachedUserIfNeeded(),
        ).thenAnswer((_) async {});

        final getMe = _MockGetMeUseCase();

        final controller = AppStartupController(
          appLaunch: appLaunch,
          connectivity: connectivity,
          sessionManager: sessionManager,
          getMe: getMe,
          sessionInitTimeout: const Duration(milliseconds: 10),
          onboardingReadTimeout: const Duration(milliseconds: 10),
        );

        var completed = false;
        controller.initialize().then((_) => completed = true);

        async.flushMicrotasks();
        expect(controller.status, AppStartupStatus.initializing);
        expect(completed, false);

        async.elapse(const Duration(milliseconds: 15));
        async.flushMicrotasks();

        expect(completed, true);
        expect(controller.isReady, true);
        expect(controller.shouldShowOnboarding, true);

        controller.dispose();
        sessionNotifier.dispose();
      });
    });
  });

  group('AppStartupController hydration', () {
    test('does not call GetMe if cached user restoration resolves auth pending', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);

      final connectivity = _MockConnectivityService();
      when(
        () => connectivity.networkStatusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.init()).thenAnswer((_) async {});

      var isAuthPending = true;
      when(() => sessionManager.isAuthPending).thenAnswer((_) => isAuthPending);

      final restoreCompleter = Completer<void>();
      when(
        () => sessionManager.restoreCachedUserIfNeeded(),
      ).thenAnswer((_) => restoreCompleter.future);

      final getMe = _MockGetMeUseCase();

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();

      isAuthPending = false;
      restoreCompleter.complete();

      await Future<void>.delayed(Duration.zero);
      verifyNever(() => getMe());

      controller.dispose();
      sessionNotifier.dispose();
    });

    test('logs out when GetMe returns unauthenticated (session unchanged)', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);

      final connectivity = _MockConnectivityService();
      when(
        () => connectivity.networkStatusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.init()).thenAnswer((_) async {});
      when(() => sessionManager.isAuthPending).thenReturn(true);
      when(() => sessionManager.restoreCachedUserIfNeeded()).thenAnswer((_) async {});

      when(() => sessionManager.refreshToken).thenReturn('refresh_1');
      when(() => sessionManager.logout(reason: any(named: 'reason'))).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});

      final getMe = _MockGetMeUseCase();
      when(
        () => getMe(),
      ).thenAnswer((_) async => left(const AuthFailure.unauthenticated()));

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();
      await Future<void>.delayed(Duration.zero);

      verify(() => getMe()).called(1);
      verify(() => sessionManager.logout(reason: 'hydrate_unauthenticated')).called(1);
      verifyNever(() => sessionManager.setUser(any()));

      controller.dispose();
      sessionNotifier.dispose();
    });

    test('does not apply GetMe result if session is cleared mid-flight', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);

      final connectivity = _MockConnectivityService();
      when(
        () => connectivity.networkStatusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.init()).thenAnswer((_) async {});
      when(() => sessionManager.isAuthPending).thenReturn(true);
      when(() => sessionManager.restoreCachedUserIfNeeded()).thenAnswer((_) async {});
      when(() => sessionManager.logout(reason: any(named: 'reason'))).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});

      String? refreshToken = 'refresh_1';
      when(() => sessionManager.refreshToken).thenAnswer((_) => refreshToken);

      final getMeCompleter = Completer<Either<AuthFailure, UserEntity>>();
      final getMe = _MockGetMeUseCase();
      when(() => getMe()).thenAnswer((_) => getMeCompleter.future);

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();
      await Future<void>.delayed(Duration.zero);

      verify(() => getMe()).called(1);

      refreshToken = null;
      getMeCompleter.complete(
        right(const UserEntity(id: 'u1', email: 'user@example.com')),
      );

      await Future<void>.delayed(Duration.zero);

      verifyNever(() => sessionManager.setUser(any()));
      verifyNever(() => sessionManager.logout(reason: any(named: 'reason')));

      controller.dispose();
      sessionNotifier.dispose();
    });

    test('does not apply GetMe result if session switches mid-flight', () async {
      final appLaunch = _MockAppLaunchService();
      when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);

      final connectivity = _MockConnectivityService();
      when(
        () => connectivity.networkStatusStream,
      ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

      final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
      final sessionManager = _MockSessionManager();
      when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
      when(() => sessionManager.init()).thenAnswer((_) async {});
      when(() => sessionManager.isAuthPending).thenReturn(true);
      when(() => sessionManager.restoreCachedUserIfNeeded()).thenAnswer((_) async {});
      when(() => sessionManager.logout(reason: any(named: 'reason'))).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});

      String refreshToken = 'refresh_1';
      when(() => sessionManager.refreshToken).thenAnswer((_) => refreshToken);

      final getMeCompleter = Completer<Either<AuthFailure, UserEntity>>();
      final getMe = _MockGetMeUseCase();
      when(() => getMe()).thenAnswer((_) => getMeCompleter.future);

      final controller = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        getMe: getMe,
      );

      await controller.initialize();
      await Future<void>.delayed(Duration.zero);

      verify(() => getMe()).called(1);

      refreshToken = 'refresh_2';
      getMeCompleter.complete(
        right(const UserEntity(id: 'u_old', email: 'old@example.com')),
      );

      await Future<void>.delayed(Duration.zero);

      verifyNever(() => sessionManager.setUser(any()));
      verifyNever(() => sessionManager.logout(reason: any(named: 'reason')));

      controller.dispose();
      sessionNotifier.dispose();
    });
  });
}
