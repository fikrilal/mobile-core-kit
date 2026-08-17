import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:test/test.dart';

void main() {
  test('atomically persists and validates versioned task state', () async {
    final root = await Directory.systemTemp.createTemp('mobilekit_state_');
    addTearDown(() => root.delete(recursive: true));
    final store = FileTaskStateStore(root);
    final state = _state();

    store.create(state);
    final restored = store.read(state.taskId);

    expect(restored.taskId, state.taskId);
    expect(restored.boundaries.allowedPaths, state.boundaries.allowedPaths);
    expect(restored.preexistingChanges.single.path, 'user.txt');
  });

  test('rejects duplicate state creation and unsupported schema', () async {
    final root = await Directory.systemTemp.createTemp('mobilekit_state_');
    addTearDown(() => root.delete(recursive: true));
    final store = FileTaskStateStore(root)..create(_state());

    expect(
      () => store.create(_state()),
      throwsA(_controlError('task.state-exists')),
    );
    final stateFile = File(
      '${root.path}/.tmp/mobilekit/tasks/test-task-authority/state.json',
    );
    stateFile.writeAsStringSync('{"schemaVersion":99}\n');
    expect(
      () => store.read('test-task-authority'),
      throwsA(_controlError('task.state-invalid')),
    );
  });
}

TaskState _state() => TaskState(
  taskId: 'test-task-authority',
  lifecycle: TaskLifecycle.authorized,
  startedAt: DateTime.utc(2026, 8, 11),
  updatedAt: DateTime.utc(2026, 8, 11),
  baseRevision: _repeated('a', 40),
  planPath: 'docs/exec-plans/active/test.md',
  planSourceHash: _repeated('b', 64),
  authorityHash: _repeated('c', 64),
  declaredRisk: TaskRisk.medium,
  boundaries: const TaskBoundaries(
    allowedPaths: ['docs/exec-plans/active/test.md'],
    allowedActions: [TaskAction.verify],
    maximumRisk: TaskRisk.medium,
    repairLimit: 2,
    timeout: Duration(minutes: 30),
  ),
  impacts: const TaskImpactAreas(
    auth: false,
    navigation: false,
    api: false,
    database: false,
    platform: false,
    ui: false,
    harness: false,
    externalSystems: false,
  ),
  preexistingChanges: const [
    PreexistingChange(
      path: 'user.txt',
      sources: [ChangeSource.untracked],
      contentFingerprint:
          'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
    ),
  ],
  attemptCount: 0,
  repairCount: 0,
  repeatedFailureCount: 0,
  selectedLanes: const [],
  transitions: [
    TaskTransition(
      at: DateTime.utc(2026, 8, 11),
      from: null,
      to: TaskLifecycle.authorized,
      reason: 'task-begin',
    ),
  ],
);

String _repeated(String value, int count) => List.filled(count, value).join();

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);
