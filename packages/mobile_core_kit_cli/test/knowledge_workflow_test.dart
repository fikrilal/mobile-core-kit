import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/knowledge_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('accepts an aligned map, valid plan, and valid local links', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.delete(recursive: true));
    final errors = StringBuffer();

    final result = await KnowledgeWorkflow(
      _context(fixture, errors: errors),
    ).run(const []);

    expect(result, 0);
    expect(errors, isEmpty);
  });

  test('fails instead of skipping a missing project map', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.delete(recursive: true));
    File(p.join(fixture.path, 'AGENTS.md')).writeAsStringSync('No map.\n');
    final errors = StringBuffer();

    final result = await KnowledgeWorkflow(
      _context(fixture, errors: errors),
    ).run(const []);

    expect(result, 1);
    expect(errors.toString(), contains('required `lib/core` project map'));
  });

  test('fails on a broken normative Markdown link', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.delete(recursive: true));
    File(
      p.join(fixture.path, 'docs', 'README.md'),
    ).writeAsStringSync('[missing](not_here.md)\n');
    final errors = StringBuffer();

    final result = await KnowledgeWorkflow(
      _context(fixture, errors: errors),
    ).run(const []);

    expect(result, 1);
    expect(errors.toString(), contains('links to missing path'));
  });

  test('fails when active plan metadata contradicts its directory', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.delete(recursive: true));
    File(
      p.join(fixture.path, 'docs', 'exec-plans', 'active', 'task.md'),
    ).writeAsStringSync(
      _plan.replaceFirst('Status: active', 'Status: completed'),
    );
    final errors = StringBuffer();

    final result = await KnowledgeWorkflow(
      _context(fixture, errors: errors),
    ).run(const []);

    expect(result, 1);
    expect(errors.toString(), contains('stored under `active/`'));
  });

  test('fails when CI bypasses the canonical profile owner', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.delete(recursive: true));
    File(
      p.join(fixture.path, '.github', 'workflows', 'android.yml'),
    ).writeAsStringSync('run: flutter test\n');
    final errors = StringBuffer();

    final result = await KnowledgeWorkflow(
      _context(fixture, errors: errors),
    ).run(const []);

    expect(result, 1);
    expect(errors.toString(), contains('mobilekit verify --profile ci'));
  });
}

WorkflowContext _context(Directory root, {required StringSink errors}) {
  return WorkflowContext(
    rootDirectory: root,
    execute: (_) async => 0,
    output: StringBuffer(),
    errorOutput: errors,
  );
}

Future<Directory> _fixture() async {
  final root = await Directory.systemTemp.createTemp('mobilekit_knowledge_');
  Directory(
    p.join(root.path, 'lib', 'core', 'foundation'),
  ).createSync(recursive: true);
  Directory(p.join(root.path, 'lib', 'core', 'runtime')).createSync();
  File(p.join(root.path, 'AGENTS.md')).writeAsStringSync(_agents);
  File(
    p.join(root.path, 'README.md'),
  ).writeAsStringSync('[Documentation](docs/README.md)\n');
  File(p.join(root.path, 'docs', 'README.md'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('Documentation.\n');
  File(p.join(root.path, 'docs', 'exec-plans', 'active', 'task.md'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(_plan);
  File(p.join(root.path, '.github', 'workflows', 'android.yml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      'run: dart run mobile_core_kit_cli:mobilekit verify --profile ci\n',
    );
  return root;
}

const _agents = '''
# Agent contract

```text
lib/
├─ core/
│  ├─ foundation/
│  └─ runtime/
├─ features/
└─ navigation/
```
''';

const _plan = '''
# Task

Date: 2026-08-10
Owner: Codex
Status: active
Risk class: low
Related issue/PR: N/A
''';
