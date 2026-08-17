import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

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
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint)) {
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

class TaskState {
  const TaskState({
    required this.taskId,
    required this.status,
    required this.startedAt,
    required this.baseRevision,
    required this.planPath,
    required this.planSourceHash,
    required this.authorityHash,
    required this.declaredRisk,
    required this.boundaries,
    required this.impacts,
    required this.preexistingChanges,
  });

  static const schemaVersion = 1;

  final String taskId;
  final String status;
  final DateTime startedAt;
  final String baseRevision;
  final String planPath;
  final String planSourceHash;
  final String authorityHash;
  final TaskRisk declaredRisk;
  final TaskBoundaries boundaries;
  final TaskImpactAreas impacts;
  final List<PreexistingChange> preexistingChanges;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'taskId': taskId,
    'status': status,
    'startedAt': startedAt.toUtc().toIso8601String(),
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
  };

  factory TaskState.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != schemaVersion ||
        json['status'] != 'authorized') {
      throw const TaskControlError(
        'task.state-invalid',
        'Task state schema or status is unsupported.',
      );
    }
    final taskId = _requiredString(json, 'taskId');
    final startedAt = DateTime.tryParse(_requiredString(json, 'startedAt'));
    final baseRevision = _requiredString(json, 'baseRevision');
    final sourceHash = _requiredString(json, 'planSourceHash');
    final authorityHash = _requiredString(json, 'authorityHash');
    final boundaries = json['boundaries'];
    final impacts = json['impacts'];
    final preexisting = json['preexistingChanges'];
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$').hasMatch(taskId) ||
        startedAt == null ||
        !RegExp(r'^[0-9a-f]{40,64}$').hasMatch(baseRevision) ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(sourceHash) ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(authorityHash) ||
        boundaries is! Map ||
        impacts is! Map ||
        preexisting is! List ||
        preexisting.any((change) => change is! Map)) {
      throw const TaskControlError(
        'task.state-invalid',
        'Task state is malformed.',
      );
    }
    return TaskState(
      taskId: taskId,
      status: 'authorized',
      startedAt: startedAt,
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
}

abstract interface class TaskStateStore {
  void create(TaskState state);

  TaskState read(String taskId);
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
    destination.parent.createSync(recursive: true);
    final temporary = File('${destination.path}.tmp-${pid}');
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

  File _file(String taskId) {
    if (!RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$').hasMatch(taskId)) {
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
