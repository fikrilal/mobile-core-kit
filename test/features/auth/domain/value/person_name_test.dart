import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/value/person_name.dart';

void main() {
  group('PersonName', () {
    test('trims and accepts valid name', () {
      final result = PersonName.create(' John ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, 'John'),
      );
    });

    test('rejects empty/whitespace-only name', () {
      expect(PersonName.create('').isLeft(), true);
      expect(PersonName.create('   ').isLeft(), true);
    });

    test('rejects 1-character name', () {
      expect(PersonName.create('A').isLeft(), true);
    });

    test('rejects name longer than 50 characters', () {
      final input = List.filled(51, 'a').join();
      expect(PersonName.create(input).isLeft(), true);
    });
  });
}

