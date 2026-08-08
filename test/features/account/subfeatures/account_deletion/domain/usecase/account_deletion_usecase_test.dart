import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/account_deletion_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountDeletionRepository extends Mock
    implements AccountDeletionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(AccountDeletionAction.request);
  });

  group('AccountDeletionUseCase', () {
    test('delegates request action to repository', () async {
      final repo = _MockAccountDeletionRepository();
      final usecase = AccountDeletionUseCase(repo);

      when(
        () => repo.deleteAccount(any()),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(AccountDeletionAction.request);

      expect(result, right(unit));
      verify(
        () => repo.deleteAccount(AccountDeletionAction.request),
      ).called(1);
    });

    test('delegates cancel action to repository', () async {
      final repo = _MockAccountDeletionRepository();
      final usecase = AccountDeletionUseCase(repo);

      when(
        () => repo.deleteAccount(any()),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(AccountDeletionAction.cancel);

      expect(result, right(unit));
      verify(
        () => repo.deleteAccount(AccountDeletionAction.cancel),
      ).called(1);
    });

    test('propagates failures', () async {
      final repo = _MockAccountDeletionRepository();
      final usecase = AccountDeletionUseCase(repo);

      when(
        () => repo.deleteAccount(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final result = await usecase(AccountDeletionAction.request);

      expect(result, left(const AuthFailure.network()));
      verify(
        () => repo.deleteAccount(AccountDeletionAction.request),
      ).called(1);
    });
  });
}
