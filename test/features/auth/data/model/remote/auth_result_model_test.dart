import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/user_model.dart';

String _jwtWithExpSeconds(int expSeconds) {
  final header = <String, dynamic>{'alg': 'none', 'typ': 'JWT'};
  final payload = <String, dynamic>{'exp': expSeconds};
  final headerPart = base64Url
      .encode(utf8.encode(jsonEncode(header)))
      .replaceAll('=', '');
  final payloadPart = base64Url
      .encode(utf8.encode(jsonEncode(payload)))
      .replaceAll('=', '');
  return '$headerPart.$payloadPart.signature';
}

void main() {
  test('AuthResultModel.toTokensEntity derives expiry from access token', () {
    final expSeconds = DateTime.now()
        .toUtc()
        .add(const Duration(days: 30))
        .millisecondsSinceEpoch ~/
        1000;

    final accessToken = _jwtWithExpSeconds(expSeconds);
    final result = AuthResultModel(
      user: const UserModel(id: 'u1', email: 'user@example.com'),
      accessToken: accessToken,
      refreshToken: 'refresh',
    );

    final tokens = result.toTokensEntity();

    expect(tokens.expiresAt, isNotNull);
    expect(
      tokens.expiresAt,
      DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true),
    );
    expect(tokens.expiresIn, greaterThan(0));
  });
}

