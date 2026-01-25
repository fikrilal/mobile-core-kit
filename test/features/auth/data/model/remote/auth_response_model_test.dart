import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';

String _jwtWithPayload(Map<String, dynamic> payload) {
  final header = <String, dynamic>{'alg': 'none', 'typ': 'JWT'};
  final headerPart = base64Url
      .encode(utf8.encode(jsonEncode(header)))
      .replaceAll('=', '');
  final payloadPart = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return '$headerPart.$payloadPart.signature';
}

String _jwtWithExpSeconds(int expSeconds) {
  return _jwtWithPayload({'exp': expSeconds});
}

void main() {
  group('AuthResponseModel', () {
    test('parses backend-shaped JSON (login/register/oidc)', () {
      final expSeconds =
          DateTime.now()
              .toUtc()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch ~/
          1000;

      final json = <String, dynamic>{
        'user': <String, dynamic>{
          'id': 'u1',
          'email': 'user@example.com',
          'emailVerified': true,
          'roles': ['USER'],
          'authMethods': ['PASSWORD'],
          'profile': <String, dynamic>{
            'profileImageFileId': null,
            'displayName': null,
            'givenName': 'Dante',
            'familyName': null,
          },
          'accountDeletion': null,
        },
        'accessToken': _jwtWithExpSeconds(expSeconds),
        'refreshToken': 'refresh',
      };

      final model = AuthResponseModel.fromJson(json);

      expect(model.user.id, 'u1');
      expect(model.user.email, 'user@example.com');
      expect(model.user.emailVerified, true);
      expect(model.user.roles, ['USER']);
      expect(model.user.authMethods, ['PASSWORD']);
      expect(model.user.profile.givenName, 'Dante');
      expect(model.accessToken, isNotEmpty);
      expect(model.refreshToken, 'refresh');
    });

    test('toSessionEntity preserves hydrated user fields', () {
      final model = AuthResponseModel.fromJson(<String, dynamic>{
        'user': <String, dynamic>{
          'id': 'u1',
          'email': 'user@example.com',
          'emailVerified': true,
          'roles': ['USER'],
          'authMethods': ['PASSWORD'],
          'profile': <String, dynamic>{
            'profileImageFileId': null,
            'displayName': null,
            'givenName': 'Dante',
            'familyName': null,
          },
        },
        'accessToken': _jwtWithPayload({'sub': 'u1'}),
        'refreshToken': 'refresh',
      });

      final session = model.toSessionEntity();

      expect(session.user, isNotNull);
      expect(session.user!.roles, ['USER']);
      expect(session.user!.profile.givenName, 'Dante');
    });
  });
}
