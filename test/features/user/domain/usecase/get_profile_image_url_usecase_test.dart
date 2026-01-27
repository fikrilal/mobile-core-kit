import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_image_url_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileImageRepository extends Mock implements ProfileImageRepository {}

void main() {
  group('GetProfileImageUrlUseCase', () {
    test('delegates to repository', () async {
      final repo = _MockProfileImageRepository();
      final usecase = GetProfileImageUrlUseCase(repo);

      final url = ProfileImageUrlEntity(
        url: 'https://example.com/u1.png',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      when(() => repo.getProfileImageUrl()).thenAnswer((_) async => right(url));

      final result = await usecase();

      expect(result, right(url));
      verify(() => repo.getProfileImageUrl()).called(1);
    });

    test('propagates failures', () async {
      final repo = _MockProfileImageRepository();
      final usecase = GetProfileImageUrlUseCase(repo);

      when(
        () => repo.getProfileImageUrl(),
      ).thenAnswer((_) async => left(const AuthFailure.network()));

      final result = await usecase();

      expect(result, left(const AuthFailure.network()));
      verify(() => repo.getProfileImageUrl()).called(1);
    });
  });
}

