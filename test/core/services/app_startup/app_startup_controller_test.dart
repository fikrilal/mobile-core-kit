import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';

class _MockAppLaunchService extends Mock implements AppLaunchService {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

void main() {
  group('AppStartupController.initialize', () {
    test('fails open when SessionManager.init times out', () {
      fakeAsync((async) {
        final appLaunch = _MockAppLaunchService();
        when(() => appLaunch.shouldShowOnboarding()).thenAnswer((_) async => false);

        final connectivity = _MockConnectivityService();
        when(() => connectivity.networkStatusStream)
            .thenAnswer((_) => const Stream<NetworkStatus>.empty());

        final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
        final sessionManager = _MockSessionManager();
        when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
        when(() => sessionManager.isAuthPending).thenReturn(false);

        final initCompleter = Completer<void>();
        when(() => sessionManager.init()).thenAnswer((_) => initCompleter.future);

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
        when(() => appLaunch.shouldShowOnboarding())
            .thenAnswer((_) => onboardingCompleter.future);

        final connectivity = _MockConnectivityService();
        when(() => connectivity.networkStatusStream)
            .thenAnswer((_) => const Stream<NetworkStatus>.empty());

        final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
        final sessionManager = _MockSessionManager();
        when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
        when(() => sessionManager.isAuthPending).thenReturn(false);
        when(() => sessionManager.init()).thenAnswer((_) async {});

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
}
