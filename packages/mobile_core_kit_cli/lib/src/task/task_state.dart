import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_failure.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

enum TaskLifecycle {
  authorized,
  verifying,
  failed,
  verified,
  escalated;

  static TaskLifecycle parse(String value) => values.firstWhere(
    (candidate) => candidate.name == value,
    orElse: () => throw const TaskControlError(
      'task.state-invalid',
      'Task lifecycle is unsupported.',
    ),
  );
}

class PreexistingChange {
  const PreexistingChange({
    required this.path,
    required this.sources,
    required this.contentFingerprint,
  });

  final String path;
  final List<ChangeSource> sources;
  final String contentFingerprint;

  Map<String, Object?> toJson() => {
    'path': path,
    'sources': sources.map((source) => source.name).toList(),
    'contentFingerprint': contentFingerprint,
  };

  factory PreexistingChange.fromJson(Map<String, Object?> json) {
    final sources = json['sources'];
    final fingerprint = _requiredString(json, 'contentFingerprint');
    if (sources is! List ||
        sources.any((source) => source is! String) ||
        !_sha256.hasMatch(fingerprint)) {
      throw const TaskControlError(
        'task.state-invalid',
        'Pre-existing task change is invalid.',
      );
    }
    return PreexistingChange(
      path: normalizeRepositoryPath(_requiredString(json, 'path')),
      sources: sources.cast<String>().map(_changeSource).toList(),
      contentFingerprint: fingerprint,
    );
  }
}

class TaskTransition {
  const TaskTransition({
    required this.at,
    required this.from,
    required this.to,
    required this.reason,
  });

  final DateTime at;
  final TaskLifecycle? from;
  final TaskLifecycle to;
  final String reason;

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    if (from != null) 'from': from!.name,
    'to': to.name,
    'reason': reason,
  };

  factory TaskTransition.fromJson(Map<String, Object?> json) {
    final at = DateTime.tryParse(_requiredString(json, 'at'));
    final from = json['from'];
    final reason = _requiredString(json, 'reason');
    if (at == null ||
        (from != null && from is! String) ||
        reason.length > 160) {
      throw const TaskControlError(
        'task.state-invalid',
        'Task transition is invalid.',
      );
    }
    return TaskTransition(
      at: at,
      from: from == null ? null : TaskLifecycle.parse(from as String),
      to: TaskLifecycle.parse(_requiredString(json, 'to')),
      reason: reason,
    );
  }
}

class TaskFailureRecord {
  const TaskFailureRecord({
    required this.boundary,
    required this.category,
    required this.exitCode,
    required this.diagnostic,
    required this.remediation,
    required this.at,
    required this.taskFingerprint,
  });

  final String boundary;
  final TaskFailureCategory category;
  final int exitCode;
  final String diagnostic;
  final String remediation;
  final DateTime at;
  final String taskFingerprint;

  Map<String, Object?> toJson() => {
    'boundary': boundary,
    'category': category.name,
    'exitCode': exitCode,
    'diagnostic': sanitizeTaskDiagnostic(diagnostic),
    'remediation': sanitizeTaskDiagnostic(remediation, maximumLength: 1000),
    'at': at.toUtc().toIso8601String(),
    'taskFingerprint': taskFingerprint,
  };

  factory TaskFailureRecord.fromJson(Map<String, Object?> json) {
    final boundary = _requiredString(json, 'boundary');
    final category = _requiredString(json, 'category');
    final exitCode = json['exitCode'];
    final diagnostic = _requiredString(json, 'diagnostic');
    final remediation = _requiredString(json, 'remediation');
    final at = DateTime.tryParse(_requiredString(json, 'at'));
    final fingerprint = _requiredString(json, 'taskFingerprint');
    if (!_boundary.hasMatch(boundary) ||
        exitCode is! int ||
        at == null ||
        !_sha256.hasMatch(fingerprint) ||
        diagnostic.length > 4097 ||
        remediation.length > 1001) {
      throw const TaskControlError(
        'task.state-invalid',
        'Task failure record is invalid.',
      );
    }
    return TaskFailureRecord(
      boundary: boundary,
      category: TaskFailureCategory.values.firstWhere(
        (candidate) => candidate.name == category,
        orElse: () => throw const TaskControlError(
          'task.state-invalid',
          'Task failure category is unsupported.',
        ),
      ),
      exitCode: exitCode,
      diagnostic: diagnostic,
      remediation: remediation,
      at: at,
      taskFingerprint: fingerprint,
    );
  }
}

class TaskState {
  const TaskState({
    required this.taskId,
    required this.lifecycle,
    required this.startedAt,
    required this.updatedAt,
    required this.baseRevision,
    required this.planPath,
    required this.planSourceHash,
    required this.authorityHash,
    required this.declaredRisk,
    required this.boundaries,
    required this.impacts,
    required this.preexistingChanges,
    required this.attemptCount,
    required this.repairCount,
    required this.repeatedFailureCount,
    required this.selectedLanes,
    required this.transitions,
    this.lastTaskFingerprint,
    this.failure,
    this.escalationReason,
  });

  static const schemaVersion = 2;

  final String taskId;
  final TaskLifecycle lifecycle;
  final DateTime startedAt;
  final DateTime updatedAt;
  final String baseRevision;
  final String planPath;
  final String planSourceHash;
  final String authorityHash;
  final TaskRisk declaredRisk;
  final TaskBoundaries boundaries;
  final TaskImpactAreas impacts;
  final List<PreexistingChange> preexistingChanges;
  final int attemptCount;
  final int repairCount;
  final int repeatedFailureCount;
  final List<String> selectedLanes;
  final List<TaskTransition> transitions;
  final String? lastTaskFingerprint;
  final TaskFailureRecord? failure;
  final String? escalationReason;

  String get status => lifecycle.name;

  TaskState transition(
    TaskLifecycle next, {
    required DateTime at,
    required String reason,
    int? attemptCount,
    int? repairCount,
    int? repeatedFailureCount,
    List<String>? selectedLanes,
    Object? lastTaskFingerprint = _unchanged,
    Object? failure = _unchanged,
    Object? escalationReason = _unchanged,
  }) {
    final nextTransitions = [
      ...transitions,
      TaskTransition(at: at, from: lifecycle, to: next, reason: reason),
    ];
    final boundedTransitions = nextTransitions.length > 100
        ? nextTransitions.sublist(nextTransitions.length - 100)
        : nextTransitions;
    return TaskState(
      taskId: taskId,
      lifecycle: next,
      startedAt: startedAt,
      updatedAt: at.toUtc(),
      baseRevision: baseRevision,
      planPath: planPath,
      planSourceHash: planSourceHash,
      authorityHash: authorityHash,
      declaredRisk: declaredRisk,
      boundaries: boundaries,
      impacts: impacts,
      preexistingChanges: preexistingChanges,
      attemptCount: attemptCount ?? this.attemptCount,
      repairCount: repairCount ?? this.repairCount,
      repeatedFailureCount: repeatedFailureCount ?? this.repeatedFailureCount,
      selectedLanes: selectedLanes ?? this.selectedLanes,
      transitions: boundedTransitions,
      lastTaskFingerprint: identical(lastTaskFingerprint, _unchanged)
          ? this.lastTaskFingerprint
          : lastTaskFingerprint as String?,
      failure: identical(failure, _unchanged)
          ? this.failure
          : failure as TaskFailureRecord?,
      escalationReason: identical(escalationReason, _unchanged)
          ? this.escalationReason
          : escalationReason as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'taskId': taskId,
    'lifecycle': lifecycle.name,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'baseRevision': baseRevision,
    'planPath': planPath,
    'planSourceHash': planSourceHash,
    'authorityHash': authorityHash,
    'declaredRisk': declaredRisk.name,
    'boundaries': boundaries.toJson(),
    'impacts': impacts.toJson(),
    'preexistingChanges': preexistingChanges
        .map((change) => change.toJson())
        .toList(),
    'attemptCount': attemptCount,
    'repairCount': repairCount,
    'repeatedFailureCount': repeatedFailureCount,
    'selectedLanes': selectedLanes,
    'transitions': transitions
        .map((transition) => transition.toJson())
        .toList(),
    if (lastTaskFingerprint != null) 'lastTaskFingerprint': lastTaskFingerprint,
    if (failure != null) 'failure': failure!.toJson(),
    if (escalationReason != null) 'escalationReason': escalationReason,
  };

  factory TaskState.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    if (version == 1) return _fromV1(json);
    if (version != schemaVersion) {
      throw const TaskControlError(
        'task.state-invalid',
        'Task state schema is unsupported.',
      );
    }
    return _fromV2(json);
  }

  static TaskState _fromV1(Map<String, Object?> json) {
    if (json['status'] != 'authorized') {
      throw const TaskControlError(
        'task.state-invalid',
        'Legacy task state status is unsupported.',
      );
    }
    final startedAt = DateTime.tryParse(_requiredString(json, 'startedAt'));
    if (startedAt == null) {
      throw const TaskControlError(
        'task.state-invalid',
        'Legacy task start time is invalid.',
      );
    }
    final common = _common(json);
    return TaskState(
      taskId: common.taskId,
      lifecycle: TaskLifecycle.authorized,
      startedAt: startedAt,
      updatedAt: startedAt,
      baseRevision: common.baseRevision,
      planPath: common.planPath,
      planSourceHash: common.planSourceHash,
      authorityHash: common.authorityHash,
      declaredRisk: common.declaredRisk,
      boundaries: common.boundaries,
      impacts: common.impacts,
      preexistingChanges: common.preexistingChanges,
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
    );
  }

  static TaskState _fromV2(Map<String, Object?> json) {
    final common = _common(json);
    final startedAt = DateTime.tryParse(_requiredString(json, 'startedAt'));
    final updatedAt = DateTime.tryParse(_requiredString(json, 'updatedAt'));
    final attempts = json['attemptCount'];
    final repairs = json['repairCount'];
    final repeated = json['repeatedFailureCount'];
    final lanes = json['selectedLanes'];
    final transitions = json['transitions'];
    final fingerprint = json['lastTaskFingerprint'];
    final failure = json['failure'];
    final escalation = json['escalationReason'];
    if (startedAt == null ||
        updatedAt == null ||
        attempts is! int ||
        attempts < 0 ||
        repairs is! int ||
        repairs < 0 ||
        repeated is! int ||
        repeated < 0 ||
        lanes is! List ||
        lanes.any((lane) => lane is! String) ||
        transitions is! List ||
        transitions.any((transition) => transition is! Map) ||
        (fingerprint != null &&
            (fingerprint is! String || !_sha256.hasMatch(fingerprint))) ||
        (failure != null && failure is! Map) ||
        (escalation != null && escalation is! String)) {
      throw const TaskControlError(
        'task.state-invalid',
        'Task state is malformed.',
      );
    }
    return TaskState(
      taskId: common.taskId,
      lifecycle: TaskLifecycle.parse(_requiredString(json, 'lifecycle')),
      startedAt: startedAt,
      updatedAt: updatedAt,
      baseRevision: common.baseRevision,
      planPath: common.planPath,
      planSourceHash: common.planSourceHash,
      authorityHash: common.authorityHash,
      declaredRisk: common.declaredRisk,
      boundaries: common.boundaries,
      impacts: common.impacts,
      preexistingChanges: common.preexistingChanges,
      attemptCount: attempts,
      repairCount: repairs,
      repeatedFailureCount: repeated,
      selectedLanes: List.unmodifiable(lanes.cast<String>()),
      transitions: transitions
          .cast<Map>()
          .map(
            (transition) =>
                TaskTransition.fromJson(transition.cast<String, Object?>()),
          )
          .toList(),
      lastTaskFingerprint: fingerprint as String?,
      failure: failure == null
          ? null
          : TaskFailureRecord.fromJson(
              (failure as Map).cast<String, Object?>(),
            ),
      escalationReason: escalation as String?,
    );
  }
}

abstract interface class TaskStateStore {
  void create(TaskState state);

  TaskState read(String taskId);

  void write(TaskState state);
}

class FileTaskStateStore implements TaskStateStore {
  const FileTaskStateStore(this.root);

  final Directory root;

  @override
  void create(TaskState state) {
    final destination = _file(state.taskId);
    if (destination.existsSync()) {
      throw TaskControlError(
        'task.state-exists',
        "Task state already exists for '${state.taskId}'.",
      );
    }
    _write(state);
  }

  @override
  TaskState read(String taskId) {
    final source = _file(taskId);
    if (!source.existsSync()) {
      throw TaskControlError(
        'task.state-missing',
        "Task state does not exist for '$taskId'.",
      );
    }
    try {
      final decoded = jsonDecode(source.readAsStringSync());
      if (decoded is! Map) throw const FormatException();
      return TaskState.fromJson(decoded.cast<String, Object?>());
    } on TaskControlError {
      rethrow;
    } on Object {
      throw TaskControlError(
        'task.state-unreadable',
        "Task state is unreadable for '$taskId'.",
      );
    }
  }

  @override
  void write(TaskState state) {
    if (!_file(state.taskId).existsSync()) {
      throw TaskControlError(
        'task.state-missing',
        "Task state does not exist for '${state.taskId}'.",
      );
    }
    _write(state);
  }

  void _write(TaskState state) {
    final destination = _file(state.taskId);
    destination.parent.createSync(recursive: true);
    final temporary = File('${destination.path}.tmp-$pid');
    try {
      temporary.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(state.toJson())}\n',
        flush: true,
      );
      temporary.renameSync(destination.path);
    } finally {
      if (temporary.existsSync()) temporary.deleteSync();
    }
  }

  File _file(String taskId) {
    if (!_taskId.hasMatch(taskId)) {
      throw const TaskControlError(
        'task.task-id-invalid',
        'Task ID is invalid.',
      );
    }
    return File(
      p.join(root.path, '.tmp', 'mobilekit', 'tasks', taskId, 'state.json'),
    );
  }
}

class _CommonTaskState {
  const _CommonTaskState({
    required this.taskId,
    required this.baseRevision,
    required this.planPath,
    required this.planSourceHash,
    required this.authorityHash,
    required this.declaredRisk,
    required this.boundaries,
    required this.impacts,
    required this.preexistingChanges,
  });

  final String taskId;
  final String baseRevision;
  final String planPath;
  final String planSourceHash;
  final String authorityHash;
  final TaskRisk declaredRisk;
  final TaskBoundaries boundaries;
  final TaskImpactAreas impacts;
  final List<PreexistingChange> preexistingChanges;
}

_CommonTaskState _common(Map<String, Object?> json) {
  final taskId = _requiredString(json, 'taskId');
  final baseRevision = _requiredString(json, 'baseRevision');
  final sourceHash = _requiredString(json, 'planSourceHash');
  final authorityHash = _requiredString(json, 'authorityHash');
  final boundaries = json['boundaries'];
  final impacts = json['impacts'];
  final preexisting = json['preexistingChanges'];
  if (!_taskId.hasMatch(taskId) ||
      !_revision.hasMatch(baseRevision) ||
      !_sha256.hasMatch(sourceHash) ||
      !_sha256.hasMatch(authorityHash) ||
      boundaries is! Map ||
      impacts is! Map ||
      preexisting is! List ||
      preexisting.any((change) => change is! Map)) {
    throw const TaskControlError(
      'task.state-invalid',
      'Task state is malformed.',
    );
  }
  return _CommonTaskState(
    taskId: taskId,
    baseRevision: baseRevision,
    planPath: normalizeRepositoryPath(_requiredString(json, 'planPath')),
    planSourceHash: sourceHash,
    authorityHash: authorityHash,
    declaredRisk: TaskRisk.parse(_requiredString(json, 'declaredRisk')),
    boundaries: TaskBoundaries.fromJson(boundaries.cast<String, Object?>()),
    impacts: TaskImpactAreas.fromJson(impacts.cast<String, Object?>()),
    preexistingChanges: preexisting
        .cast<Map>()
        .map(
          (change) =>
              PreexistingChange.fromJson(change.cast<String, Object?>()),
        )
        .toList(),
  );
}

String _requiredString(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value is! String || value.isEmpty) {
    throw TaskControlError(
      'task.state-invalid',
      "Task state '$name' is invalid.",
    );
  }
  return value;
}

ChangeSource _changeSource(String value) {
  return ChangeSource.values.firstWhere(
    (source) => source.name == value,
    orElse: () => throw TaskControlError(
      'task.state-invalid',
      "Unsupported change source '$value'.",
    ),
  );
}

const _unchanged = Object();
final _taskId = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _revision = RegExp(r'^[0-9a-f]{40,64}$');
final _sha256 = RegExp(r'^[0-9a-f]{64}$');
final _boundary = RegExp(r'^[a-z][a-z0-9._-]{1,79}$');
