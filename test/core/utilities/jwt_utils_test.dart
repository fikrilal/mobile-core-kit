import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/utilities/jwt_utils.dart';

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

void main() {
  group('JwtUtils', () {
    test('tryDecodePayload returns payload map', () {
      final jwt = _jwtWithPayload({'sub': 'u1', 'exp': 1});

      final payload = JwtUtils.tryDecodePayload(jwt);

      expect(payload, isNotNull);
      expect(payload!['sub'], 'u1');
      expect(payload['exp'], 1);
    });

    test('tryGetExpiresAt reads exp (int) as utc DateTime', () {
      const expSeconds = 1893456000; // 2030-01-01T00:00:00Z
      final jwt = _jwtWithPayload({'exp': expSeconds});

      final expiresAt = JwtUtils.tryGetExpiresAt(jwt);

      expect(
        expiresAt,
        DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true),
      );
    });

    test('tryGetExpiresAt reads exp (string)', () {
      const expSeconds = 1893456000; // 2030-01-01T00:00:00Z
      final jwt = _jwtWithPayload({'exp': expSeconds.toString()});

      final expiresAt = JwtUtils.tryGetExpiresAt(jwt);

      expect(
        expiresAt,
        DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true),
      );
    });

    test('tryComputeExpiry clamps expiresIn at 0 when expired', () {
      const expSeconds = 1000;
      final jwt = _jwtWithPayload({'exp': expSeconds});

      final now = DateTime.fromMillisecondsSinceEpoch(
        (expSeconds + 10) * 1000,
        isUtc: true,
      );
      final expiry = JwtUtils.tryComputeExpiry(jwt, now: now);

      expect(expiry, isNotNull);
      expect(
        expiry!.expiresAt,
        DateTime.fromMillisecondsSinceEpoch(1000 * 1000, isUtc: true),
      );
      expect(expiry.expiresIn, 0);
    });

    test('returns null when exp is missing', () {
      final jwt = _jwtWithPayload({'sub': 'u1'});

      expect(JwtUtils.tryGetExpiresAt(jwt), isNull);
      expect(JwtUtils.tryComputeExpiry(jwt), isNull);
    });

    test('returns null when exp is malformed', () {
      final jwt = _jwtWithPayload({'exp': 'not-a-number'});

      expect(JwtUtils.tryGetExpiresAt(jwt), isNull);
      expect(JwtUtils.tryComputeExpiry(jwt), isNull);
    });

    test('returns null for invalid tokens', () {
      expect(JwtUtils.tryDecodePayload('not-a-jwt'), isNull);
      expect(JwtUtils.tryGetExpiresAt('not-a-jwt'), isNull);
      expect(JwtUtils.tryComputeExpiry('not-a-jwt'), isNull);
    });
  });
}
