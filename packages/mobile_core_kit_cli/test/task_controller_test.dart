import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_controller.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test('selects fast for a narrow low-risk task', () async {
    final fixture = await _fixture(
      plan: taskPlanFixture(
        risk: 'low',
        impacts: validImpactFixture.replaceFirst(
          'UI/UX/accessibility: yes',
          'UI/UX/accessibility: no',
        ),
      ),
    );
    addTearDown(() => fixture.root.delete(recursive: true));

    final result = await fixture.controller.verify(
      _taskId,
      runLane: (profile, _) async {
        expect(profile, VerificationProfile.fast);
        return _passed;
      },
    );

    expect(result.profile, VerificationProfile.fast);
  });

  test('selects full for medium risk and records a verified episode', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.delete(recursive: true));

    final result = await fixture.controller.verify(
      _taskId,
      runLane: (profile, _) async {
        expect(profile, VerificationProfile.full);
        return _passed;
      },
    );

    expect(result.lifecycle, TaskLifecycle.verified);
    expect(fixture.store.read(_taskId).attemptCount, 1);
    expect(fixture.episodes.events.map((event) => event.type), [
      'verification-started',
      'verification-passed',
    ]);
  });

  test('sanitizes failure and escalates repeated unchanged attempts', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.delete(recursive: true));

    final first = await fixture.controller.verify(
      _taskId,
      runLane: (_, _) async => _failed,
    );
    expect(first.lifecycle, TaskLifecycle.failed);
    expect(first.failure!.boundary, 'format.dart');
    expect(first.failure!.diagnostic, isNot(contains('super-secret')));

    final repair = await fixture.controller.recordRepair(_taskId);
    expect(repair.candidateChanged, isFalse);
    expect(repair.repairCount, 1);

    final repeated = await fixture.controller.recordRepair(_taskId);
    expect(repeated.lifecycle, TaskLifecycle.escalated);
    expect(
      fixture.store.read(_taskId).escalationReason,
      'task.repair-budget-exhausted',
    );
  });

  test(
    'changed candidate enables one bounded repair and re-verification',
    () async {
      final fixture = await _fixture();
      addTearDown(() => fixture.root.delete(recursive: true));
      await fixture.controller.verify(
        _taskId,
        runLane: (_, _) async => _failed,
      );
      fixture.repository.worktree = const [
        RepositoryChange(
          path: 'lib/features/example/new.dart',
          sources: [ChangeSource.untracked],
        ),
      ];
      fixture.repository.fingerprints['lib/features/example/new.dart'] = _hash2;

      final repair = await fixture.controller.recordRepair(_taskId);
      expect(repair.candidateChanged, isTrue);
      expect(repair.lifecycle, TaskLifecycle.authorized);
      final verified = await fixture.controller.verify(
        _taskId,
        runLane: (_, _) async => _passed,
      );
      expect(verified.lifecycle, TaskLifecycle.verified);
    },
  );

  test('expired task escalates without executing a lane', () async {
    var clock = DateTime.utc(2026, 8, 11);
    final fixture = await _fixture(now: () => clock);
    addTearDown(() => fixture.root.delete(recursive: true));
    clock = clock.add(const Duration(hours: 7));
    var invoked = false;

    final result = await fixture.controller.verify(
      _taskId,
      runLane: (_, _) async {
        invoked = true;
        return _passed;
      },
    );

    expect(invoked, isFalse);
    expect(result.exitCode, 124);
    expect(result.lifecycle, TaskLifecycle.escalated);
    expect(result.failure!.boundary, 'controller.timeout');
  });

  test('unavailable required infrastructure escalates immediately', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.delete(recursive: true));

    final result = await fixture.controller.verify(
      _taskId,
      runLane: (_, _) =>
          throw const ProcessException('flutter', ['test'], 'not found'),
    );

    expect(result.lifecycle, TaskLifecycle.escalated);
    expect(result.failure!.boundary, 'infrastructure.unavailable');
    expect(
      fixture.store.read(_taskId).escalationReason,
      'task.infrastructure-unavailable',
    );
  });
}

const _taskId = 'test-task-authority';
const _planPath = 'docs/exec-plans/active/test.md';
const _hash2 =
    '2222222222222222222222222222222222222222222222222222222222222222';
const _passed = TaskLaneExecution(
  exitCode: 0,
  duration: Duration(milliseconds: 12),
  timedOut: false,
  diagnostic: '',
);
const _failed = TaskLaneExecution(
  exitCode: 1,
  duration: Duration(milliseconds: 12),
  timedOut: false,
  diagnostic: 'password=super-secret person@example.com',
  failedStep: VerificationStep.format,
);

Future<_ControllerFixture> _fixture({
  DateTime Function()? now,
  String? plan,
}) async {
  final clock = now ?? () => DateTime.utc(2026, 8, 11);
  final root = await Directory.systemTemp.createTemp('mobilekit_controller_');
  File(p.join(root.path, _planPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(plan ?? taskPlanFixture());
  Directory(
    p.join(root.path, 'lib/features/example'),
  ).createSync(recursive: true);
  final repository = _FakeGitRepository();
  final store = _MemoryTaskStateStore();
  final episodes = _MemoryEpisodeStore();
  final service = TaskService(
    root: root,
    repository: repository,
    stateStore: store,
    now: clock,
  );
  await service.begin(_planPath);
  return _ControllerFixture(
    root: root,
    repository: repository,
    store: store,
    episodes: episodes,
    controller: TaskController(
      service: service,
      stateStore: store,
      episodeStore: episodes,
      now: clock,
    ),
  );
}

class _ControllerFixture {
  const _ControllerFixture({
    required this.root,
    required this.repository,
    required this.store,
    required this.episodes,
    required this.controller,
  });

  final Directory root;
  final _FakeGitRepository repository;
  final _MemoryTaskStateStore store;
  final _MemoryEpisodeStore episodes;
  final TaskController controller;
}

class _FakeGitRepository implements GitRepository {
  List<RepositoryChange> worktree = const [];
  final Map<String, String> fingerprints = {};

  @override
  Future<List<RepositoryChange>> changesSince(String _) async => const [];

  @override
  Future<String> contentFingerprint(String path) async =>
      fingerprints[path] ??
      '0000000000000000000000000000000000000000000000000000000000000000';

  @override
  Future<String> head() async => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  @override
  Future<List<RepositoryChange>> worktreeChanges() async => worktree;
}

class _MemoryTaskStateStore implements TaskStateStore {
  TaskState? state;

  @override
  void create(TaskState value) => state = value;

  @override
  TaskState read(String _) => state!;

  @override
  void write(TaskState value) => state = value;
}

class _MemoryEpisodeStore implements TaskEpisodeStore {
  final List<TaskEpisodeEvent> events = [];

  @override
  void append(String _, TaskEpisodeEvent event) => events.add(event);

  @override
  TaskEpisode read(String taskId) =>
      TaskEpisode(taskId: taskId, events: events);
}
