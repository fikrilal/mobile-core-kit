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
    expect(errors, isEmpty);
  });

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

  test('maps workflow commands to existing tool scripts', () async {
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
        ['dart', 'run', 'tool/verify.dart', '--env', 'dev', '--skip-tests'],
      ],
      [
        ['fix', '--dry-run'],
        ['dart', 'run', 'tool/fix.dart', '--dry-run'],
      ],
      [
        ['config', 'generate', '--env', 'dev'],
        ['dart', 'run', 'tool/gen_config.dart', '--env', 'dev'],
      ],
      [
        ['env', 'verify', '--all', '--strict'],
        ['dart', 'run', 'tool/verify_env_schema.dart', '--all', '--strict'],
      ],
      [
        ['codegen', 'verify'],
        ['dart', 'run', 'tool/verify_codegen.dart'],
      ],
      [
        ['l10n', 'verify', 'tool/untranslated_messages.json'],
        [
          'dart',
          'run',
          'tool/verify_untranslated_messages.dart',
          'tool/untranslated_messages.json',
        ],
      ],
      [
        ['project-map', 'verify'],
        ['dart', 'run', 'tool/verify_project_map_drift.dart'],
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
  });

  test('prints command help without invoking a tool script', () async {
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
