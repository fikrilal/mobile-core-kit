import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test(
    'begin captures immutable authority and pre-existing ownership',
    () async {
      final fixture = await _serviceFixture();
      addTearDown(() => fixture.root.delete(recursive: true));

      final result = await fixture.service.begin(_planPath);

      expect(result.taskId, 'test-task-authority');
      expect(result.baseRevision, _repeated('a', 40));
      expect(result.preexistingPathCount, 1);
      final state = fixture.store.read(result.taskId);
      expect(state.authorityHash, hasLength(64));
      expect(state.preexistingChanges.single.path, 'user.txt');
    },
  );

  test(
    'preflight preserves unchanged user work and rejects later scope escape',
    () async {
      final fixture = await _serviceFixture();
      addTearDown(() => fixture.root.delete(recursive: true));
      await fixture.service.begin(_planPath);

      fixture.repository.worktree = [
        const RepositoryChange(
          path: 'user.txt',
          sources: [ChangeSource.untracked],
        ),
        const RepositoryChange(
          path: 'lib/features/example/new.dart',
          sources: [ChangeSource.untracked],
        ),
      ];
      fixture.repository.fingerprints['lib/features/example/new.dart'] =
          _repeated('2', 64);
      final unchanged = await fixture.service.preflight(
        'test-task-authority',
        action: TaskAction.verify,
      );
      expect(unchanged.preexistingPaths, ['user.txt']);
      expect(unchanged.taskPaths, ['lib/features/example/new.dart']);
      expect(unchanged.classification.effectiveRisk, TaskRisk.medium);

      fixture.repository.fingerprints['user.txt'] = _repeated('3', 64);
      await expectLater(
        fixture.service.preflight(
          'test-task-authority',
          action: TaskAction.verify,
        ),
        throwsA(_controlError('task.scope-violation')),
      );
    },
  );

  test('preflight rejects scope escape and changed authority', () async {
    final fixture = await _serviceFixture();
    addTearDown(() => fixture.root.delete(recursive: true));
    await fixture.service.begin(_planPath);
    fixture.repository.worktree = [
      const RepositoryChange(
        path: 'outside.txt',
        sources: [ChangeSource.untracked],
      ),
    ];
    fixture.repository.fingerprints['outside.txt'] = _repeated('4', 64);

    await expectLater(
      fixture.service.preflight(
        'test-task-authority',
        action: TaskAction.verify,
      ),
      throwsA(_controlError('task.scope-violation')),
    );

    fixture.repository.worktree = const [];
    final planFile = File(p.join(fixture.root.path, _planPath));
    planFile.writeAsStringSync(
      taskPlanFixture(allowedActions: 'edit, verify, commit'),
    );
    await expectLater(
      fixture.service.preflight(
        'test-task-authority',
        action: TaskAction.verify,
      ),
      throwsA(_controlError('task.authority-changed')),
    );
  });

  test(
    'preflight rejects unauthorized actions and risk above ceiling',
    () async {
      final fixture = await _serviceFixture(
        plan: taskPlanFixture(risk: 'low', maximumRisk: 'low'),
      );
      addTearDown(() => fixture.root.delete(recursive: true));
      await fixture.service.begin(_planPath);

      await expectLater(
        fixture.service.preflight(
          'test-task-authority',
          action: TaskAction.commit,
        ),
        throwsA(_controlError('task.action-not-authorized')),
      );

      fixture.repository.worktree = [
        const RepositoryChange(
          path: 'lib/features/example/new.dart',
          sources: [ChangeSource.untracked],
        ),
      ];
      fixture.repository.fingerprints['lib/features/example/new.dart'] =
          _repeated('5', 64);
      await expectLater(
        fixture.service.preflight(
          'test-task-authority',
          action: TaskAction.verify,
        ),
        throwsA(_controlError('task.risk-above-authority')),
      );
    },
  );
}

const _planPath = 'docs/exec-plans/active/test.md';

Future<_ServiceFixture> _serviceFixture({String? plan}) async {
  final root = await Directory.systemTemp.createTemp('mobilekit_service_');
  File(p.join(root.path, _planPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(plan ?? taskPlanFixture());
  Directory(
    p.join(root.path, 'lib/features/example'),
  ).createSync(recursive: true);
  final repository = _FakeGitRepository(
    worktree: const [
      RepositoryChange(path: 'user.txt', sources: [ChangeSource.untracked]),
    ],
    fingerprints: {'user.txt': _repeated('1', 64)},
  );
  final store = _MemoryTaskStateStore();
  return _ServiceFixture(
    root: root,
    repository: repository,
    store: store,
    service: TaskService(
      root: root,
      repository: repository,
      stateStore: store,
      now: () => DateTime.utc(2026, 8, 11),
    ),
  );
}

class _ServiceFixture {
  const _ServiceFixture({
    required this.root,
    required this.repository,
    required this.store,
    required this.service,
  });

  final Directory root;
  final _FakeGitRepository repository;
  final _MemoryTaskStateStore store;
  final TaskService service;
}

class _FakeGitRepository implements GitRepository {
  _FakeGitRepository({required this.worktree, required this.fingerprints});

  List<RepositoryChange> worktree;
  final Map<String, String> fingerprints;
  List<RepositoryChange> committed = const [];

  @override
  Future<List<RepositoryChange>> changesSince(String _) async => committed;

  @override
  Future<String> contentFingerprint(String path) async =>
      fingerprints[path] ?? _repeated('0', 64);

  @override
  Future<String> head() async => _repeated('a', 40);

  @override
  Future<List<RepositoryChange>> worktreeChanges() async => worktree;
}

String _repeated(String value, int count) => List.filled(count, value).join();

class _MemoryTaskStateStore implements TaskStateStore {
  TaskState? state;

  @override
  void create(TaskState value) {
    if (state != null) {
      throw const TaskControlError('task.state-exists', 'exists');
    }
    state = value;
  }

  @override
  TaskState read(String taskId) {
    final value = state;
    if (value == null || value.taskId != taskId) {
      throw const TaskControlError('task.state-missing', 'missing');
    }
    return value;
  }
}

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);
