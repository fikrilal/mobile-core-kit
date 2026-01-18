import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_service.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/services/app_launch/app_launch_service.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/connectivity/connectivity_service.dart';
import 'package:mobile_core_kit/core/services/connectivity/network_status.dart';
import 'package:mobile_core_kit/core/services/deep_link/deep_link_parser.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_store.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/refresh_token_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/navigation/app_redirect.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth happy path: sign in navigates to home', (tester) async {
    final appLaunch = _FakeAppLaunchService(onboardingSeen: true);
    final connectivity = _FakeConnectivityService();
    final sessionRepo = _InMemorySessionRepository();
    final authRepo = _FakeAuthRepository();
    final userRepo = _FakeUserRepository();
    final analytics = AnalyticsTracker(_NoopAnalyticsService());

    final refreshUsecase = RefreshTokenUsecase(authRepo);
    final events = AppEventBus();
    final sessionManager = SessionManager(
      sessionRepo,
      refreshUsecase: refreshUsecase,
      events: events,
    );

    final getMe = GetMeUseCase(userRepo);
    final startup = AppStartupController(
      appLaunch: appLaunch,
      connectivity: connectivity,
      sessionManager: sessionManager,
      getMe: getMe,
      sessionInitTimeout: const Duration(milliseconds: 50),
      onboardingReadTimeout: const Duration(milliseconds: 50),
    );

    final deepLinks = PendingDeepLinkController(
      store: PendingDeepLinkStore(),
      parser: DeepLinkParser(),
    );

    // Ensure startup is ready before first frame so the gate doesn't block
    // interaction during this test.
    await startup.initialize();

    final loginUseCase = LoginUserUseCase(authRepo);
    final googleUseCase = GoogleSignInUseCase(authRepo);

    final router = GoRouter(
      initialLocation: AppRoutes.root,
      refreshListenable: Listenable.merge([startup, deepLinks]),
      redirect: (context, state) =>
          appRedirectUri(state.uri, startup, deepLinks, DeepLinkParser()),
      routes: [
        GoRoute(
          path: AppRoutes.root,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _MarkerPage('HOME'),
        ),
        GoRoute(
          path: AuthRoutes.signIn,
          builder: (context, state) => BlocProvider<LoginCubit>(
            create: (_) => LoginCubit(
              loginUseCase,
              googleUseCase,
              sessionManager,
              analytics,
            ),
            child: const SignInPage(),
          ),
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

    await tester.pumpAndSettle();

    // Redirect should land us on sign-in when unauthenticated.
    expect(find.text('Sign In'), findsWidgets);

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.pump();

    await tester.tap(find.text('Sign In').first);
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(sessionManager.isAuthenticated, isTrue);
  });
}

class _MarkerPage extends StatelessWidget {
  const _MarkerPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

class _NoopAnalyticsService implements IAnalyticsService {
  var _enabled = false;

  @override
  Future<void> clearUser() async {}

  @override
  Future<void> initialize() async {}

  @override
  bool isAnalyticsCollectionEnabled() => _enabled;

  @override
  Future<void> logEvent(
    String eventName, {
    Map<String, Object?>? parameters,
  }) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    String? previousScreenName,
    Map<String, Object?>? parameters,
  }) async {}

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;
  }

  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> setUserProperty(
    String propertyName,
    String propertyValue,
  ) async {}
}

class _FakeAppLaunchService implements AppLaunchService {
  _FakeAppLaunchService({required bool onboardingSeen})
    : _onboardingSeen = onboardingSeen;

  bool _onboardingSeen;

  @override
  Future<void> markOnboardingSeen() async {
    _onboardingSeen = true;
  }

  @override
  Future<bool> shouldShowOnboarding() async => !_onboardingSeen;
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
  Future<Either<AuthFailure, AuthSessionEntity>> googleSignIn() async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> login(
    LoginRequestEntity request,
  ) async {
    return right(
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
          firstName: 'Test',
          lastName: 'User',
        ),
      ),
    );
  }

  @override
  Future<Either<AuthFailure, Unit>> logout(LogoutRequestEntity request) async {
    return right(unit);
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
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<Either<AuthFailure, UserEntity>> getMe() async {
    return left(const AuthFailure.unexpected(message: 'not implemented'));
  }
}
