import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';

void main() {
  group('EmailAddress', () {
    test('accepts trimmed valid address', () {
      final result = EmailAddress.create(' user@example.com ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, 'user@example.com'),
      );
    });

    test('rejects invalid format', () {
      final result = EmailAddress.create('not-an-email');
      expect(result.isLeft(), true);
    });

    test('rejects trailing junk after a valid-looking prefix', () {
      final result = EmailAddress.create('user@example.com trailing');
      expect(result.isLeft(), true);
    });

    test('rejects multiple @', () {
      final result = EmailAddress.create('user@example.com@evil.com');
      expect(result.isLeft(), true);
    });
  });
}

