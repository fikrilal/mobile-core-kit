import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_user_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

class _MockLogoutUserUseCase extends Mock implements LogoutUserUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RefreshRequestEntity(refreshToken: 'refresh'));
  });

  group('LogoutFlowUseCase', () {
    test('calls remote logout (best-effort) then clears local session', () async {
      final logoutUser = _MockLogoutUserUseCase();
      when(() => logoutUser(any())).thenAnswer((_) async => right(null));

      final sessionManager = _MockSessionManager();
      when(() => sessionManager.session).thenReturn(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh_123',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: UserEntity(id: 'u1', email: 'user@example.com'),
        ),
      );
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutUser: logoutUser,
        sessionManager: sessionManager,
      );

      await usecase(reason: 'manual_logout');

      verifyInOrder([
        () => logoutUser(const RefreshRequestEntity(refreshToken: 'refresh_123')),
        () => sessionManager.logout(reason: 'manual_logout'),
      ]);
    });

    test('still clears local session when remote logout returns failure', () async {
      final logoutUser = _MockLogoutUserUseCase();
      when(
        () => logoutUser(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final sessionManager = _MockSessionManager();
      when(() => sessionManager.session).thenReturn(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh_123',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
        ),
      );
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutUser: logoutUser,
        sessionManager: sessionManager,
      );

      await usecase(reason: 'manual_logout');

      verify(() => sessionManager.logout(reason: 'manual_logout')).called(1);
    });

    test('skips remote logout when there is no session', () async {
      final logoutUser = _MockLogoutUserUseCase();
      final sessionManager = _MockSessionManager();

      when(() => sessionManager.session).thenReturn(null);
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      final usecase = LogoutFlowUseCase(
        logoutUser: logoutUser,
        sessionManager: sessionManager,
      );

      await usecase(reason: 'manual_logout');

      verifyNever(() => logoutUser(any()));
      verify(() => sessionManager.logout(reason: 'manual_logout')).called(1);
    });
  });
}

