import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileImageRepository extends Mock
    implements ProfileImageRepository {}

class _MockGetMeUseCase extends Mock implements GetMeUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ClearProfileImageRequestEntity());
  });

  group('ClearProfileImageUseCase', () {
    test('clears then refreshes /me', () async {
      final repo = _MockProfileImageRepository();
      final getMe = _MockGetMeUseCase();
      const user = UserEntity(id: 'u1', email: 'user@example.com');

      when(
        () => repo.clearProfileImage(any()),
      ).thenAnswer((_) async => right(unit));
      when(() => getMe()).thenAnswer((_) async => right(user));

      final usecase = ClearProfileImageUseCase(repo, getMe);

      final result = await usecase(const ClearProfileImageRequestEntity());

      expect(result, right(user));

      verifyInOrder([() => repo.clearProfileImage(any()), () => getMe()]);
    });

    test('returns failure and does not call getMe when clear fails', () async {
      final repo = _MockProfileImageRepository();
      final getMe = _MockGetMeUseCase();

      when(
        () => repo.clearProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final usecase = ClearProfileImageUseCase(repo, getMe);

      final result = await usecase(const ClearProfileImageRequestEntity());

      expect(result, left(const AuthFailure.network()));

      verify(() => repo.clearProfileImage(any())).called(1);
      verifyNever(() => getMe());
    });
  });
}
