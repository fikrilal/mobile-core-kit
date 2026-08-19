import 'dart:io';
import 'dart:math';

import 'package:mobile_core_kit_cli/src/handoff/handoff_approval.dart';
import 'package:mobile_core_kit_cli/src/handoff/publication_adapter.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/private_artifact.dart';
import 'package:mobile_core_kit_cli/src/task/repository_mutation_lock.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;

class HandoffDryRunResult {
  const HandoffDryRunResult({
    required this.taskId,
    required this.action,
    required this.attempt,
    required this.branch,
    required this.remote,
    required this.changedPaths,
    required this.expiresAt,
    required this.challenge,
  });

  final String taskId;
  final TaskAction action;
  final int attempt;
  final String branch;
  final String remote;
  final List<String> changedPaths;
  final DateTime expiresAt;
  final String challenge;
}

class HandoffMutationResult {
  const HandoffMutationResult({
    required this.taskId,
    required this.action,
    required this.outcome,
  });

  final String taskId;
  final TaskAction action;
  final String outcome;
}

typedef HandoffPreflight =
    Future<TaskPreflightResult> Function(String taskId, TaskAction action);

class HandoffService {
  HandoffService({
    required this.root,
    required this.controlRoot,
    TaskStateStore? states,
    TaskEpisodeStore? episodes,
    HandoffApprovalStore? approvals,
    HandoffPreflight? preflight,
    PublicationAdapter? adapter,
    RepositoryMutationLock? lock,
    DateTime Function()? now,
    String Function()? challenge,
  }) : states = states ?? FileTaskStateStore(controlRoot),
       episodes = episodes ?? FileTaskEpisodeStore(controlRoot),
       approvals = approvals ?? FileHandoffApprovalStore(controlRoot),
       preflight =
           preflight ??
           ((taskId, action) => TaskService(
             root: root,
             stateStore: states ?? FileTaskStateStore(controlRoot),
           ).preflight(taskId, action: action)),
       adapter = adapter ?? NativePublicationAdapter(root),
       lock = lock ?? RepositoryMutationLock(controlRoot),
       now = now ?? DateTime.now,
       challenge = challenge ?? _secureChallenge;

  static const approvalLifetime = Duration(minutes: 15);

  final Directory root;
  final Directory controlRoot;
  final TaskStateStore states;
  final TaskEpisodeStore episodes;
  final HandoffApprovalStore approvals;
  final HandoffPreflight preflight;
  final PublicationAdapter adapter;
  final RepositoryMutationLock lock;
  final DateTime Function() now;
  final String Function() challenge;

  Future<HandoffDryRunResult> dryRun(String taskId, TaskAction action) {
    _requirePublicationAction(action);
    return lock.protect(() async {
      final existing = approvals.read(taskId, action);
      if (existing != null && existing.status != HandoffStatus.prepared) {
        throw TaskControlError(
          'handoff.action-already-started',
          "Handoff '${action.label}' already reached ${existing.status.name}.",
        );
      }
      final fresh = await _fresh(taskId, action);
      _assertRepositoryShape(action, fresh);
      final value = challenge();
      if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(value)) {
        throw const TaskControlError(
          'handoff.challenge-invalid',
          'Handoff challenge generator returned an invalid value.',
        );
      }
      final preparedAt = now().toUtc();
      final approval = HandoffApproval(
        taskId: taskId,
        action: action,
        status: HandoffStatus.prepared,
        taskFingerprint: fresh.preflight.taskFingerprint,
        authorityHash: fresh.state.authorityHash,
        attempt: fresh.state.attemptCount,
        branch: fresh.repository.branch,
        remote: fresh.repository.remote,
        changedPaths: fresh.preflight.taskPaths,
        challengeHash: sha256String(value),
        preparedAt: preparedAt,
        expiresAt: preparedAt.add(approvalLifetime),
      );
      approvals.write(approval);
      return HandoffDryRunResult(
        taskId: taskId,
        action: action,
        attempt: approval.attempt,
        branch: approval.branch,
        remote: approval.remote,
        changedPaths: approval.changedPaths,
        expiresAt: approval.expiresAt,
        challenge: value,
      );
    });
  }

  Future<HandoffMutationResult> commit(
    String taskId,
    String approval,
    String message,
  ) {
    validatePublicationText(message, 'commit message');
    return _execute(taskId, TaskAction.commit, approval, (fresh) async {
      await adapter.stage(fresh.preflight.taskPaths);
      final staged = await adapter.inspect();
      _assertSamePaths(staged.stagedPaths, fresh.preflight.taskPaths, 'staged');
      final revision = await adapter.commit(message);
      final completed = await adapter.inspect();
      _assertClean(completed);
      return revision;
    });
  }

  Future<HandoffMutationResult> push(String taskId, String approval) =>
      _execute(taskId, TaskAction.push, approval, (fresh) async {
        _assertClean(fresh.repository);
        return adapter.push(fresh.repository.branch);
      });

  Future<HandoffMutationResult> draftPr(
    String taskId,
    String approval, {
    required String base,
    required String title,
  }) {
    validatePublicationBase(base);
    validatePublicationText(title, 'pull request title');
    return _execute(taskId, TaskAction.draftPr, approval, (fresh) async {
      _assertClean(fresh.repository);
      final body = File(
        p.join(
          controlRoot.path,
          '.tmp',
          'mobilekit',
          'tasks',
          taskId,
          'handoff',
          'draft-pr-body.md',
        ),
      );
      writePrivateFile(body, _draftBody(fresh));
      return adapter.createDraftPr(
        branch: fresh.repository.branch,
        base: base,
        title: title,
        bodyPath: body.path,
      );
    });
  }

  Future<HandoffMutationResult> _execute(
    String taskId,
    TaskAction action,
    String challenge,
    Future<String> Function(_FreshHandoff fresh) mutation,
  ) {
    return lock.protect(() async {
      final approval = approvals.read(taskId, action);
      _assertApproval(approval, action, challenge);
      final fresh = await _fresh(taskId, action);
      _assertRepositoryShape(action, fresh);
      _assertApprovalMatches(approval!, fresh);
      approvals.write(approval.transition(HandoffStatus.executing));
      late final String outcome;
      try {
        outcome = await mutation(fresh);
      } on Object {
        approvals.write(
          approval.transition(
            HandoffStatus.uncertain,
            completedAt: now().toUtc(),
            outcome: 'external-outcome-uncertain',
          ),
        );
        throw TaskControlError(
          'handoff.outcome-uncertain',
          "Handoff '${action.label}' may have changed state; inspect manually and do not retry.",
        );
      }
      approvals.write(
        approval.transition(
          HandoffStatus.completed,
          completedAt: now().toUtc(),
          outcome: outcome,
        ),
      );
      return HandoffMutationResult(
        taskId: taskId,
        action: action,
        outcome: outcome,
      );
    });
  }

  Future<_FreshHandoff> _fresh(String taskId, TaskAction action) async {
    final state = states.read(taskId);
    if (state.lifecycle != TaskLifecycle.verified ||
        state.attemptCount <= 0 ||
        state.lastTaskFingerprint == null ||
        state.preexistingChanges.isNotEmpty) {
      throw const TaskControlError(
        'handoff.task-not-ready',
        'Handoff requires a verified task with a clean original baseline.',
      );
    }
    final result = await preflight(taskId, action);
    final episode = episodes.read(taskId);
    final last = episode.events.isEmpty ? null : episode.events.last;
    if (result.taskFingerprint != state.lastTaskFingerprint ||
        last?.type != 'verification-passed' ||
        last?.status != TaskLifecycle.verified.name ||
        last?.taskFingerprint != result.taskFingerprint) {
      throw const TaskControlError(
        'handoff.verification-stale',
        'Latest successful verification does not match the current candidate.',
      );
    }
    final repository = await adapter.inspect();
    final workspace = state.workspace;
    if (workspace != null &&
        (workspace.lifecycle != TaskWorkspaceLifecycle.prepared ||
            p.canonicalize(workspace.path) != p.canonicalize(root.path) ||
            workspace.branch != repository.branch)) {
      throw const TaskControlError(
        'handoff.workspace-mismatch',
        'Publication checkout does not match the owned task workspace.',
      );
    }
    return _FreshHandoff(
      state: state,
      preflight: result,
      repository: repository,
    );
  }

  void _assertRepositoryShape(TaskAction action, _FreshHandoff fresh) {
    if (fresh.repository.stagedPaths.isNotEmpty) {
      throw const TaskControlError(
        'handoff.prestaged-paths',
        'Handoff refuses paths staged outside the publication adapter.',
      );
    }
    if (action == TaskAction.commit) {
      _assertSamePaths(
        fresh.repository.worktreePaths,
        fresh.preflight.taskPaths,
        'worktree',
      );
    } else {
      _assertClean(fresh.repository);
    }
  }

  void _assertApproval(
    HandoffApproval? approval,
    TaskAction action,
    String challenge,
  ) {
    if (approval == null ||
        approval.action != action ||
        approval.status != HandoffStatus.prepared) {
      throw TaskControlError(
        'handoff.approval-missing',
        "Prepare a fresh '${action.label}' dry-run first.",
      );
    }
    if (!now().toUtc().isBefore(approval.expiresAt)) {
      throw const TaskControlError(
        'handoff.approval-expired',
        'Handoff approval expired.',
      );
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(challenge) ||
        sha256String(challenge) != approval.challengeHash) {
      throw const TaskControlError(
        'handoff.approval-invalid',
        'Handoff approval challenge does not match.',
      );
    }
  }

  void _assertApprovalMatches(HandoffApproval approval, _FreshHandoff fresh) {
    if (approval.taskId != fresh.state.taskId ||
        approval.attempt != fresh.state.attemptCount ||
        approval.taskFingerprint != fresh.preflight.taskFingerprint ||
        approval.authorityHash != fresh.state.authorityHash ||
        approval.branch != fresh.repository.branch ||
        approval.remote != fresh.repository.remote) {
      throw const TaskControlError(
        'handoff.approval-stale',
        'Repository or verification state changed after dry-run.',
      );
    }
    _assertSamePaths(
      approval.changedPaths,
      fresh.preflight.taskPaths,
      'approved',
    );
  }

  void _assertClean(PublicationRepositoryState repository) {
    if (repository.stagedPaths.isNotEmpty ||
        repository.worktreePaths.isNotEmpty) {
      throw const TaskControlError(
        'handoff.checkout-dirty',
        'Push and draft PR require a clean verified checkout.',
      );
    }
  }

  void _assertSamePaths(
    List<String> actual,
    List<String> expected,
    String label,
  ) {
    final left = [...actual]..sort();
    final right = [...expected]..sort();
    if (left.length != right.length ||
        left.asMap().entries.any((entry) => entry.value != right[entry.key])) {
      throw TaskControlError(
        'handoff.paths-mismatch',
        '$label paths do not exactly match verified task ownership.',
      );
    }
  }

  void _requirePublicationAction(TaskAction action) {
    if (!const {
      TaskAction.commit,
      TaskAction.push,
      TaskAction.draftPr,
    }.contains(action)) {
      throw const TaskControlError(
        'handoff.action-invalid',
        'Handoff supports only commit, push, and draft-pr.',
      );
    }
  }

  String _draftBody(_FreshHandoff fresh) =>
      '''
## Verified handoff

- Task: `${fresh.state.taskId}`
- Verification attempt: `${fresh.state.attemptCount}`
- Candidate fingerprint: `${fresh.preflight.taskFingerprint}`
- Selected lane: `${fresh.state.selectedLanes.join(', ')}`

### Verified task paths

${fresh.preflight.taskPaths.map((path) => '- `$path`').join('\n')}
''';
}

class _FreshHandoff {
  const _FreshHandoff({
    required this.state,
    required this.preflight,
    required this.repository,
  });

  final TaskState state;
  final TaskPreflightResult preflight;
  final PublicationRepositoryState repository;
}

String _secureChallenge() {
  final random = Random.secure();
  return List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
