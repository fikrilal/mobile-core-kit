import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'scaffolds a feature directly under the discovered repository root',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final output = StringBuffer();

      final result = await MobilekitCli(
        currentDirectory: repository,
        output: output,
      ).run(['scaffold', 'feature', 'review', '--slice', 'list', '--dry-run']);

      expect(result, 0);
      expect(output.toString(), contains('Dry run: would scaffold feature'));
      expect(
        Directory(
          p.join(repository.path, 'lib', 'features', 'review'),
        ).existsSync(),
        isFalse,
      );
    },
  );

  test('prints scaffold help without invoking a legacy entrypoint', () async {
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
    'maps each duplication profile to jscpd and direct report filtering',
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
        _writeReport(repository, profile);
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
      _writeReport(repository, 'core');
      _writeReport(repository, 'small-helpers');
      final invocations = <List<String>>[];

      final result = await MobilekitCli(
        currentDirectory: repository,
        commandExecutor: (command) async {
          invocations.add(List<String>.from(command));
          return 0;
        },
      ).run(['duplication', 'check']);

      expect(result, 0);
      expect(invocations.length, 2);
      expect(invocations[0].first, 'npx');
      expect(invocations[1].first, 'npx');
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
  File(p.join(directory.path, '.mobilekit', 'template.yaml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
    );
  return directory;
}

void _writeReport(Directory repository, String profile) {
  final reportPath = switch (profile) {
    'core' => '.tmp/jscpd-phase1/jscpd-report.json',
    'small-helpers' => '.tmp/jscpd-small-helpers/jscpd-report.json',
    'presentation' => '.tmp/jscpd-presentation/jscpd-report.json',
    _ => throw ArgumentError.value(profile, 'profile'),
  };
  final reportFile = File(p.join(repository.path, reportPath))
    ..createSync(recursive: true);
  reportFile.writeAsStringSync('{"duplicates": []}');
}
