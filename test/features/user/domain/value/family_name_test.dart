import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/user/domain/value/family_name.dart';

void main() {
  group('FamilyName', () {
    test('accepts trimmed valid name', () {
      final result = FamilyName.create(' Doe ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, 'Doe'),
      );
    });

    test('createOptional returns null for empty input', () {
      final result = FamilyName.createOptional('   ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value, isNull),
      );
    });

    test('createOptional rejects too-short non-empty input', () {
      expect(FamilyName.createOptional('A').isLeft(), true);
    });
  });
}
