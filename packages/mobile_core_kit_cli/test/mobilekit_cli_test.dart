import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:path/path.dart' as p;
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
    expect(output.toString(), contains('lint'));
    expect(output.toString(), contains('runtime'));
    expect(errors, isEmpty);
  });

  test(
    'prints runtime log command help without finding a repository',
    () async {
      final output = StringBuffer();
      final errors = StringBuffer();

      final result = await MobilekitCli(
        currentDirectory: Directory.systemTemp,
        output: output,
        errorOutput: errors,
      ).run(['runtime', 'logs', '--help']);

      expect(result, 0);
      expect(output.toString(), contains('Usage: mobilekit runtime logs'));
      expect(errors, isEmpty);
    },
  );

  test('prints lint command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['lint', '--help']);

    expect(result, 0);
    expect(output.toString(), contains('Usage: mobilekit lint'));
    expect(errors, isEmpty);
  });

  test(
    'prints runtime evidence command help without finding a repository',
    () async {
      final output = StringBuffer();
      final errors = StringBuffer();

      final result = await MobilekitCli(
        currentDirectory: Directory.systemTemp,
        output: output,
        errorOutput: errors,
      ).run(['runtime', 'evidence', '--help']);

      expect(result, 0);
      expect(output.toString(), contains('Usage: mobilekit runtime evidence'));
      expect(errors, isEmpty);
    },
  );

  test('returns usage error for an unknown command', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      output: output,
      errorOutput: errors,
    ).run(['unknown']);

    expect(result, 2);
    expect(errors.toString(), contains("Unknown command 'unknown'"));
    expect(output, isEmpty);
  });

  test(
    'runs CLI-owned workflow commands through the shared executor',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'mobile_core_kit_cli_workflow_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      File(
        p.join(tempDirectory.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: test_repository\n');
      Directory(p.join(tempDirectory.path, 'tool')).createSync();

      final cases = <List<List<String>>>[
        [
          ['verify', '--env', 'dev', '--skip-tests'],
          ['flutter', 'pub', 'get'],
        ],
        [
          ['fix', '--dry-run'],
          ['dart', 'fix', '--dry-run', '--code', 'directives_ordering'],
        ],
      ];

      for (final testCase in cases) {
        final invocations = <List<String>>[];
        final result = await MobilekitCli(
          currentDirectory: tempDirectory,
          commandExecutor: (command) async {
            invocations.add(List<String>.from(command));
            return 17;
          },
        ).run(testCase.first);

        expect(result, 17, reason: 'Arguments: ${testCase.first}');
        expect(invocations, [testCase.last]);
      }
    },
  );

  test('prints command help without invoking a legacy entrypoint', () async {
    final output = StringBuffer();
    var invoked = false;

    final result = await MobilekitCli(
      output: output,
      commandExecutor: (command) async {
        invoked = true;
        return 0;
      },
    ).run(['verify', '--help']);

    expect(result, 0);
    expect(output.toString(), contains('Usage: mobilekit verify [options]'));
    expect(invoked, isFalse);
  });

  test('rejects an unknown grouped command', () async {
    final errors = StringBuffer();

    final result = await MobilekitCli(
      errorOutput: errors,
    ).run(['config', 'write']);

    expect(result, 2);
    expect(errors.toString(), contains("Unknown config command 'write'"));
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
