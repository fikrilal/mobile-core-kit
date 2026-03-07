import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/adapters/current_user_fetcher_adapter.dart';
import 'package:mobile_core_kit/features/account/domain/usecase/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetCurrentUserUseCase extends Mock
    implements GetCurrentUserUseCase {}

void main() {
  group('AccountCurrentUserFetcherAdapter', () {
    test('returns the user when current-user fetch succeeds', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      final getCurrentUser = _MockGetCurrentUserUseCase();
      final adapter = AccountCurrentUserFetcherAdapter(getCurrentUser);

      when(() => getCurrentUser()).thenAnswer((_) async => right(user));

      final result = await adapter.fetch();

      expect(
        result,
        right(const UserEntity(id: 'u1', email: 'user@example.com')),
      );
    });

    test('maps auth failures into session failures', () async {
      final getCurrentUser = _MockGetCurrentUserUseCase();
      final adapter = AccountCurrentUserFetcherAdapter(getCurrentUser);

      when(
        () => getCurrentUser(),
      ).thenAnswer((_) async => left(const AuthFailure.unauthenticated()));

      final result = await adapter.fetch();

      expect(result, left(const SessionFailure.unauthenticated()));
    });
  });
}
