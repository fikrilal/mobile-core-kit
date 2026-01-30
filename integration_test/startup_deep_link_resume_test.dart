import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_core_kit/core/design_system/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/infra/storage/prefs/navigation/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/platform/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/platform/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';
import 'package:mobile_core_kit/core/runtime/navigation/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_launch_service.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/navigation/app_redirect.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';
import 'package:mobile_core_kit/navigation/onboarding/onboarding_routes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilText(
    WidgetTester tester,
    String text, {
    Duration step = const Duration(milliseconds: 50),
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      await tester.pump(step);
      if (find.text(text).evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for text: $text');
  }

  testWidgets(
    'startup gate preserves deep link and resumes after onboarding + auth',
    (tester) async {
      final appLaunch = _FakeAppLaunchService();
      final connectivity = _FakeConnectivityService();
      final sessionRepo = _InMemorySessionRepository();
      final authRepo = _FakeAuthRepository();
      final userRepo = _FakeUserRepository();

      final tokenRefresher = _AuthRepositoryTokenRefresher(authRepo);
      final events = AppEventBus();
      final sessionManager = SessionManager(
        sessionRepo,
        tokenRefresher: tokenRefresher,
        events: events,
      );

      final currentUserFetcher = _UserRepositoryCurrentUserFetcher(userRepo);
      final startup = AppStartupController(
        appLaunch: appLaunch,
        connectivity: connectivity,
        sessionManager: sessionManager,
        currentUserFetcher: currentUserFetcher,
        sessionInitTimeout: const Duration(milliseconds: 50),
        onboardingReadTimeout: const Duration(milliseconds: 50),
      );

      final deepLinkStore = PendingDeepLinkStore();
      await deepLinkStore.clear();
      final deepLinks = PendingDeepLinkController(
        store: deepLinkStore,
        parser: DeepLinkParser(),
      );

      final router = GoRouter(
        initialLocation: AppRoutes.root,
        refreshListenable: Listenable.merge([startup, deepLinks]),
        redirect: (context, state) =>
            appRedirectUri(state.uri, startup, deepLinks, DeepLinkParser()),
        routes: [
          GoRoute(
            path: AppRoutes.root,
            builder: (context, state) => const _MarkerPage('ROOT'),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const _MarkerPage('HOME'),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const _MarkerPage('PROFILE'),
          ),
          GoRoute(
            path: OnboardingRoutes.onboarding,
            builder: (context, state) => const _MarkerPage('ONBOARDING'),
          ),
          GoRoute(
            path: AuthRoutes.signIn,
            builder: (context, state) => const _MarkerPage('SIGN_IN'),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => AppStartupGate(
            listenable: startup,
            isReady: () => startup.isReady,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ROOT'), findsOneWidget);
      expect(find.byType(ModalBarrier), findsAtLeastNWidgets(1));

      router.go('https://links.fikril.dev/profile');
      await tester.pump();

      expect(find.text('ROOT'), findsOneWidget);
      expect(deepLinks.pendingLocation, AppRoutes.profile);

      await startup.initialize();
      await pumpUntilText(tester, 'ONBOARDING');

      expect(find.text('ONBOARDING'), findsOneWidget);
      expect(deepLinks.pendingLocation, AppRoutes.profile);

      await startup.completeOnboarding();
      await pumpUntilText(tester, 'SIGN_IN');

      expect(find.text('SIGN_IN'), findsOneWidget);
      expect(deepLinks.pendingLocation, AppRoutes.profile);

      await sessionManager.login(
        AuthSessionEntity(
          tokens: const AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 3600,
          ),
          user: const UserEntity(
            id: 'u1',
            email: 'user@example.com',
            profile: UserProfileEntity(givenName: 'Test', familyName: 'User'),
          ),
        ),
      );
      await pumpUntilText(tester, 'PROFILE');

      expect(find.text('PROFILE'), findsOneWidget);
      expect(deepLinks.pendingLocation, isNull);
    },
  );
}

class _MarkerPage extends StatelessWidget {
  const _MarkerPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _FakeAppLaunchService implements AppLaunchService {
  bool _seen = false;

  @override
  Future<void> markOnboardingSeen() async {
    _seen = true;
  }

  @override
  Future<bool> shouldShowOnboarding() async => !_seen;
}

class _FakeConnectivityService implements ConnectivityService {
  final _controller = StreamController<NetworkStatus>.broadcast();

  @override
  NetworkStatus get currentStatus => NetworkStatus.online;

  @override
  bool get isConnected => true;

  @override
  Stream<NetworkStatus> get networkStatusStream => _controller.stream;

  @override
  Future<void> checkConnectivity() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> initialize() async {
    _controller.add(NetworkStatus.online);
  }
}

class _InMemorySessionRepository implements SessionRepository {
  AuthSessionEntity? _session;

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  Future<AuthSessionEntity?> loadSession() async => _session;

  @override
  Future<UserEntity?> loadCachedUser() async => _session?.user;

  @override
  Future<void> saveSession(AuthSessionEntity session) async {
    _session = session;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<AuthFailure, AuthSessionEntity>> signInWithGoogleOidc() async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> verifyEmail(
    VerifyEmailRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> resendEmailVerification() async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> login(
    LoginRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> logout(LogoutRequestEntity request) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, AuthTokensEntity>> refreshToken(
    RefreshRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> register(
    RegisterRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> changePassword(
    ChangePasswordRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> requestPasswordReset(
    PasswordResetRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, Unit>> confirmPasswordReset(
    PasswordResetConfirmRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<Either<AuthFailure, UserEntity>> getMe() async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, UserEntity>> patchMeProfile(
    PatchMeProfileRequestEntity request,
  ) async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }
}

SessionFailure _toSessionFailure(AuthFailure failure) {
  return failure.maybeWhen(
    network: () => const SessionFailure.network(),
    unauthenticated: () => const SessionFailure.unauthenticated(),
    tooManyRequests: () => const SessionFailure.tooManyRequests(),
    serverError: (message) => SessionFailure.serverError(message),
    orElse: () => const SessionFailure.unexpected(),
  );
}

class _AuthRepositoryTokenRefresher implements TokenRefresher {
  _AuthRepositoryTokenRefresher(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<SessionFailure, AuthTokensEntity>> refresh(
    String refreshToken,
  ) async {
    final result = await _repository.refreshToken(
      RefreshRequestEntity(refreshToken: refreshToken),
    );
    return result.mapLeft(_toSessionFailure);
  }
}

class _UserRepositoryCurrentUserFetcher implements CurrentUserFetcher {
  _UserRepositoryCurrentUserFetcher(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<SessionFailure, UserEntity>> fetch() async {
    final result = await _repository.getMe();
    return result.mapLeft(_toSessionFailure);
  }
}
