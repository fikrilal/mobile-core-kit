import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/user/domain/value/given_name.dart';

void main() {
  group('GivenName', () {
    test('accepts trimmed valid name', () {
      final result = GivenName.create(' John ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, 'John'),
      );
    });

    test('rejects empty name', () {
      expect(GivenName.create('').isLeft(), true);
      expect(GivenName.create('   ').isLeft(), true);
    });

    test('rejects too-short name', () {
      expect(GivenName.create('A').isLeft(), true);
    });

    test('rejects too-long name', () {
      final long = 'A' * 51;
      expect(GivenName.create(long).isLeft(), true);
    });
  });
}
