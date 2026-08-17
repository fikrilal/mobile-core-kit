import 'dart:io';

import 'package:mobile_core_kit_cli/mobile_core_kit_cli.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_result.dart';
import 'package:mobile_core_kit_cli/src/workflows/verify_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
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

      final result = await MobilekitCli(
        currentDirectory: repository,
        commandExecutor: (command) async {
          commands.add(List<String>.from(command));
          return 0;
        },
      ).run(['verify', '--profile', 'fast', '--env', 'dev']);

      expect(result, 0);
      expect(commands, [
        ['flutter', 'pub', 'get'],
        [
          'dart',
          'format',
          'lib/core/foundation/config/build_config_values.dart',
        ],
        ['flutter', 'gen-l10n'],
        ['dart', 'format', '--output', 'none', '--set-exit-if-changed', '.'],
        ['flutter', 'analyze'],
        ['dart', 'run', 'custom_lint'],
        ['dart', 'test', 'packages/mobile_core_kit_cli/test'],
        ['dart', 'test', 'packages/mobile_core_kit_lints/test'],
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

  test('verify reports structured fail-fast step outcomes', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));
    final outcomes = <VerificationStepOutcome>[];
    final context = WorkflowContext(
      rootDirectory: repository,
      execute: (_) async => 17,
      output: StringBuffer(),
      errorOutput: StringBuffer(),
    );

    final result = await VerifyWorkflow(
      context,
      observer: outcomes.add,
    ).run(['--profile', 'fast']);

    expect(result, 17);
    expect(outcomes, hasLength(1));
    expect(outcomes.single.step, VerificationStep.dependencies);
    expect(outcomes.single.exitCode, 17);
  });

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

  test('runtime profile delegates options to runtime evidence owner', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));
    final arguments = <String>[];
    final context = WorkflowContext(
      rootDirectory: repository,
      execute: (_) async => 0,
      output: StringBuffer(),
      errorOutput: StringBuffer(),
    );

    final result =
        await VerifyWorkflow(
          context,
          runtimeVerification: (received) async {
            arguments.addAll(received);
            return 0;
          },
        ).run([
          '--profile',
          'runtime',
          '--env',
          'staging',
          '--device',
          'emulator-5554',
          '--target',
          'integration_test/auth_happy_path_test.dart',
          '--artifacts-dir',
          '_artifacts/test',
        ]);

    expect(result, 0);
    expect(arguments, [
      '--device',
      'emulator-5554',
      '--flavor',
      'staging',
      '--target',
      'integration_test/auth_happy_path_test.dart',
      '--artifacts-dir',
      '_artifacts/test',
    ]);
  });
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
  File(p.join(repository.path, 'AGENTS.md')).writeAsStringSync('''
```text
lib/
├─ core/
│  └─ foundation/
├─ features/
└─ navigation/
```
''');
  File(p.join(repository.path, '.github/workflows/android.yml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('mobilekit verify --profile ci\n');
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
