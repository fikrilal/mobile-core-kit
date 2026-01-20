import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/navigation/app_redirect.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';
import 'package:mobile_core_kit/navigation/onboarding/onboarding_routes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAppLaunchService extends Mock implements AppLaunchService {}

class _MockConnectivityService extends Mock implements ConnectivityService {}

class _MockSessionManager extends Mock implements SessionManager {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

AppStartupController _startupNotReady() {
  final appLaunch = _MockAppLaunchService();

  final connectivity = _MockConnectivityService();
  when(
    () => connectivity.networkStatusStream,
  ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

  final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
  final sessionManager = _MockSessionManager();
  when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
  when(
    () => sessionManager.restoreCachedUserIfNeeded(),
  ).thenAnswer((_) async {});
  when(() => sessionManager.isAuthPending).thenReturn(false);
  when(() => sessionManager.isAuthenticated).thenReturn(false);

  final getMe = _MockGetMeUseCase();

  final controller = AppStartupController(
    appLaunch: appLaunch,
    connectivity: connectivity,
    sessionManager: sessionManager,
    getMe: getMe,
  );

  addTearDown(() {
    controller.dispose();
    sessionNotifier.dispose();
  });

  return controller;
}

Future<AppStartupController> _startup({
  required bool shouldShowOnboarding,
  required bool isAuthenticated,
}) async {
  final appLaunch = _MockAppLaunchService();
  when(
    () => appLaunch.shouldShowOnboarding(),
  ).thenAnswer((_) async => shouldShowOnboarding);

  final connectivity = _MockConnectivityService();
  when(
    () => connectivity.networkStatusStream,
  ).thenAnswer((_) => const Stream<NetworkStatus>.empty());

  final sessionNotifier = ValueNotifier<AuthSessionEntity?>(null);
  final sessionManager = _MockSessionManager();
  when(() => sessionManager.sessionNotifier).thenReturn(sessionNotifier);
  when(() => sessionManager.init()).thenAnswer((_) async {});
  when(
    () => sessionManager.restoreCachedUserIfNeeded(),
  ).thenAnswer((_) async {});
  when(() => sessionManager.isAuthPending).thenReturn(false);
  when(() => sessionManager.isAuthenticated).thenReturn(isAuthenticated);

  final getMe = _MockGetMeUseCase();

  final controller = AppStartupController(
    appLaunch: appLaunch,
    connectivity: connectivity,
    sessionManager: sessionManager,
    getMe: getMe,
    sessionInitTimeout: const Duration(milliseconds: 10),
    onboardingReadTimeout: const Duration(milliseconds: 10),
  );

  await controller.initialize();
  addTearDown(() {
    controller.dispose();
    sessionNotifier.dispose();
  });
  return controller;
}

PendingDeepLinkController _deepLinks() {
  SharedPreferences.setMockInitialValues({});

  final parser = DeepLinkParser();
  final store = PendingDeepLinkStore(
    prefs: SharedPreferences.getInstance(),
    ttl: const Duration(hours: 1),
    now: () => DateTime(2026, 1, 1),
  );

  return PendingDeepLinkController(
    store: store,
    parser: parser,
    now: () => DateTime(2026, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('appRedirectUri (deep link policy)', () {
    test('captures protected location during startup and redirects to /', () {
      final deepLinks = _deepLinks();
      final parser = DeepLinkParser();

      final startupNotReady = _startupNotReady();

      final redirect = appRedirectUri(
        Uri.parse('/profile'),
        startupNotReady,
        deepLinks,
        parser,
      );

      expect(redirect, AppRoutes.root);
      expect(deepLinks.pendingLocation, '/profile');
    });

    test('holds pending intent through onboarding and auth, then resumes', () async {
      final deepLinks = _deepLinks();
      final parser = DeepLinkParser();

      // Ready, onboarding required -> redirect to onboarding and keep pending.
      final startupOnboarding = await _startup(
        shouldShowOnboarding: true,
        isAuthenticated: false,
      );

      final r1 = appRedirectUri(
        Uri.parse('/profile'),
        startupOnboarding,
        deepLinks,
        parser,
      );
      expect(r1, OnboardingRoutes.onboarding);
      expect(deepLinks.pendingLocation, '/profile');

      // After onboarding complete (ready, no onboarding, still unauthenticated)
      final startupNeedsAuth = await _startup(
        shouldShowOnboarding: false,
        isAuthenticated: false,
      );

      final r2 = appRedirectUri(
        Uri.parse(AppRoutes.root),
        startupNeedsAuth,
        deepLinks,
        parser,
      );
      expect(r2, AuthRoutes.signIn);
      expect(deepLinks.pendingLocation, '/profile');

      // After login (ready, no onboarding, authenticated) from auth zone -> resume.
      final startupAuthed = await _startup(
        shouldShowOnboarding: false,
        isAuthenticated: true,
      );

      final r3 = appRedirectUri(
        Uri.parse(AuthRoutes.signIn),
        startupAuthed,
        deepLinks,
        parser,
      );
      expect(r3, '/profile');
      expect(deepLinks.pendingLocation, isNull);
    });

    test(
      'canonicalizes allowlisted https://orymu.com links to internal /path',
      () async {
        final deepLinks = _deepLinks();
        final parser = DeepLinkParser();

        final startupAuthed = await _startup(
          shouldShowOnboarding: false,
          isAuthenticated: true,
        );

        final redirect = appRedirectUri(
          Uri.parse('https://orymu.com/profile'),
          startupAuthed,
          deepLinks,
          parser,
        );

        expect(redirect, '/profile');
      },
    );

    test('rejects non-allowlisted https hosts (fail safe to /)', () async {
      final deepLinks = _deepLinks();
      final parser = DeepLinkParser();

      final startupAuthed = await _startup(
        shouldShowOnboarding: false,
        isAuthenticated: true,
      );

      final redirect = appRedirectUri(
        Uri.parse('https://evil.com/profile'),
        startupAuthed,
        deepLinks,
        parser,
      );

      expect(redirect, AppRoutes.root);
      expect(deepLinks.pendingLocation, isNull);
    });
  });
}
