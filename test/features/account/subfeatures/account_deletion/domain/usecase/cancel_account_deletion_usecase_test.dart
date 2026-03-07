import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/cancel_account_deletion_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAccountDeletionRepository extends Mock
    implements AccountDeletionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CancelAccountDeletionRequestEntity());
  });

  group('CancelAccountDeletionUseCase', () {
    test('delegates to repository', () async {
      final repo = _MockAccountDeletionRepository();
      final usecase = CancelAccountDeletionUseCase(repo);
      const request = CancelAccountDeletionRequestEntity();

      when(
        () => repo.cancelAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(request);

      expect(result, right(unit));
      verify(() => repo.cancelAccountDeletion(request)).called(1);
    });

    test('propagates failures', () async {
      final repo = _MockAccountDeletionRepository();
      final usecase = CancelAccountDeletionUseCase(repo);
      const request = CancelAccountDeletionRequestEntity();

      when(
        () => repo.cancelAccountDeletion(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final result = await usecase(request);

      expect(result, left(const AuthFailure.network()));
      verify(() => repo.cancelAccountDeletion(request)).called(1);
    });
  });
}
