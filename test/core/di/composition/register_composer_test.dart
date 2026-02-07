import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/di/composition/register_composer.dart';

void main() {
  group('RegisterComposer', () {
    test('runs registration steps in deterministic order', () {
      final order = <int>[];
      final composer = RegisterComposer(
        steps: [(_) => order.add(1), (_) => order.add(2), (_) => order.add(3)],
      );

      composer.compose(GetIt.asNewInstance());

      expect(order, [1, 2, 3]);
    });

    test('supports empty step list', () {
      final composer = RegisterComposer(steps: const []);
      expect(() => composer.compose(GetIt.asNewInstance()), returnsNormally);
    });
  });
}
