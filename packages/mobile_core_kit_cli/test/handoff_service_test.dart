import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/handoff/handoff_approval.dart';
import 'package:mobile_core_kit_cli/src/handoff/handoff_service.dart';
import 'package:mobile_core_kit_cli/src/handoff/publication_adapter.dart';
import 'package:mobile_core_kit_cli/src/policy/risk_classifier.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'dry-run binds a private expiring approval without mutating Git',
    () async {
      final fixture = _fixture(TaskAction.commit);
      addTearDown(() => fixture.root.deleteSync(recursive: true));

      final result = await fixture.service.dryRun(_taskId, TaskAction.commit);

      expect(result.challenge, _challenge);
      expect(result.changedPaths, [_taskPath]);
      expect(result.expiresAt, DateTime.utc(2026, 8, 12, 0, 15));
      expect(fixture.adapter.mutations, isEmpty);
      final stored = fixture.approvals.read(_taskId, TaskAction.commit)!;
      expect(stored.challengeHash, sha256String(_challenge));
      expect(jsonEncode(stored.toJson()), isNot(contains(_challenge)));
    },
  );

  test(
    'commit stages exactly verified paths and consumes its approval',
    () async {
      final fixture = _fixture(TaskAction.commit);
      addTearDown(() => fixture.root.deleteSync(recursive: true));
      await fixture.service.dryRun(_taskId, TaskAction.commit);

      final result = await fixture.service.commit(
        _taskId,
        _challenge,
        'feat(harness): publish verified fixture',
      );

      expect(result.outcome, _revision);
      expect(fixture.adapter.mutations, [
        'stage:$_taskPath',
        'commit:feat(harness): publish verified fixture',
      ]);
      expect(
        fixture.approvals.read(_taskId, TaskAction.commit)!.status,
        HandoffStatus.completed,
      );
      await expectLater(
        fixture.service.commit(_taskId, _challenge, 'feat: retry'),
        throwsA(_controlError('handoff.approval-missing')),
      );
    },
  );

  test('push and draft PR require separate clean approvals', () async {
    final fixture = _fixture(TaskAction.push, clean: true);
    addTearDown(() => fixture.root.deleteSync(recursive: true));
    await fixture.service.dryRun(_taskId, TaskAction.push);
    final pushed = await fixture.service.push(_taskId, _challenge);
    expect(pushed.outcome, _revision);
    expect(fixture.adapter.mutations, ['push:agent/task-fixture']);

    fixture.action = TaskAction.draftPr;
    await fixture.service.dryRun(_taskId, TaskAction.draftPr);
    final drafted = await fixture.service.draftPr(
      _taskId,
      _challenge,
      base: 'main',
      title:
          'Establish the Mobile Agent Harness and Controlled Engineering Loops',
    );
    expect(drafted.outcome, 'https://github.com/example/mobile/pull/7');
    expect(
      fixture.adapter.mutations.last,
      startsWith('draft:agent/task-fixture:main:'),
    );
  });

  test('expired, stale, dirty, and pre-staged handoffs fail closed', () async {
    var clock = DateTime.utc(2026, 8, 12);
    final expired = _fixture(TaskAction.commit, now: () => clock);
    addTearDown(() => expired.root.deleteSync(recursive: true));
    await expired.service.dryRun(_taskId, TaskAction.commit);
    clock = clock.add(const Duration(minutes: 15));
    await expectLater(
      expired.service.commit(_taskId, _challenge, 'feat: expired'),
      throwsA(_controlError('handoff.approval-expired')),
    );

    final stale = _fixture(TaskAction.commit);
    addTearDown(() => stale.root.deleteSync(recursive: true));
    stale.fingerprint = _otherFingerprint;
    await expectLater(
      stale.service.dryRun(_taskId, TaskAction.commit),
      throwsA(_controlError('handoff.verification-stale')),
    );

    final staged = _fixture(TaskAction.commit);
    addTearDown(() => staged.root.deleteSync(recursive: true));
    staged.adapter.stagedPaths = [_taskPath];
    await expectLater(
      staged.service.dryRun(_taskId, TaskAction.commit),
      throwsA(_controlError('handoff.prestaged-paths')),
    );

    final dirtyPush = _fixture(TaskAction.push);
    addTearDown(() => dirtyPush.root.deleteSync(recursive: true));
    await expectLater(
      dirtyPush.service.dryRun(_taskId, TaskAction.push),
      throwsA(_controlError('handoff.checkout-dirty')),
    );
  });

  test('ambiguous external failure is recorded and never replayed', () async {
    final fixture = _fixture(TaskAction.push, clean: true);
    addTearDown(() => fixture.root.deleteSync(recursive: true));
    fixture.adapter.failPush = true;
    await fixture.service.dryRun(_taskId, TaskAction.push);

    await expectLater(
      fixture.service.push(_taskId, _challenge),
      throwsA(_controlError('handoff.outcome-uncertain')),
    );
    expect(
      fixture.approvals.read(_taskId, TaskAction.push)!.status,
      HandoffStatus.uncertain,
    );
    await expectLater(
      fixture.service.push(_taskId, _challenge),
      throwsA(_controlError('handoff.approval-missing')),
    );
    expect(
      fixture.adapter.mutations.where((value) => value.startsWith('push:')),
      hasLength(1),
    );
  });

  test('file approvals are strict, bounded, and owner-only', () {
    final root = Directory.systemTemp.createTempSync(
      'mobilekit_handoff_store_',
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final store = FileHandoffApprovalStore(root);
    final approval = _approval();
    store.write(approval);
    final path = File(
      p.join(root.path, '.tmp/mobilekit/tasks/$_taskId/handoff/commit.json'),
    );
    expect(store.read(_taskId, TaskAction.commit)!.taskId, _taskId);
    if (!Platform.isWindows) {
      expect(FileStat.statSync(path.path).mode & 0x1ff, 0x180); // 0600
    }
    final decoded = (jsonDecode(path.readAsStringSync()) as Map)
        .cast<String, Object?>();
    decoded['model'] = 'codex';
    path.writeAsStringSync(jsonEncode(decoded));
    expect(
      () => store.read(_taskId, TaskAction.commit),
      throwsA(_controlError('handoff.approval-invalid')),
    );
  });

  test('normalizes credential-free remotes and rejects protected branches', () {
    expect(
      normalizePublicationRemote('git@github.com:example/mobile.git'),
      'github.com/example/mobile',
    );
    expect(
      normalizePublicationRemote('https://github.com/example/mobile.git'),
      'github.com/example/mobile',
    );
    expect(
      () => normalizePublicationRemote(
        'https://token@github.com/example/mobile.git',
      ),
      throwsA(_controlError('handoff.remote-invalid')),
    );
    expect(
      () => validatePublicationBranch('main'),
      throwsA(_controlError('handoff.branch-invalid')),
    );
  });
}

const _taskId = 'handoff-fixture-task';
const _taskPath = 'lib/features/example/change.dart';
const _fingerprint =
    '1111111111111111111111111111111111111111111111111111111111111111';
const _otherFingerprint =
    '2222222222222222222222222222222222222222222222222222222222222222';
const _authority =
    '3333333333333333333333333333333333333333333333333333333333333333';
const _challenge =
    '4444444444444444444444444444444444444444444444444444444444444444';
const _revision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

_HandoffFixture _fixture(
  TaskAction action, {
  bool clean = false,
  DateTime Function()? now,
}) {
  final root = Directory.systemTemp.createTempSync('mobilekit_handoff_');
  final states = _MemoryStateStore(_state());
  final episodes = _MemoryEpisodeStore(_episode());
  final approvals = _MemoryApprovalStore();
  final adapter = _FakePublicationAdapter(clean: clean);
  late _HandoffFixture fixture;
  fixture = _HandoffFixture(
    root: root,
    states: states,
    approvals: approvals,
    adapter: adapter,
    action: action,
  );
  fixture.service = HandoffService(
    root: root,
    controlRoot: root,
    states: states,
    episodes: episodes,
    approvals: approvals,
    adapter: adapter,
    preflight: (_, requested) async {
      expect(requested, fixture.action);
      return _preflight(requested, fixture.fingerprint);
    },
    now: now ?? () => DateTime.utc(2026, 8, 12),
    challenge: () => _challenge,
  );
  return fixture;
}

TaskState _state() => TaskState(
  taskId: _taskId,
  lifecycle: TaskLifecycle.verified,
  startedAt: DateTime.utc(2026, 8, 12),
  updatedAt: DateTime.utc(2026, 8, 12),
  baseRevision: _revision,
  planPath: 'docs/exec-plans/active/handoff.md',
  planSourceHash: _fingerprint,
  authorityHash: _authority,
  declaredRisk: TaskRisk.high,
  boundaries: const TaskBoundaries(
    allowedPaths: [_taskPath],
    allowedActions: [TaskAction.commit, TaskAction.push, TaskAction.draftPr],
    maximumRisk: TaskRisk.high,
    repairLimit: 2,
    timeout: Duration(hours: 1),
  ),
  impacts: const TaskImpactAreas(
    auth: false,
    navigation: false,
    api: false,
    database: false,
    platform: false,
    ui: false,
    harness: true,
    externalSystems: true,
  ),
  preexistingChanges: const [],
  attemptCount: 1,
  repairCount: 0,
  repeatedFailureCount: 0,
  selectedLanes: const ['full'],
  transitions: const [],
  lastTaskFingerprint: _fingerprint,
);

TaskEpisode _episode() => TaskEpisode(
  taskId: _taskId,
  events: [
    TaskEpisodeEvent(
      at: DateTime.utc(2026, 8, 12),
      type: 'verification-passed',
      status: 'verified',
      summary: 'Full verification passed.',
      taskFingerprint: _fingerprint,
    ),
  ],
);

TaskPreflightResult _preflight(TaskAction action, String fingerprint) =>
    TaskPreflightResult(
      taskId: _taskId,
      action: action,
      taskPaths: const [_taskPath],
      preexistingPaths: const [],
      classification: const RiskClassification(
        effectiveRisk: TaskRisk.high,
        pathRisk: TaskRisk.high,
        declaredRisk: TaskRisk.high,
        paths: [_taskPath],
        reasons: [],
      ),
      taskFingerprint: fingerprint,
    );

HandoffApproval _approval() => HandoffApproval(
  taskId: _taskId,
  action: TaskAction.commit,
  status: HandoffStatus.prepared,
  taskFingerprint: _fingerprint,
  authorityHash: _authority,
  attempt: 1,
  branch: 'agent/task-fixture',
  remote: 'github.com/example/mobile',
  changedPaths: const [_taskPath],
  challengeHash: sha256String(_challenge),
  preparedAt: DateTime.utc(2026, 8, 12),
  expiresAt: DateTime.utc(2026, 8, 12, 0, 15),
);

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);

class _HandoffFixture {
  _HandoffFixture({
    required this.root,
    required this.states,
    required this.approvals,
    required this.adapter,
    required this.action,
  });

  final Directory root;
  final _MemoryStateStore states;
  final _MemoryApprovalStore approvals;
  final _FakePublicationAdapter adapter;
  late HandoffService service;
  TaskAction action;
  String fingerprint = _fingerprint;
}

class _MemoryStateStore implements TaskStateStore {
  _MemoryStateStore(this.state);

  TaskState state;

  @override
  void create(TaskState state) => throw UnimplementedError();

  @override
  TaskState read(String taskId) => state;

  @override
  void write(TaskState state) => this.state = state;
}

class _MemoryEpisodeStore implements TaskEpisodeStore {
  _MemoryEpisodeStore(this.episode);

  final TaskEpisode episode;

  @override
  void append(String taskId, TaskEpisodeEvent event) =>
      throw UnimplementedError();

  @override
  TaskEpisode read(String taskId) => episode;
}

class _MemoryApprovalStore implements HandoffApprovalStore {
  final Map<String, HandoffApproval> values = {};

  @override
  HandoffApproval? read(String taskId, TaskAction action) =>
      values['$taskId:${action.label}'];

  @override
  void write(HandoffApproval approval) {
    values['${approval.taskId}:${approval.action.label}'] = approval;
  }
}

class _FakePublicationAdapter implements PublicationAdapter {
  _FakePublicationAdapter({required bool clean})
    : worktreePaths = clean ? [] : [_taskPath];

  List<String> stagedPaths = [];
  List<String> worktreePaths;
  final List<String> mutations = [];
  bool failPush = false;

  @override
  Future<String> commit(String message) async {
    mutations.add('commit:$message');
    stagedPaths = [];
    worktreePaths = [];
    return _revision;
  }

  @override
  Future<String> createDraftPr({
    required String branch,
    required String base,
    required String title,
    required String bodyPath,
  }) async {
    expect(File(bodyPath).existsSync(), isTrue);
    mutations.add('draft:$branch:$base:$title');
    return 'https://github.com/example/mobile/pull/7';
  }

  @override
  Future<PublicationRepositoryState> inspect() async =>
      PublicationRepositoryState(
        branch: 'agent/task-fixture',
        remote: 'github.com/example/mobile',
        head: _revision,
        stagedPaths: [...stagedPaths],
        worktreePaths: [...worktreePaths],
      );

  @override
  Future<String> push(String branch) async {
    mutations.add('push:$branch');
    if (failPush) throw StateError('ambiguous');
    return _revision;
  }

  @override
  Future<void> stage(List<String> paths) async {
    mutations.add('stage:${paths.join(',')}');
    stagedPaths = [...paths];
  }
}
