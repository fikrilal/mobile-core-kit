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
