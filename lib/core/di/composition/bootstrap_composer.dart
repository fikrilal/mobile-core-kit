typedef BootstrapStep = Future<void> Function();

/// Composes asynchronous bootstrap steps in deterministic order.
class BootstrapComposer {
  const BootstrapComposer({required List<BootstrapStep> steps})
    : _steps = steps;

  final List<BootstrapStep> _steps;

  Future<void> compose() async {
    for (final step in _steps) {
      await step();
    }
  }
}
