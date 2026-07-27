import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('maps scaffold feature arguments to the existing tool script', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));
    final invocations = <List<String>>[];

    final result = await MobilekitCli(
      currentDirectory: repository,
      commandExecutor: (command) async {
        invocations.add(List<String>.from(command));
        return 17;
      },
    ).run(['scaffold', 'feature', 'review', '--slice', 'list', '--dry-run']);

    expect(result, 17);
    expect(invocations, [
      [
        'dart',
        'run',
        'tool/scaffold_feature.dart',
        '--feature',
        'review',
        '--slice',
        'list',
        '--dry-run',
      ],
    ]);
  });

  test('prints scaffold help without invoking the tool script', () async {
    final output = StringBuffer();
    var invoked = false;

    final result = await MobilekitCli(
      output: output,
      commandExecutor: (command) async {
        invoked = true;
        return 0;
      },
    ).run(['scaffold', 'feature', '--help']);

    expect(result, 0);
    expect(
      output.toString(),
      contains('Usage: mobilekit scaffold feature <name> [options]'),
    );
    expect(invoked, isFalse);
  });

  test(
    'maps each duplication profile to the shell-equivalent commands',
    () async {
      final cases = <List<Object>>[
        [
          ['core'],
          [
            [
              'npx',
              '--yes',
              'jscpd',
              'lib/features',
              'lib/core/foundation',
              'lib/core/runtime',
              'lib/core/infra',
              'lib/navigation',
              '--config',
              '.jscpd.json',
              '--silent',
            ],
            [
              'dart',
              'tool/filter_duplication_report.dart',
              '--report',
              '.tmp/jscpd-phase1/jscpd-report.json',
              '--allowlist',
              'tool/duplication_allowlist.json',
            ],
          ],
        ],
        [
          ['small-helpers'],
          [
            [
              'npx',
              '--yes',
              'jscpd',
              'lib/features',
              'lib/core/foundation',
              'lib/core/runtime',
              'lib/navigation',
              '--config',
              '.jscpd.small_helpers.json',
              '--silent',
            ],
            [
              'dart',
              'tool/filter_duplication_report.dart',
              '--profile',
              'small_helpers',
              '--report',
              '.tmp/jscpd-small-helpers/jscpd-report.json',
              '--allowlist',
              'tool/small_helper_duplication_allowlist.json',
            ],
          ],
        ],
        [
          ['presentation'],
          [
            [
              'npx',
              '--yes',
              'jscpd',
              'lib/features/account/presentation',
              'lib/features/auth/presentation',
              '--config',
              '.jscpd.presentation.json',
              '--silent',
            ],
            [
              'dart',
              'tool/filter_duplication_report.dart',
              '--profile',
              'presentation',
              '--report',
              '.tmp/jscpd-presentation/jscpd-report.json',
              '--allowlist',
              'tool/presentation_duplication_allowlist.json',
            ],
          ],
        ],
      ];

      for (final testCase in cases) {
        final profile = (testCase.first as List<String>).single;
        final expected = testCase.last as List<List<String>>;
        final repository = await _createRepository();
        addTearDown(() => repository.delete(recursive: true));
        Directory(
          p.join(repository.path, 'lib', 'features', 'account', 'presentation'),
        ).createSync(recursive: true);
        Directory(
          p.join(repository.path, 'lib', 'features', 'auth', 'presentation'),
        ).createSync(recursive: true);
        final invocations = <List<String>>[];

        final result = await MobilekitCli(
          currentDirectory: repository,
          commandExecutor: (command) async {
            invocations.add(List<String>.from(command));
            return 0;
          },
        ).run(['duplication', 'check', '--profile', profile]);

        expect(result, 0, reason: 'Profile: $profile');
        expect(invocations, expected);
      }
    },
  );

  test(
    'default duplication check runs core then small-helper profiles',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final invocations = <List<String>>[];

      final result = await MobilekitCli(
        currentDirectory: repository,
        commandExecutor: (command) async {
          invocations.add(List<String>.from(command));
          return 0;
        },
      ).run(['duplication', 'check']);

      expect(result, 0);
      expect(invocations.length, 4);
      expect(invocations[0].first, 'npx');
      expect(invocations[1].first, 'dart');
      expect(invocations[2].first, 'npx');
      expect(invocations[3].first, 'dart');
    },
  );

  test('rejects an invalid duplication profile', () async {
    final errors = StringBuffer();

    final result = await MobilekitCli(
      errorOutput: errors,
    ).run(['duplication', 'check', '--profile', 'unknown']);

    expect(result, 2);
    expect(errors.toString(), contains('not an allowed value'));
  });

  test(
    'rejects a presentation profile when no presentation directories exist',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final errors = StringBuffer();
      final invocations = <List<String>>[];

      final result = await MobilekitCli(
        currentDirectory: repository,
        errorOutput: errors,
        commandExecutor: (command) async {
          invocations.add(List<String>.from(command));
          return 0;
        },
      ).run(['duplication', 'check', '--profile', 'presentation']);

      expect(result, 2);
      expect(
        errors.toString(),
        contains('No presentation directories found under lib/features.'),
      );
      expect(invocations, isEmpty);
    },
  );
}

Future<Directory> _createRepository() async {
  final directory = await Directory.systemTemp.createTemp(
    'mobile_core_kit_cli_scaffold_duplication_test_',
  );
  File(
    p.join(directory.path, 'pubspec.yaml'),
  ).writeAsStringSync('name: test_repository\n');
  Directory(p.join(directory.path, 'tool')).createSync();
  return directory;
}
