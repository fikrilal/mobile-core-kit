import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/refresh_current_user_after_profile_image_mutation.dart';
import 'package:mocktail/mocktail.dart';

class _MockCurrentUserFetcher extends Mock implements CurrentUserFetcher {}

void main() {
  group('refreshCurrentUserAfterProfileImageMutation', () {
    test('returns the refreshed user when fetch succeeds', () async {
      final fetcher = _MockCurrentUserFetcher();
      const user = UserEntity(id: 'u1', email: 'user@example.com');

      when(() => fetcher.fetch()).thenAnswer((_) async => right(user));

      final result = await refreshCurrentUserAfterProfileImageMutation(fetcher);

      expect(result, right(user));
    });

    test('maps session unauthenticated to auth unauthenticated', () async {
      final fetcher = _MockCurrentUserFetcher();

      when(
        () => fetcher.fetch(),
      ).thenAnswer((_) async => left(const SessionFailure.unauthenticated()));

      final result = await refreshCurrentUserAfterProfileImageMutation(fetcher);

      expect(result, left(const AuthFailure.unauthenticated()));
    });

    test('maps session server error to auth server error', () async {
      final fetcher = _MockCurrentUserFetcher();

      when(
        () => fetcher.fetch(),
      ).thenAnswer((_) async => left(const SessionFailure.serverError('down')));

      final result = await refreshCurrentUserAfterProfileImageMutation(fetcher);

      expect(result, left(const AuthFailure.serverError('down')));
    });
  });
}
