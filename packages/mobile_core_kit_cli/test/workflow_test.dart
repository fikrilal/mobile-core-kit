import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'lint runs analyzer and custom lint through the shared executor',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final commands = <List<String>>[];

      final result = await MobilekitCli(
        currentDirectory: repository,
        commandExecutor: (command) async {
          commands.add(List<String>.from(command));
          return 0;
        },
      ).run(['lint']);

      expect(result, 0);
      expect(commands, [
        ['flutter', 'analyze'],
        ['dart', 'run', 'custom_lint'],
      ]);
    },
  );

  test(
    'verify runs migrated workflows directly and preserves the step sequence',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));
      final commands = <List<String>>[];

      final result =
          await MobilekitCli(
            currentDirectory: repository,
            commandExecutor: (command) async {
              commands.add(List<String>.from(command));
              return 0;
            },
          ).run([
            'verify',
            '--env',
            'dev',
            '--skip-duplication',
            '--skip-tests',
            '--skip-format',
          ]);

      expect(result, 0);
      expect(commands, [
        ['flutter', 'pub', 'get'],
        [
          'dart',
          'format',
          'lib/core/foundation/config/build_config_values.dart',
        ],
        ['flutter', 'gen-l10n'],
        ['flutter', 'analyze'],
        ['dart', 'run', 'custom_lint'],
      ]);
      expect(
        File(
          p.join(
            repository.path,
            'lib/core/foundation/config/build_config_values.dart',
          ),
        ).existsSync(),
        isTrue,
      );
    },
  );

  test(
    'scaffold writes generated files relative to the repository root',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));

      final result = await MobilekitCli(
        currentDirectory: repository,
      ).run(['scaffold', 'feature', 'review']);

      expect(result, 0);
      expect(
        File(
          p.join(
            repository.path,
            'lib/features/review/presentation/pages/review_page.dart',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          'lib/features/review/presentation/pages/review_page.dart',
        ).existsSync(),
        isFalse,
      );
    },
  );
}

Future<Directory> _createRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobile_core_kit_cli_workflow_test_',
  );
  File(
    p.join(repository.path, 'pubspec.yaml'),
  ).writeAsStringSync('name: test_repository\n');
  File(p.join(repository.path, '.git')).writeAsStringSync('gitdir: test\n');
  Directory(
    p.join(repository.path, 'lib/core/foundation/config'),
  ).createSync(recursive: true);
  Directory(
    p.join(repository.path, 'lib/features'),
  ).createSync(recursive: true);
  Directory(p.join(repository.path, '.tmp')).createSync(recursive: true);
  File(
    p.join(repository.path, 'AGENTS.md'),
  ).writeAsStringSync('Repository test fixture without a core project map.\n');
  File(
    p.join(repository.path, '.tmp/untranslated_messages.json'),
  ).writeAsStringSync('{}\n');

  for (final environment in ['dev', 'staging', 'prod']) {
    File(p.join(repository.path, '.env/$environment.yaml'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(_validEnvironmentYaml);
  }

  return repository;
}

const _validEnvironmentYaml = '''
core: https://core.example.com
auth: https://auth.example.com
profile: https://profile.example.com
googleOidcServerClientId: test-client
enableLogging: false
reminderExperiment: false
analyticsEnabledDefault: true
analyticsDebugLoggingEnabled: false
netLogRedact: true
netLogBodyLimitBytes: 8192
netLogLargeThresholdBytes: 65536
netLogSlowMs: 800
netLogMode: off
deepLinkAllowedHosts:
  - example.com
''';
