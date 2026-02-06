import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/di/composition/bootstrap_composer.dart';

void main() {
  group('BootstrapComposer', () {
    test('runs bootstrap steps in deterministic order', () async {
      final order = <int>[];
      final composer = BootstrapComposer(
        steps: [
          () async => order.add(1),
          () async => order.add(2),
          () async => order.add(3),
        ],
      );

      await composer.compose();

      expect(order, [1, 2, 3]);
    });

    test('rethrows step errors and stops subsequent steps', () async {
      final order = <int>[];
      final composer = BootstrapComposer(
        steps: [
          () async => order.add(1),
          () async {
            order.add(2);
            throw StateError('boom');
          },
          () async => order.add(3),
        ],
      );

      await expectLater(composer.compose(), throwsA(isA<StateError>()));
      expect(order, [1, 2]);
    });
  });
}
