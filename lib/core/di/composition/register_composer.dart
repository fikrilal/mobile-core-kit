import 'package:get_it/get_it.dart';

typedef LocatorRegistrar = void Function(GetIt locator);

/// Composes synchronous GetIt registration steps in deterministic order.
class RegisterComposer {
  const RegisterComposer({required List<LocatorRegistrar> steps})
    : _steps = steps;

  final List<LocatorRegistrar> _steps;

  void compose(GetIt locator) {
    for (final step in _steps) {
      step(locator);
    }
  }
}
