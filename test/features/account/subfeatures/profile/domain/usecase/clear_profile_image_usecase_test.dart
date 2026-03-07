import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileImageRepository extends Mock
    implements ProfileImageRepository {}

class _MockCurrentUserFetcher extends Mock implements CurrentUserFetcher {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ClearProfileImageRequestEntity());
  });

  group('ClearProfileImageUseCase', () {
    test('clears then refreshes /me', () async {
      final repo = _MockProfileImageRepository();
      final fetcher = _MockCurrentUserFetcher();
      const user = UserEntity(id: 'u1', email: 'user@example.com');

      when(
        () => repo.clearProfileImage(any()),
      ).thenAnswer((_) async => right(unit));
      when(() => fetcher.fetch()).thenAnswer((_) async => right(user));

      final usecase = ClearProfileImageUseCase(repo, fetcher);

      final result = await usecase(const ClearProfileImageRequestEntity());

      expect(result, right(user));

      verifyInOrder([
        () => repo.clearProfileImage(any()),
        () => fetcher.fetch(),
      ]);
    });

    test('returns failure and does not call getMe when clear fails', () async {
      final repo = _MockProfileImageRepository();
      final fetcher = _MockCurrentUserFetcher();

      when(
        () => repo.clearProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final usecase = ClearProfileImageUseCase(repo, fetcher);

      final result = await usecase(const ClearProfileImageRequestEntity());

      expect(result, left(const AuthFailure.network()));

      verify(() => repo.clearProfileImage(any())).called(1);
      verifyNever(() => fetcher.fetch());
    });

    test('maps current-user refresh failure back to auth failure', () async {
      final repo = _MockProfileImageRepository();
      final fetcher = _MockCurrentUserFetcher();

      when(
        () => repo.clearProfileImage(any()),
      ).thenAnswer((_) async => right(unit));
      when(
        () => fetcher.fetch(),
      ).thenAnswer((_) async => left(const SessionFailure.serverError()));

      final usecase = ClearProfileImageUseCase(repo, fetcher);

      final result = await usecase(const ClearProfileImageRequestEntity());

      expect(result, left(const AuthFailure.serverError()));
    });
  });
}
