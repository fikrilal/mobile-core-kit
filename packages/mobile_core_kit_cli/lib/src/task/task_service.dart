import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/oracle/oracle_registry.dart';
import 'package:mobile_core_kit_cli/src/policy/risk_classifier.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/git_worktree_client.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;

class TaskBeginResult {
  const TaskBeginResult({
    required this.taskId,
    required this.planPath,
    required this.baseRevision,
    required this.declaredRisk,
    required this.preexistingPathCount,
  });

  final String taskId;
  final String planPath;
  final String baseRevision;
  final TaskRisk declaredRisk;
  final int preexistingPathCount;
}

class TaskPreflightResult {
  const TaskPreflightResult({
    required this.taskId,
    required this.action,
    required this.taskPaths,
    required this.preexistingPaths,
    required this.classification,
    required this.taskFingerprint,
  });

  final String taskId;
  final TaskAction action;
  final List<String> taskPaths;
  final List<String> preexistingPaths;
  final RiskClassification classification;
  final String taskFingerprint;
}

class TaskService {
  TaskService({
    required this.root,
    GitRepository? repository,
    TaskStateStore? stateStore,
    void Function(TaskPlan plan)? validateOracles,
    DateTime Function()? now,
  }) : repository = repository ?? NativeGitRepository(root),
       stateStore = stateStore ?? FileTaskStateStore(root),
       _oracleValidator =
           validateOracles ??
           ((plan) => OracleRegistry.load(root).validatePlan(plan)),
       now = now ?? DateTime.now;

  final Directory root;
  final GitRepository repository;
  final TaskStateStore stateStore;
  final void Function(TaskPlan plan) _oracleValidator;
  final DateTime Function() now;

  Future<TaskBeginResult> begin(
    String planPath, {
    Iterable<String> taskOwnedPaths = const [],
  }) async {
    final plan = _loadPlan(planPath);
    _validateOracles(plan);
    if (plan.status != TaskPlanStatus.active ||
        !plan.path.startsWith('docs/exec-plans/active/')) {
      throw const TaskControlError(
        'task.plan-not-active',
        'Task begin requires an active-folder V2 plan.',
      );
    }
    if (findScopeViolations([
      plan.path,
    ], plan.boundaries.allowedPaths).isNotEmpty) {
      throw const TaskControlError(
        'task.plan-outside-scope',
        'Allowed paths must include the authority-bearing plan itself.',
      );
    }
    assertAllowedPathsStayInRepository(root, plan.boundaries.allowedPaths);
    final normalizedTaskOwnedPaths = taskOwnedPaths
        .map(normalizeRepositoryPath)
        .toSet();
    final taskOwnedScopeViolations = findScopeViolations(
      normalizedTaskOwnedPaths,
      plan.boundaries.allowedPaths,
    );
    if (taskOwnedScopeViolations.isNotEmpty) {
      throw TaskControlError(
        'task.task-owned-path-outside-scope',
        'Initially task-owned paths exceed plan scope: '
            '${taskOwnedScopeViolations.join(', ')}.',
      );
    }

    final baseRevision = await repository.head();
    final changes = await repository.worktreeChanges();
    final startedAt = now().toUtc();
    final preexisting = <PreexistingChange>[];
    for (final change in changes) {
      if (normalizedTaskOwnedPaths.contains(change.path)) continue;
      preexisting.add(
        PreexistingChange(
          path: change.path,
          sources: change.sources,
          contentFingerprint: await repository.contentFingerprint(change.path),
        ),
      );
    }
    stateStore.create(
      TaskState(
        taskId: plan.taskId,
        lifecycle: TaskLifecycle.authorized,
        startedAt: startedAt,
        updatedAt: startedAt,
        baseRevision: baseRevision,
        planPath: plan.path,
        planSourceHash: plan.sourceHash,
        authorityHash: plan.authorityHash,
        declaredRisk: plan.risk,
        boundaries: plan.boundaries,
        impacts: plan.impacts,
        oracleIds: plan.oracleIds,
        preexistingChanges: List.unmodifiable(preexisting),
        attemptCount: 0,
        repairCount: 0,
        repeatedFailureCount: 0,
        selectedLanes: const [],
        transitions: [
          TaskTransition(
            at: startedAt,
            from: null,
            to: TaskLifecycle.authorized,
            reason: 'task-begin',
          ),
        ],
      ),
    );
    return TaskBeginResult(
      taskId: plan.taskId,
      planPath: plan.path,
      baseRevision: baseRevision,
      declaredRisk: plan.risk,
      preexistingPathCount: preexisting.length,
    );
  }

  TaskState status(String taskId) => stateStore.read(taskId);

  Future<TaskPreflightResult> preflight(
    String taskId, {
    required TaskAction action,
  }) async {
    final state = stateStore.read(taskId);
    _assertWorkspace(state);
    final plan = _loadPlan(state.planPath);
    if (plan.status != TaskPlanStatus.active ||
        plan.taskId != state.taskId ||
        plan.authorityHash != state.authorityHash) {
      throw const TaskControlError(
        'task.authority-changed',
        'Authority-bearing plan metadata changed after task begin.',
      );
    }
    _validateOracles(plan);
    try {
      assertActionAllowed(plan.boundaries, action);
    } on TaskPlanError catch (error) {
      throw TaskControlError(error.code, error.message);
    }

    final changes = mergeChanges(
      await repository.changesSince(state.baseRevision),
      await repository.worktreeChanges(),
    );
    final baseline = {
      for (final change in state.preexistingChanges) change.path: change,
    };
    final taskPaths = <String>[];
    final preexistingPaths = <String>[];
    for (final change in changes) {
      final previous = baseline[change.path];
      final currentFingerprint = await repository.contentFingerprint(
        change.path,
      );
      if (previous != null &&
          previous.contentFingerprint == currentFingerprint) {
        preexistingPaths.add(change.path);
      } else {
        taskPaths.add(change.path);
      }
    }
    taskPaths.sort();
    preexistingPaths.sort();

    final violations = findScopeViolations(
      taskPaths,
      plan.boundaries.allowedPaths,
    );
    if (violations.isNotEmpty) {
      throw TaskControlError(
        'task.scope-violation',
        'Task-owned paths exceed plan scope: ${violations.join(', ')}.',
      );
    }
    final classification = classifyRisk(
      taskPaths,
      declaredRisk: plan.risk,
      impacts: plan.impacts,
    );
    if (classification.effectiveRisk.index >
        plan.boundaries.maximumRisk.index) {
      throw TaskControlError(
        'task.risk-above-authority',
        'Effective ${classification.effectiveRisk.name} risk exceeds maximum '
            '${plan.boundaries.maximumRisk.name}.',
      );
    }
    final fingerprintContent = <List<String>>[];
    for (final path in taskPaths) {
      fingerprintContent.add([path, await repository.contentFingerprint(path)]);
    }
    final taskFingerprint = sha256
        .convert(
          utf8.encode(
            jsonEncode({
              'authorityHash': plan.authorityHash,
              'baseRevision': state.baseRevision,
              'effectiveRisk': classification.effectiveRisk.name,
              'paths': fingerprintContent,
            }),
          ),
        )
        .toString();
    return TaskPreflightResult(
      taskId: taskId,
      action: action,
      taskPaths: List.unmodifiable(taskPaths),
      preexistingPaths: List.unmodifiable(preexistingPaths),
      classification: classification,
      taskFingerprint: taskFingerprint,
    );
  }

  void _assertWorkspace(TaskState state) {
    final workspace = state.workspace;
    if (workspace == null) return;
    if (workspace.lifecycle != TaskWorkspaceLifecycle.prepared) {
      throw TaskControlError(
        'workspace.lifecycle-invalid',
        'Task workspace is ${workspace.lifecycle.name}; controlled actions are disabled.',
      );
    }
    if (canonicalWorkspacePath(root.path) !=
        canonicalWorkspacePath(workspace.path)) {
      throw const TaskControlError(
        'workspace.checkout-mismatch',
        'Run controlled task actions from the owned task workspace.',
      );
    }
  }

  Future<RiskClassification> classifyCurrent({String? planPath}) async {
    final changes = await repository.worktreeChanges();
    final plan = planPath == null ? null : _loadPlan(planPath);
    return classifyRisk(
      changes.map((change) => change.path),
      declaredRisk: plan?.risk,
      impacts: plan?.impacts,
    );
  }

  TaskPlan _loadPlan(String planPath) {
    try {
      final normalized = normalizeRepositoryPath(planPath);
      final source = File(p.join(root.path, normalized));
      if (!source.existsSync()) {
        throw TaskControlError(
          'task.plan-missing',
          "Task plan does not exist: '$normalized'.",
        );
      }
      return parseTaskPlan(normalized, source.readAsStringSync());
    } on TaskControlError {
      rethrow;
    } on TaskPlanError catch (error) {
      throw TaskControlError(error.code, error.message);
    } on FileSystemException catch (error) {
      throw TaskControlError('task.plan-unreadable', error.message);
    }
  }

  void _validateOracles(TaskPlan plan) {
    try {
      _oracleValidator(plan);
    } on OracleRegistryError catch (error) {
      throw TaskControlError(error.code, error.message);
    }
  }
}
