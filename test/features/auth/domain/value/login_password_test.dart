import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';

void main() {
  group('LoginPassword', () {
    test('accepts non-empty password and preserves whitespace', () {
      final result = LoginPassword.create(' password ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Expected Right'),
        (value) => expect(value.value, ' password '),
      );
    });

    test('rejects empty/whitespace-only password', () {
      expect(LoginPassword.create('').isLeft(), true);
      expect(LoginPassword.create('   ').isLeft(), true);
    });
  });
}
