import 'dart:collection';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/template/template_manifest.dart';
import 'package:mobile_core_kit_cli/src/template/template_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('interactive dry-run does not write a project manifest', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final output = StringBuffer();
    final errors = StringBuffer();
    final answers = <String>[
      'example-app',
      'Example App',
      '',
      'com.example.app',
      'com.example.app',
      'com.example.app',
      'disabled',
      'configure',
    ];

    final result = await TemplateLifecycleWorkflow(
      WorkflowContext(
        rootDirectory: repository,
        execute: (_) async => 0,
        output: output,
        errorOutput: errors,
      ),
      inputReader: _reader(answers),
    ).run(TemplateLifecycleCommand.init, ['--dry-run']);

    expect(result, 0);
    expect(errors, isEmpty);
    expect(output.toString(), contains('mobilekit init plan'));
    expect(output.toString(), contains('changed: .mobilekit/project.yaml'));
    expect(
      output.toString(),
      contains('external: environment and external services'),
    );
    expect(output.toString(), contains('Dry run: no files were changed.'));
    expect(
      File(p.join(repository.path, projectManifestRelativePath)).existsSync(),
      isFalse,
    );
  });

  test('writes a manifest from a non-interactive config', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final config = File(p.join(repository.path, 'project-input.yaml'))
      ..writeAsStringSync(_validConfig);
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = await TemplateLifecycleWorkflow(
      WorkflowContext(
        rootDirectory: repository,
        execute: (_) async => 0,
        output: output,
        errorOutput: errors,
      ),
      inputReader: () => 'unused',
    ).run(TemplateLifecycleCommand.init, ['--config', config.path, '--yes']);

    expect(result, 0);
    expect(errors, isEmpty);
    expect(
      File(
        p.join(repository.path, projectManifestRelativePath),
      ).readAsStringSync(),
      contains('dart_package:'),
    );
    expect(output.toString(), contains('Wrote .mobilekit/project.yaml.'));
  });

  test(
    'initializes a fixture, runs valid generators, and is dry-run/idempotent',
    () async {
      final repository = await _createGenerationRepository();
      addTearDown(() => repository.delete(recursive: true));
      final config = File(p.join(repository.path, 'project-input.yaml'))
        ..writeAsStringSync(_validConfig);
      final beforeDryRun = _snapshot(repository);
      final dryRunCommands = <List<String>>[];

      final dryRunResult =
          await TemplateLifecycleWorkflow(
            WorkflowContext(
              rootDirectory: repository,
              execute: (command) async {
                dryRunCommands.add(command);
                return 0;
              },
              output: StringBuffer(),
              errorOutput: StringBuffer(),
            ),
          ).run(TemplateLifecycleCommand.init, [
            '--config',
            config.path,
            '--dry-run',
          ]);

      expect(dryRunResult, 0);
      expect(dryRunCommands, isEmpty);
      expect(_snapshot(repository), beforeDryRun);

      final commands = <List<String>>[];
      final output = StringBuffer();
      final errors = StringBuffer();
      final workflow = TemplateLifecycleWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (command) async {
            commands.add(command);
            return 0;
          },
          output: output,
          errorOutput: errors,
        ),
      );

      expect(
        await workflow.run(TemplateLifecycleCommand.init, [
          '--config',
          config.path,
          '--yes',
        ]),
        0,
        reason: '${errors.toString()}\n${output.toString()}',
      );
      final commandNames = commands.map((command) => command.join(' '));
      expect(commandNames, contains('flutter pub get'));
      expect(commandNames, contains('flutter gen-l10n'));
      expect(commandNames, contains('dart run build_runner build'));
      expect(
        File(
          p.join(
            repository.path,
            'lib/core/foundation/config/build_config_values.dart',
          ),
        ).existsSync(),
        isTrue,
      );

      final existingManifest = File(
        p.join(repository.path, projectManifestRelativePath),
      ).readAsStringSync();
      final secondCommands = <List<String>>[];
      final secondResult =
          await TemplateLifecycleWorkflow(
            WorkflowContext(
              rootDirectory: repository,
              execute: (command) async {
                secondCommands.add(command);
                return 0;
              },
              output: StringBuffer(),
              errorOutput: errors,
            ),
          ).run(TemplateLifecycleCommand.customize, [
            '--config',
            config.path,
            '--yes',
          ]);

      expect(secondResult, 0);
      expect(secondCommands, isEmpty);
      expect(
        File(
          p.join(repository.path, projectManifestRelativePath),
        ).readAsStringSync(),
        existingManifest,
      );
    },
  );

  test('fixture customization stops on a managed-file conflict', () async {
    final repository = await _createGenerationRepository();
    addTearDown(() => repository.delete(recursive: true));
    final config = File(p.join(repository.path, 'project-input.yaml'))
      ..writeAsStringSync(_validConfig);
    final errors = StringBuffer();
    final workflow = TemplateLifecycleWorkflow(
      WorkflowContext(
        rootDirectory: repository,
        execute: (_) async => 0,
        output: StringBuffer(),
        errorOutput: errors,
      ),
    );

    expect(
      await workflow.run(TemplateLifecycleCommand.init, [
        '--config',
        config.path,
        '--yes',
      ]),
      0,
    );
    final manifestBefore = File(
      p.join(repository.path, projectManifestRelativePath),
    ).readAsStringSync();
    File(
      p.join(repository.path, 'README.md'),
    ).writeAsStringSync('# user-owned-heading\n');

    final result = await workflow.run(TemplateLifecycleCommand.customize, [
      '--config',
      config.path,
      '--yes',
    ]);

    expect(result, 1);
    expect(errors.toString(), contains('conflicts'));
    expect(
      File(
        p.join(repository.path, projectManifestRelativePath),
      ).readAsStringSync(),
      manifestBefore,
    );
  });

  test('requires init before interactive customization', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final errors = StringBuffer();
    final result = await TemplateLifecycleWorkflow(
      WorkflowContext(
        rootDirectory: repository,
        execute: (_) async => 0,
        errorOutput: errors,
      ),
      inputReader: () => null,
    ).run(TemplateLifecycleCommand.customize, const []);

    expect(result, 1);
    expect(
      errors.toString(),
      contains('No project manifest found. Run mobilekit init first.'),
    );
  });

  test('does not overwrite an invalid existing manifest', () async {
    final repository = await _createRepository();
    addTearDown(() => repository.delete(recursive: true));

    final manifest = File(p.join(repository.path, projectManifestRelativePath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('schema: 99\n');
    final errors = StringBuffer();

    final result = await TemplateLifecycleWorkflow(
      WorkflowContext(
        rootDirectory: repository,
        execute: (_) async => 0,
        errorOutput: errors,
      ),
      inputReader: () => null,
    ).run(TemplateLifecycleCommand.init, const []);

    expect(result, 1);
    expect(errors.toString(), contains('Invalid project manifest'));
    expect(manifest.readAsStringSync(), 'schema: 99\n');
  });

  test(
    'interactive input is normalized and written after confirmation',
    () async {
      final repository = await _createRepository();
      addTearDown(() => repository.delete(recursive: true));

      final answers = <String>[
        'Example-App',
        'Example App',
        '',
        'Com.Example.App',
        'Com.Example.App',
        'Com.Example.App',
        'disabled',
        'disabled',
        'yes',
      ];
      final output = StringBuffer();
      final errors = StringBuffer();

      final result = await TemplateLifecycleWorkflow(
        WorkflowContext(
          rootDirectory: repository,
          execute: (_) async => 0,
          output: output,
          errorOutput: errors,
        ),
        inputReader: _reader(answers),
      ).run(TemplateLifecycleCommand.init, const []);

      expect(result, 0);
      expect(errors, isEmpty);

      final manifest = File(
        p.join(repository.path, projectManifestRelativePath),
      ).readAsStringSync();
      expect(manifest, contains("slug: 'example-app'"));
      expect(manifest, contains("dart_package: 'example_app'"));
      expect(manifest, contains("application_id: 'com.example.app'"));
      expect(output.toString(), contains('Wrote .mobilekit/project.yaml.'));
    },
  );
}

Future<Directory> _createRepository() async {
  final repository = await Directory.systemTemp.createTemp(
    'mobilekit_template_workflow_test_',
  );
  File(p.join(repository.path, 'pubspec.yaml')).writeAsStringSync('''
name: mobile_core_kit
description: 'A new Flutter project.'
''');
  final marker = File(p.join(repository.path, templateMarkerRelativePath))
    ..parent.createSync(recursive: true);
  marker.writeAsStringSync('''
schema: 1
template: mobile_core_kit
version: 2026-08-01
''');
  return repository;
}

Future<Directory> _createGenerationRepository() async {
  final repository = await _createRepository();
  File(p.join(repository.path, 'pubspec.yaml')).writeAsStringSync('''
name: mobile_core_kit
description: 'A new Flutter project.'
dev_dependencies:
  build_runner: ^2.12.2
''');
  File(
    p.join(repository.path, 'README.md'),
  ).writeAsStringSync('# mobile-core-kit\n');
  File(p.join(repository.path, 'lib', 'l10n', 'app_en.arb'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('''
{
  "appTitle": "Mobile Core Kit"
}
''');
  File(p.join(repository.path, '.env', 'dev.yaml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(_validEnvironment);
  Directory(
    p.join(repository.path, 'lib', 'core', 'foundation', 'config'),
  ).createSync(recursive: true);
  return repository;
}

TemplateInputReader _reader(List<String> answers) {
  final queue = ListQueue<String>.from(answers);
  return () => queue.isEmpty ? null : queue.removeFirst();
}

const _validConfig = '''
schema: 1
template: mobile_core_kit
repository:
  slug: example-app
  description: Example App
app:
  display_name: Example App
  dart_package: example_app
platforms:
  android:
    namespace: com.example.app
    application_id: com.example.app
    flavor_suffixes:
      dev: .dev
      staging: .staging
  ios:
    bundle_id: com.example.app
    test_bundle_id: com.example.app.runnertests
deep_links:
  mode: disabled
firebase:
  mode: configure
environment:
  examples_updated: false
''';

const _validEnvironment = '''
core: https://api.example.test/v1
auth: https://api.example.test/v1
profile: https://api.example.test/v1
enableLogging: true
reminderExperiment: false
analyticsEnabledDefault: true
analyticsDebugLoggingEnabled: true
googleOidcServerClientId: example.apps.googleusercontent.com
deepLinkAllowedHosts: []
netLogMode: full
netLogBodyLimitBytes: 8192
netLogLargeThresholdBytes: 65536
netLogSlowMs: 800
netLogRedact: true
''';

Map<String, String> _snapshot(Directory root) {
  final result = <String, String>{};
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File) {
      result[p.relative(entity.path, from: root.path)] = entity
          .readAsStringSync();
    }
  }
  return result;
}
