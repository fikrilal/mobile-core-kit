import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_user_model.dart';

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
  group('AuthResultModel', () {
    test('parses backend-shaped JSON (login/register)', () {
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
          'authMethods': ['PASSWORD'],
        },
        'accessToken': _jwtWithExpSeconds(expSeconds),
        'refreshToken': 'refresh',
      };

      final model = AuthResultModel.fromJson(json);

      expect(model.user.id, 'u1');
      expect(model.user.email, 'user@example.com');
      expect(model.user.emailVerified, true);
      expect(model.user.authMethods, ['PASSWORD']);
      expect(model.accessToken, isNotEmpty);
      expect(model.refreshToken, 'refresh');
    });

    test('parses backend-shaped JSON (refresh, authMethods omitted)', () {
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
        },
        'accessToken': _jwtWithExpSeconds(expSeconds),
        'refreshToken': 'refresh',
      };

      final model = AuthResultModel.fromJson(json);
      expect(model.user.authMethods, isNull);

      final session = model.toSessionEntity();
      expect(session.user?.authMethods, isEmpty);
    });

    test('toTokensEntity derives expiry from access token', () {
      final expSeconds =
          DateTime.now()
              .toUtc()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch ~/
          1000;

      final accessToken = _jwtWithExpSeconds(expSeconds);
      final result = AuthResultModel(
        user: const AuthUserModel(
          id: 'u1',
          email: 'user@example.com',
          emailVerified: false,
        ),
        accessToken: accessToken,
        refreshToken: 'refresh',
      );

      final tokens = result.toTokensEntity();

      expect(tokens.expiresAt, isNotNull);
      expect(tokens.expiresIn, greaterThan(0));
      expect(tokens.expiresAt!.millisecondsSinceEpoch, expSeconds * 1000);
    });

    test('toTokensEntity is safe when exp is missing or malformed', () {
      final missingExp = AuthResultModel(
        user: const AuthUserModel(
          id: 'u1',
          email: 'user@example.com',
          emailVerified: false,
        ),
        accessToken: _jwtWithPayload({'sub': 'u1'}),
        refreshToken: 'refresh',
      );

      final missingTokens = missingExp.toTokensEntity();
      expect(missingTokens.expiresAt, isNull);
      expect(missingTokens.expiresIn, 0);

      final malformedExp = AuthResultModel(
        user: const AuthUserModel(
          id: 'u1',
          email: 'user@example.com',
          emailVerified: false,
        ),
        accessToken: _jwtWithPayload({'exp': 'not-a-number'}),
        refreshToken: 'refresh',
      );

      final malformedTokens = malformedExp.toTokensEntity();
      expect(malformedTokens.expiresAt, isNull);
      expect(malformedTokens.expiresIn, 0);
    });
  });
}
