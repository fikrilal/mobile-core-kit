import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/deadline_command_runner.dart';
import 'package:test/test.dart';

void main() {
  test('refuses to start a command after the task deadline', () async {
    final root = await Directory.systemTemp.createTemp('mobilekit_deadline_');
    addTearDown(() => root.delete(recursive: true));
    final runner = DeadlineCommandRunner(
      rootDirectory: root,
      deadline: DateTime.now().toUtc().subtract(const Duration(seconds: 1)),
      output: StringBuffer(),
      errorOutput: StringBuffer(),
    );

    final result = await runner.run(['definitely-not-an-executable']);

    expect(result, 124);
    expect(runner.lastResult!.timedOut, isTrue);
    expect(
      runner.lastResult!.diagnostic,
      'Task deadline expired before command start.',
    );
  });
}
