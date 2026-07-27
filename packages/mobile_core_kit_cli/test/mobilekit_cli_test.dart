import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:test/test.dart';

void main() {
  test('prints general help', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      output: output,
      errorOutput: errors,
    ).run(['--help']);

    expect(result, 0);
    expect(
      output.toString(),
      contains('mobilekit - mobile-core-kit repository tooling'),
    );
    expect(output.toString(), contains('doctor'));
    expect(errors, isEmpty);
  });

  test('returns usage error for an unknown command', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      output: output,
      errorOutput: errors,
    ).run(['verify']);

    expect(result, 2);
    expect(errors.toString(), contains("Unknown command 'verify'"));
    expect(output, isEmpty);
  });

  test('routes doctor and reports a missing repository', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_command_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final output = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: tempDirectory,
      output: output,
    ).run(['doctor']);

    expect(result, 1);
    expect(output.toString(), contains('Repository: not found'));
    expect(output.toString(), contains('Doctor found problems.'));
  });
}
