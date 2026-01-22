import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/me_model.dart';

void main() {
  group('MeModel', () {
    test('parses nested profile and maps to UserEntity', () {
      final json = <String, dynamic>{
        'id': 'u1',
        'email': 'user@example.com',
        'emailVerified': true,
        'roles': ['USER', 'ADMIN'],
        'authMethods': ['PASSWORD', 'GOOGLE'],
        'profile': {
          'profileImageFileId': 'file_1',
          'displayName': 'Dante Alighieri',
          'givenName': 'Dante',
          'familyName': 'Alighieri',
        },
        'accountDeletion': {
          'requestedAt': '2026-01-01T00:00:00Z',
          'scheduledFor': '2026-02-01T00:00:00Z',
        },
      };

      final model = MeModel.fromJson(json);
      final entity = model.toEntity();

      expect(
        entity,
        const UserEntity(
          id: 'u1',
          email: 'user@example.com',
          emailVerified: true,
          roles: ['USER', 'ADMIN'],
          authMethods: ['PASSWORD', 'GOOGLE'],
          profile: UserProfileEntity(
            profileImageFileId: 'file_1',
            displayName: 'Dante Alighieri',
            givenName: 'Dante',
            familyName: 'Alighieri',
          ),
          accountDeletion: AccountDeletionEntity(
            requestedAt: '2026-01-01T00:00:00Z',
            scheduledFor: '2026-02-01T00:00:00Z',
          ),
        ),
      );
    });

    test('supports null accountDeletion', () {
      final json = <String, dynamic>{
        'id': 'u1',
        'email': 'user@example.com',
        'emailVerified': true,
        'roles': ['USER'],
        'authMethods': ['PASSWORD'],
        'profile': {
          'givenName': 'Dante',
        },
      };

      final entity = MeModel.fromJson(json).toEntity();
      expect(entity.accountDeletion, isNull);
      expect(entity.profile.givenName, 'Dante');
    });
  });
}

