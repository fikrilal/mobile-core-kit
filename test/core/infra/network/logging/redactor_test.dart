import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/infra/network/logging/redactor.dart';

void main() {
  group('Redactor.redactMap', () {
    test('redacts token-like keys', () {
      const accessToken = 'access_1234567890';
      const refreshToken = 'refresh_1234567890';
      const idToken = 'id_1234567890';
      const password = 'Secret123';

      final result = Redactor.redactMap({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'idToken': idToken,
        'password': password,
        // Should not be redacted (non-sensitive).
        'tokenType': 'Bearer',
      });

      expect(result['accessToken'], isNot(accessToken));
      expect(result['refreshToken'], isNot(refreshToken));
      expect(result['idToken'], isNot(idToken));
      expect(result['password'], isNot(password));
      expect(result['tokenType'], 'Bearer');

      expect(result['accessToken'], contains('***'));
      expect(result['refreshToken'], contains('***'));
      expect(result['idToken'], contains('***'));
      expect(result['password'], contains('***'));
    });

    test('redacts nested token-like keys in maps and lists', () {
      const accessToken = 'access_1234567890';
      const refreshToken = 'refresh_1234567890';

      final result = Redactor.redactMap({
        'data': {
          'tokens': {'accessToken': accessToken},
        },
        'items': [
          {'refreshToken': refreshToken},
        ],
      });

      final data = result['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;
      expect(tokens['accessToken'], isNot(accessToken));
      expect(tokens['accessToken'], contains('***'));

      final items = result['items'] as List;
      final first = items.first as Map;
      expect(first['refreshToken'], isNot(refreshToken));
      expect(first['refreshToken'], contains('***'));
    });
  });
}
