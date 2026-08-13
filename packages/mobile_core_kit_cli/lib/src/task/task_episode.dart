import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_failure.dart';
import 'package:path/path.dart' as p;

class TaskEpisodeEvent {
  const TaskEpisodeEvent({
    required this.at,
    required this.type,
    required this.status,
    required this.summary,
    this.taskFingerprint,
    this.boundary,
  });

  final DateTime at;
  final String type;
  final String status;
  final String summary;
  final String? taskFingerprint;
  final String? boundary;

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'type': type,
    'status': status,
    'summary': sanitizeTaskDiagnostic(summary),
    if (taskFingerprint != null) 'taskFingerprint': taskFingerprint,
    if (boundary != null) 'boundary': boundary,
  };

  factory TaskEpisodeEvent.fromJson(Map<String, Object?> json) {
    final at = DateTime.tryParse(_string(json, 'at'));
    final type = _string(json, 'type');
    final status = _string(json, 'status');
    final summary = _string(json, 'summary');
    final fingerprint = json['taskFingerprint'];
    final boundary = json['boundary'];
    if (at == null ||
        !_eventValue.hasMatch(type) ||
        !_eventValue.hasMatch(status) ||
        summary.length > 4097 ||
        (fingerprint != null &&
            (fingerprint is! String || !_sha256.hasMatch(fingerprint))) ||
        (boundary != null &&
            (boundary is! String || !_boundary.hasMatch(boundary)))) {
      throw const TaskControlError(
        'task.episode-invalid',
        'Task episode event is malformed.',
      );
    }
    return TaskEpisodeEvent(
      at: at,
      type: type,
      status: status,
      summary: summary,
      taskFingerprint: fingerprint as String?,
      boundary: boundary as String?,
    );
  }
}

class TaskEpisode {
  const TaskEpisode({required this.taskId, required this.events});

  static const schemaVersion = 1;

  final String taskId;
  final List<TaskEpisodeEvent> events;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'taskId': taskId,
    'events': events.map((event) => event.toJson()).toList(),
  };

  factory TaskEpisode.fromJson(Map<String, Object?> json) {
    final events = json['events'];
    final taskId = _string(json, 'taskId');
    if (json['schemaVersion'] != schemaVersion ||
        !_taskId.hasMatch(taskId) ||
        events is! List ||
        events.any((event) => event is! Map)) {
      throw const TaskControlError(
        'task.episode-invalid',
        'Task episode schema is unsupported or malformed.',
      );
    }
    return TaskEpisode(
      taskId: taskId,
      events: events
          .cast<Map>()
          .map(
            (event) => TaskEpisodeEvent.fromJson(event.cast<String, Object?>()),
          )
          .toList(),
    );
  }
}

abstract interface class TaskEpisodeStore {
  TaskEpisode read(String taskId);

  void append(String taskId, TaskEpisodeEvent event);
}

class FileTaskEpisodeStore implements TaskEpisodeStore {
  const FileTaskEpisodeStore(this.root);

  final Directory root;

  @override
  TaskEpisode read(String taskId) {
    final source = _file(taskId);
    if (!source.existsSync()) {
      return TaskEpisode(taskId: taskId, events: const []);
    }
    try {
      final decoded = jsonDecode(source.readAsStringSync());
      if (decoded is! Map) throw const FormatException();
      return TaskEpisode.fromJson(decoded.cast<String, Object?>());
    } on TaskControlError {
      rethrow;
    } on Object {
      throw TaskControlError(
        'task.episode-unreadable',
        "Task episode is unreadable for '$taskId'.",
      );
    }
  }

  @override
  void append(String taskId, TaskEpisodeEvent event) {
    final current = read(taskId);
    final events = [...current.events, event];
    final bounded = events.length > 100
        ? events.sublist(events.length - 100)
        : events;
    _write(TaskEpisode(taskId: taskId, events: bounded));
  }

  void _write(TaskEpisode episode) {
    final destination = _file(episode.taskId);
    destination.parent.createSync(recursive: true);
    final temporary = File('${destination.path}.tmp-$pid');
    try {
      temporary.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(episode.toJson())}\n',
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
      p.join(root.path, '.tmp', 'mobilekit', 'tasks', taskId, 'episode.json'),
    );
  }
}

final _taskId = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _sha256 = RegExp(r'^[0-9a-f]{64}$');
final _eventValue = RegExp(r'^[a-z][a-z0-9-]{1,39}$');
final _boundary = RegExp(r'^[a-z][a-z0-9._-]{1,79}$');

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw TaskControlError(
      'task.episode-invalid',
      "Task episode '$key' is invalid.",
    );
  }
  return value;
}
