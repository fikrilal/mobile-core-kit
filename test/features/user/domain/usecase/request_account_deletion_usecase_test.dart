import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RequestAccountDeletionRequestEntity());
  });

  group('RequestAccountDeletionUseCase', () {
    test('delegates to repository', () async {
      final repo = _MockUserRepository();
      final usecase = RequestAccountDeletionUseCase(repo);
      const request = RequestAccountDeletionRequestEntity();

      when(
        () => repo.requestAccountDeletion(any()),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(request);

      expect(result, right(unit));
      verify(() => repo.requestAccountDeletion(request)).called(1);
    });

    test('propagates failures', () async {
      final repo = _MockUserRepository();
      final usecase = RequestAccountDeletionUseCase(repo);
      const request = RequestAccountDeletionRequestEntity();

      when(
        () => repo.requestAccountDeletion(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final result = await usecase(request);

      expect(result, left(const AuthFailure.network()));
      verify(() => repo.requestAccountDeletion(request)).called(1);
    });
  });
}
