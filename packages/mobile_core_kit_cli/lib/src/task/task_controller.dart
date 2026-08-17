import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:mobile_core_kit_cli/src/task/task_failure.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:mobile_core_kit_cli/src/verification/verification_profile.dart';

class TaskLaneExecution {
  const TaskLaneExecution({
    required this.exitCode,
    required this.duration,
    required this.timedOut,
    required this.diagnostic,
    this.failedStep,
    this.infrastructureUnavailable = false,
  });

  final int exitCode;
  final Duration duration;
  final bool timedOut;
  final String diagnostic;
  final VerificationStep? failedStep;
  final bool infrastructureUnavailable;
}

typedef TaskLaneRunner =
    Future<TaskLaneExecution> Function(
      VerificationProfile profile,
      DateTime deadline,
    );

class TaskVerificationResult {
  const TaskVerificationResult({
    required this.taskId,
    required this.profile,
    required this.lifecycle,
    required this.exitCode,
    required this.attempt,
    this.failure,
  });

  final String taskId;
  final VerificationProfile profile;
  final TaskLifecycle lifecycle;
  final int exitCode;
  final int attempt;
  final TaskFailureRecord? failure;
}

class TaskRepairResult {
  const TaskRepairResult({
    required this.taskId,
    required this.candidateChanged,
    required this.lifecycle,
    required this.repairCount,
    required this.repairLimit,
  });

  final String taskId;
  final bool candidateChanged;
  final TaskLifecycle lifecycle;
  final int repairCount;
  final int repairLimit;
}

class TaskController {
  TaskController({
    required this.service,
    required this.stateStore,
    required this.episodeStore,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final TaskService service;
  final TaskStateStore stateStore;
  final TaskEpisodeStore episodeStore;
  final DateTime Function() now;

  Future<TaskVerificationResult> verify(
    String taskId, {
    required TaskLaneRunner runLane,
  }) async {
    var state = stateStore.read(taskId);
    if (state.lifecycle == TaskLifecycle.escalated) {
      throw TaskControlError(
        'task.already-escalated',
        "Task '$taskId' is already escalated: ${state.escalationReason}.",
      );
    }
    if (state.lifecycle == TaskLifecycle.verifying) {
      await _escalate(
        state,
        code: 'task.ambiguous-transition',
        summary: 'A prior verification was interrupted while running.',
      );
      throw const TaskControlError(
        'task.ambiguous-transition',
        'Interrupted verification requires human inspection.',
      );
    }
    if (state.lifecycle == TaskLifecycle.failed) {
      throw const TaskControlError(
        'task.repair-required',
        'Record a candidate-changing repair before verification runs again.',
      );
    }

    final deadline = state.startedAt.toUtc().add(state.boundaries.timeout);
    if (!_nowUtc().isBefore(deadline)) {
      return _timeoutResult(state, profile: _profileFor(state.declaredRisk));
    }

    TaskPreflightResult preflight;
    try {
      preflight = await service.preflight(taskId, action: TaskAction.verify);
    } on TaskControlError catch (error) {
      await _escalate(state, code: error.code, summary: error.message);
      rethrow;
    }

    final profile = _profileFor(preflight.classification.effectiveRisk);
    final started = _nowUtc();
    state = state.transition(
      TaskLifecycle.verifying,
      at: started,
      reason: 'verification-started',
      attemptCount: state.attemptCount + 1,
      selectedLanes: [profile.label],
    );
    stateStore.write(state);
    _event(
      state,
      type: 'verification-started',
      summary: 'Started ${profile.label} verification.',
      fingerprint: preflight.taskFingerprint,
    );

    late final TaskLaneExecution execution;
    try {
      execution = await runLane(profile, deadline);
    } on ProcessException catch (error) {
      execution = TaskLaneExecution(
        exitCode: 127,
        duration: _nowUtc().difference(started),
        timedOut: false,
        diagnostic: error.message,
        infrastructureUnavailable: true,
      );
    }
    final finished = _nowUtc();
    if (execution.timedOut || !finished.isBefore(deadline)) {
      return _timeoutResult(
        state,
        profile: profile,
        fingerprint: preflight.taskFingerprint,
      );
    }
    if (execution.exitCode == 0) {
      final verified = state.transition(
        TaskLifecycle.verified,
        at: finished,
        reason: 'verification-passed',
        repeatedFailureCount: 0,
        lastTaskFingerprint: preflight.taskFingerprint,
        failure: null,
        escalationReason: null,
      );
      stateStore.write(verified);
      _event(
        verified,
        type: 'verification-passed',
        summary:
            '${profile.label} verification passed in '
            '${execution.duration.inMilliseconds}ms.',
        fingerprint: preflight.taskFingerprint,
      );
      return TaskVerificationResult(
        taskId: taskId,
        profile: profile,
        lifecycle: verified.lifecycle,
        exitCode: 0,
        attempt: verified.attemptCount,
      );
    }

    final definition = execution.infrastructureUnavailable
        ? const TaskFailureDefinition(
            boundary: 'infrastructure.unavailable',
            category: TaskFailureCategory.infrastructure,
          )
        : execution.failedStep == null
        ? const TaskFailureDefinition(
            boundary: 'verification.unknown',
            category: TaskFailureCategory.unknown,
          )
        : verificationFailureTaxonomy[execution.failedStep!]!;
    final repeated =
        state.failure?.boundary == definition.boundary &&
        state.failure?.taskFingerprint == preflight.taskFingerprint;
    final repeatedCount = repeated ? state.repeatedFailureCount + 1 : 1;
    final repairCount = state.repairCount + (repeated ? 1 : 0);
    final failure = TaskFailureRecord(
      boundary: definition.boundary,
      category: definition.category,
      exitCode: execution.exitCode,
      diagnostic: sanitizeTaskDiagnostic(
        execution.diagnostic.isEmpty
            ? '${definition.boundary} failed with exit '
                  '${execution.exitCode}.'
            : execution.diagnostic,
      ),
      remediation:
          execution.failedStep?.remediation ?? 'Inspect the failed lane.',
      at: finished,
      taskFingerprint: preflight.taskFingerprint,
    );
    final exhausted =
        execution.infrastructureUnavailable ||
        state.boundaries.repairLimit == 0 ||
        repairCount >= state.boundaries.repairLimit;
    final escalationReason = execution.infrastructureUnavailable
        ? 'task.infrastructure-unavailable'
        : exhausted
        ? 'task.repair-budget-exhausted'
        : null;
    final next = state.transition(
      exhausted ? TaskLifecycle.escalated : TaskLifecycle.failed,
      at: finished,
      reason: escalationReason ?? 'verification-failed',
      repairCount: repairCount,
      repeatedFailureCount: repeatedCount,
      lastTaskFingerprint: preflight.taskFingerprint,
      failure: failure,
      escalationReason: escalationReason,
    );
    stateStore.write(next);
    _event(
      next,
      type: exhausted ? 'task-escalated' : 'verification-failed',
      summary: failure.diagnostic,
      fingerprint: preflight.taskFingerprint,
      boundary: failure.boundary,
    );
    return TaskVerificationResult(
      taskId: taskId,
      profile: profile,
      lifecycle: next.lifecycle,
      exitCode: execution.exitCode,
      attempt: next.attemptCount,
      failure: failure,
    );
  }

  Future<TaskRepairResult> recordRepair(String taskId) async {
    var state = stateStore.read(taskId);
    if (state.lifecycle != TaskLifecycle.failed || state.failure == null) {
      throw const TaskControlError(
        'task.repair-not-available',
        'Repair can be recorded only after a non-terminal failure.',
      );
    }
    final deadline = state.startedAt.toUtc().add(state.boundaries.timeout);
    if (!_nowUtc().isBefore(deadline)) {
      await _escalate(
        state,
        code: 'task.timeout',
        summary: 'Task timeout expired before repair could be recorded.',
      );
      throw const TaskControlError(
        'task.timeout',
        'Task timeout expired before repair could be recorded.',
      );
    }
    late final TaskPreflightResult preflight;
    try {
      preflight = await service.preflight(taskId, action: TaskAction.edit);
    } on TaskControlError catch (error) {
      await _escalate(state, code: error.code, summary: error.message);
      rethrow;
    }
    final changed = preflight.taskFingerprint != state.failure!.taskFingerprint;
    final repairs = state.repairCount + 1;
    final exhausted = repairs >= state.boundaries.repairLimit;
    if (!changed) {
      state = state.transition(
        exhausted ? TaskLifecycle.escalated : TaskLifecycle.failed,
        at: _nowUtc(),
        reason: exhausted ? 'repair-budget-exhausted' : 'repair-made-no-change',
        repairCount: repairs,
        repeatedFailureCount: state.repeatedFailureCount + 1,
        escalationReason: exhausted ? 'task.repair-budget-exhausted' : null,
      );
    } else {
      state = state.transition(
        TaskLifecycle.authorized,
        at: _nowUtc(),
        reason: 'repair-changed-candidate',
        repairCount: repairs,
        repeatedFailureCount: 0,
        escalationReason: null,
      );
    }
    stateStore.write(state);
    _event(
      state,
      type: changed ? 'repair-recorded' : 'repair-unchanged',
      summary: changed
          ? 'Repair changed the candidate; verification may run again.'
          : 'Repair did not change the candidate fingerprint.',
      fingerprint: preflight.taskFingerprint,
      boundary: state.failure?.boundary,
    );
    return TaskRepairResult(
      taskId: taskId,
      candidateChanged: changed,
      lifecycle: state.lifecycle,
      repairCount: repairs,
      repairLimit: state.boundaries.repairLimit,
    );
  }

  Future<TaskVerificationResult> _timeoutResult(
    TaskState state, {
    required VerificationProfile profile,
    String? fingerprint,
  }) async {
    final at = _nowUtc();
    final failure = TaskFailureRecord(
      boundary: 'controller.timeout',
      category: TaskFailureCategory.timeout,
      exitCode: 124,
      diagnostic: 'Task timeout expired.',
      remediation: 'Request new human authority with a fresh task baseline.',
      at: at,
      taskFingerprint: fingerprint ?? state.lastTaskFingerprint ?? _zeroHash,
    );
    final escalated = state.transition(
      TaskLifecycle.escalated,
      at: at,
      reason: 'task-timeout',
      failure: failure,
      escalationReason: 'task.timeout',
      lastTaskFingerprint: fingerprint ?? state.lastTaskFingerprint,
    );
    stateStore.write(escalated);
    _event(
      escalated,
      type: 'task-escalated',
      summary: failure.diagnostic,
      fingerprint: fingerprint,
      boundary: failure.boundary,
    );
    return TaskVerificationResult(
      taskId: state.taskId,
      profile: profile,
      lifecycle: TaskLifecycle.escalated,
      exitCode: 124,
      attempt: state.attemptCount,
      failure: failure,
    );
  }

  Future<void> _escalate(
    TaskState state, {
    required String code,
    required String summary,
  }) async {
    final escalated = state.transition(
      TaskLifecycle.escalated,
      at: _nowUtc(),
      reason: code,
      escalationReason: code,
    );
    stateStore.write(escalated);
    _event(
      escalated,
      type: 'task-escalated',
      summary: summary,
      fingerprint: state.lastTaskFingerprint,
    );
  }

  void _event(
    TaskState state, {
    required String type,
    required String summary,
    String? fingerprint,
    String? boundary,
  }) {
    episodeStore.append(
      state.taskId,
      TaskEpisodeEvent(
        at: _nowUtc(),
        type: type,
        status: state.lifecycle.name,
        summary: summary,
        taskFingerprint: fingerprint,
        boundary: boundary,
      ),
    );
  }

  DateTime _nowUtc() => now().toUtc();
}

VerificationProfile _profileFor(TaskRisk risk) => switch (risk) {
  TaskRisk.low => VerificationProfile.fast,
  TaskRisk.medium || TaskRisk.high => VerificationProfile.full,
};

const _zeroHash =
    '0000000000000000000000000000000000000000000000000000000000000000';
