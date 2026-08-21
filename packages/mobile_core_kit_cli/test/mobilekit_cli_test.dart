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
    expect(output.toString(), contains('init'));
    expect(output.toString(), contains('customize'));
    expect(output.toString(), contains('lint'));
    expect(output.toString(), contains('runtime'));
    expect(output.toString(), contains('task'));
    expect(output.toString(), contains('event'));
    expect(output.toString(), contains('maintenance'));
    expect(output.toString(), contains('ci'));
    expect(output.toString(), contains('evidence'));
    expect(output.toString(), contains('improve'));
    expect(output.toString(), contains('risk'));
    expect(errors, isEmpty);
  });

  test('prints evidence command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['evidence', '--help']);

    expect(result, 0);
    expect(
      output.toString(),
      contains('Usage: mobilekit evidence <verify|report|mutation-pilot>'),
    );
    expect(errors, isEmpty);
  });

  test('prints improve command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['improve', '--help']);

    expect(result, 0);
    expect(
      output.toString(),
      contains('Usage: mobilekit improve <check|analyze|shadow>'),
    );
    expect(errors, isEmpty);
  });

  test('prints task command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['task', '--help']);

    expect(result, 0);
    expect(output.toString(), contains('Usage: mobilekit task begin'));
    expect(output.toString(), contains('task verify --task <id>'));
    expect(output.toString(), contains('task repair --task <id>'));
    expect(
      output.toString(),
      contains('task workspace <prepare|status|cancel|cleanup> --task <id>'),
    );
    expect(errors, isEmpty);
  });

  test('prints risk command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['risk', '--help']);

    expect(result, 0);
    expect(output.toString(), contains('Usage: mobilekit risk classify'));
    expect(errors, isEmpty);
  });

  test('prints loop command help without finding a repository', () async {
    for (final command in [
      (
        arguments: ['event', '--help'],
        usage: 'Usage: mobilekit event intake --once',
      ),
      (
        arguments: ['maintenance', '--help'],
        usage: 'Usage: mobilekit maintenance run --once',
      ),
      (
        arguments: ['ci', '--help'],
        usage:
            'Usage: mobilekit ci classify --base <revision> --head <revision>',
      ),
      (
        arguments: ['handoff', '--help'],
        usage: 'Usage: mobilekit handoff dry-run --task <id>',
      ),
    ]) {
      final output = StringBuffer();
      final errors = StringBuffer();
      final result = await MobilekitCli(
        currentDirectory: Directory.systemTemp,
        output: output,
        errorOutput: errors,
      ).run(command.arguments);

      expect(result, 0);
      expect(output.toString(), contains(command.usage));
      expect(errors, isEmpty);
    }
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

  test('prints init command help without finding a repository', () async {
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: Directory.systemTemp,
      output: output,
      errorOutput: errors,
    ).run(['init', '--help']);

    expect(result, 0);
    expect(output.toString(), contains('Usage: mobilekit init [options]'));
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
      File(p.join(tempDirectory.path, '.mobilekit', 'template.yaml'))
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
        );

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
    expect(
      output.toString(),
      contains('Usage: mobilekit verify [--profile <fast|full|runtime|ci>]'),
    );
    expect(invoked, isFalse);
  });

  test('explicit profiles reject legacy weakening flags', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_profile_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    File(
      p.join(tempDirectory.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: test_repository\n');
    File(
      p.join(tempDirectory.path, '.git'),
    ).writeAsStringSync('gitdir: test\n');
    final errors = StringBuffer();
    var invoked = false;

    final result = await MobilekitCli(
      currentDirectory: tempDirectory,
      commandExecutor: (_) async {
        invoked = true;
        return 0;
      },
      errorOutput: errors,
    ).run(['verify', '--profile', 'full', '--skip-tests']);

    expect(result, 2);
    expect(errors.toString(), contains('cannot be weakened'));
    expect(invoked, isFalse);
  });

  test('runtime profile requires an explicit device', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runtime_profile_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    File(
      p.join(tempDirectory.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: test_repository\n');
    File(
      p.join(tempDirectory.path, '.git'),
    ).writeAsStringSync('gitdir: test\n');
    final errors = StringBuffer();

    final result = await MobilekitCli(
      currentDirectory: tempDirectory,
      errorOutput: errors,
    ).run(['verify', '--profile', 'runtime']);

    expect(result, 2);
    expect(errors.toString(), contains('--device is required'));
  });

  test(
    'verification failure includes stable step id and remediation',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'mobile_core_kit_cli_failure_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      File(
        p.join(tempDirectory.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: test_repository\n');
      File(
        p.join(tempDirectory.path, '.git'),
      ).writeAsStringSync('gitdir: test\n');
      final errors = StringBuffer();

      final result = await MobilekitCli(
        currentDirectory: tempDirectory,
        commandExecutor: (_) async => 9,
        errorOutput: errors,
      ).run(['verify', '--profile', 'fast']);

      expect(result, 9);
      expect(errors.toString(), contains('FAIL [verify.dependencies]'));
      expect(errors.toString(), contains('Remediation:'));
    },
  );

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
