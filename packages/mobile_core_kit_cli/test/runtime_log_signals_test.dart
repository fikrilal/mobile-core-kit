import 'package:mobile_core_kit_cli/src/runtime/runtime_log_signals.dart';
import 'package:test/test.dart';

void main() {
  test('requires a developer log line and each journey substring', () {
    const signals = [
      MaestroLogSignal(
        id: 'login-succeeded',
        contains: 'POST /auth/password/login → 2',
      ),
    ];

    final attached = evaluateMaestroLog(
      log:
          '[GoRouter] going to /auth/sign-in\n'
          '[network] [DEBUG] POST /auth/password/login → 200 in 40 ms\n',
      signals: signals,
    );
    final rejected = evaluateMaestroLog(
      log:
          '[GoRouter] going to /auth/sign-in\n'
          '[network] [ERROR] POST /auth/password/login → 401 in 12 ms\n'
          'refreshToken secret\n',
      signals: signals,
    );
    final silent = evaluateMaestroLog(
      log: 'I/flutter ( 1): The Dart VM service is listening on http://x/\n',
      signals: signals,
    );

    expect(attached.passed, isTrue);
    expect(attached.missingIds, isEmpty);
    expect(rejected.vmLogAttached, isTrue);
    expect(rejected.missingIds, ['login-succeeded']);
    expect(rejected.toJson().toString(), isNot(contains('secret')));
    expect(silent.missingIds, ['vm-log-attached', 'login-succeeded']);
  });
}
