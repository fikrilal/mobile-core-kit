import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';

void main() {
  group('Password', () {
    test('accepts password with min length and preserves whitespace', () {
      final result = Password.create(' stringstring ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, ' stringstring '),
      );
    });

    test('rejects empty/whitespace-only password', () {
      expect(Password.create('').isLeft(), true);
      expect(Password.create('   ').isLeft(), true);
    });

    test('rejects password shorter than 8 characters', () {
      expect(Password.create('short').isLeft(), true);
    });
  });
}
