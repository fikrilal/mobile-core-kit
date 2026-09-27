import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/handoff/completion_evidence.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('maestro-flow uses runtime evidence, not manual attestation', () async {
    final root = await Directory.systemTemp.createTemp('completion_maestro_');
    addTearDown(() => root.delete(recursive: true));
    File(p.join(root.path, 'maestro', 'login.yaml'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('appId: example\n');
    File(p.join(root.path, 'harness', 'oracles.yaml'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('''
schemaVersion: 1
oracles:
  auth.journey:
    kind: maestro-flow
    target: maestro/login.yaml
    covers: [auth, ui]
    logSignals:
      - id: login-succeeded
        contains: "POST /auth/password/login → 2"
''');
    final controlRoot = Directory(p.join(root.path, '.tmp', 'mobilekit'));
    controlRoot.createSync(recursive: true);
    final reader = CompletionEvidenceReader(
      root: root,
      controlRoot: controlRoot,
    );
    final state = _state();

    expect(reader.read(state).outstanding.single, contains('auth.journey'));

    _writeManifest(root, passed: true);
    expect(reader.read(state).ready, isTrue);

    _writeManifest(root, passed: false);
    expect(reader.read(state).ready, isFalse);
  });
}

TaskState _state() => TaskState(
  oracleIds: const ['auth.journey'],
  taskId: 'completion-task',
  lifecycle: TaskLifecycle.verified,
  startedAt: DateTime.utc(2026, 9, 8),
  updatedAt: DateTime.utc(2026, 9, 8),
  baseRevision: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  planPath: 'docs/exec-plans/active/completion.md',
  planSourceHash:
      '1111111111111111111111111111111111111111111111111111111111111111',
  authorityHash:
      '2222222222222222222222222222222222222222222222222222222222222222',
  declaredRisk: TaskRisk.high,
  boundaries: const TaskBoundaries(
    allowedPaths: ['docs/exec-plans/active/completion.md'],
    allowedActions: [TaskAction.verify],
    maximumRisk: TaskRisk.high,
    repairLimit: 2,
    timeout: Duration(hours: 1),
  ),
  impacts: const TaskImpactAreas(
    auth: true,
    navigation: false,
    api: false,
    database: false,
    platform: false,
    ui: true,
    harness: false,
    externalSystems: false,
  ),
  preexistingChanges: const [],
  attemptCount: 1,
  repairCount: 0,
  repeatedFailureCount: 0,
  selectedLanes: const ['full'],
  transitions: const [],
  lastTaskFingerprint:
      '5555555555555555555555555555555555555555555555555555555555555555',
);

void _writeManifest(Directory root, {required bool passed}) {
  const content = 'summary\n';
  File(p.join(root.path, '_artifacts', 'mobile', 'run', 'summary.md'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(content);
  File(
    p.join(root.path, '_artifacts', 'mobile', 'run', 'evidence.json'),
  ).writeAsStringSync(
    jsonEncode({
      'schemaVersion': 1,
      'task': {
        'id': 'completion-task',
        'planPath': 'docs/exec-plans/active/completion.md',
        'planSourceHash':
            '1111111111111111111111111111111111111111111111111111111111111111',
        'authorityHash':
            '2222222222222222222222222222222222222222222222222222222222222222',
        'baseRevision': 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        'candidateRevision': 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        'fingerprint':
            '5555555555555555555555555555555555555555555555555555555555555555',
        'oracleIds': ['auth.journey'],
      },
      'run': {
        'finishedAt': '2026-09-08T00:00:00Z',
        'outcome': passed ? 'passed' : 'failed',
        'exitCode': passed ? 0 : 1,
      },
      'results': [
        {
          'oracleId': 'auth.journey',
          'target': 'maestro/login.yaml',
          'outcome': passed ? 'passed' : 'failed',
          'exitCode': passed ? 0 : 1,
        },
      ],
      'artifacts': [
        {
          'path': '_artifacts/mobile/run/summary.md',
          'sha256': sha256String(content),
          'sizeBytes': content.length,
          'durability': 'durable-summary',
        },
      ],
    }),
  );
}
