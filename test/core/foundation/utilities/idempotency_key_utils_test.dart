import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';

void main() {
  group('IdempotencyKeyUtils', () {
    test('headerName is Idempotency-Key', () {
      expect(IdempotencyKeyUtils.headerName, 'Idempotency-Key');
    });

    test('generate produces random 32 hex chars by default', () {
      final key1 = IdempotencyKeyUtils.generate();
      final key2 = IdempotencyKeyUtils.generate();

      expect(key1.length, 32);
      expect(key2.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(key1), isTrue);
      expect(key1, isNot(equals(key2)));
    });

    test('generate respects custom byte count', () {
      final key = IdempotencyKeyUtils.generate(bytes: 8);
      expect(key.length, 16);
      expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(key), isTrue);
    });

    test('headers generates new key when none provided', () {
      final headers = IdempotencyKeyUtils.headers();

      expect(headers.containsKey(IdempotencyKeyUtils.headerName), isTrue);
      expect(headers[IdempotencyKeyUtils.headerName], isNotEmpty);
      expect(headers[IdempotencyKeyUtils.headerName]!.length, 32);
    });

    test('headers uses provided idempotency key', () {
      const customKey = 'custom-idem-123';
      final headers = IdempotencyKeyUtils.headers(customKey);

      expect(headers, {IdempotencyKeyUtils.headerName: customKey});
    });
  });
}
