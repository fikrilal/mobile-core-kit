import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/private_artifact.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

enum EventReceiptStatus { claimed, accepted }

class EventReceipt {
  const EventReceipt({
    required this.eventId,
    required this.status,
    required this.taskId,
    required this.queuedPlanPath,
    required this.activePlanPath,
    required this.queuedSourceHash,
    required this.activeSourceHash,
    required this.authorityHash,
    required this.receivedAt,
    this.completedAt,
  });

  static const schemaVersion = 1;

  final String eventId;
  final EventReceiptStatus status;
  final String taskId;
  final String queuedPlanPath;
  final String activePlanPath;
  final String queuedSourceHash;
  final String activeSourceHash;
  final String authorityHash;
  final DateTime receivedAt;
  final DateTime? completedAt;

  EventReceipt acceptedAt(DateTime value) => EventReceipt(
    eventId: eventId,
    status: EventReceiptStatus.accepted,
    taskId: taskId,
    queuedPlanPath: queuedPlanPath,
    activePlanPath: activePlanPath,
    queuedSourceHash: queuedSourceHash,
    activeSourceHash: activeSourceHash,
    authorityHash: authorityHash,
    receivedAt: receivedAt,
    completedAt: value.toUtc(),
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'eventId': eventId,
    'source': 'queued-plan',
    'status': status.name,
    'taskId': taskId,
    'queuedPlanPath': queuedPlanPath,
    'activePlanPath': activePlanPath,
    'queuedSourceHash': queuedSourceHash,
    'activeSourceHash': activeSourceHash,
    'authorityHash': authorityHash,
    'receivedAt': receivedAt.toUtc().toIso8601String(),
    if (completedAt != null)
      'completedAt': completedAt!.toUtc().toIso8601String(),
  };

  factory EventReceipt.fromJson(Map<String, Object?> json) {
    const requiredKeys = {
      'schemaVersion',
      'eventId',
      'source',
      'status',
      'taskId',
      'queuedPlanPath',
      'activePlanPath',
      'queuedSourceHash',
      'activeSourceHash',
      'authorityHash',
      'receivedAt',
    };
    const optionalKeys = {'completedAt'};
    if (json['schemaVersion'] != schemaVersion ||
        json['source'] != 'queued-plan' ||
        !json.keys.toSet().containsAll(requiredKeys) ||
        json.keys.any(
          (key) => !requiredKeys.contains(key) && !optionalKeys.contains(key),
        )) {
      throw const TaskControlError(
        'event.receipt-invalid',
        'Event receipt schema is unsupported or malformed.',
      );
    }
    final status = _status(_string(json, 'status'));
    final completedAt = _optionalDate(json, 'completedAt');
    if ((status == EventReceiptStatus.claimed && completedAt != null) ||
        (status == EventReceiptStatus.accepted && completedAt == null)) {
      throw const TaskControlError(
        'event.receipt-invalid',
        'Event receipt lifecycle is malformed.',
      );
    }
    final taskId = _string(json, 'taskId');
    if (!_taskId.hasMatch(taskId)) {
      throw const TaskControlError(
        'event.receipt-invalid',
        'Event receipt task ID is invalid.',
      );
    }
    return EventReceipt(
      eventId: _hash(json, 'eventId'),
      status: status,
      taskId: taskId,
      queuedPlanPath: _planPath(json, 'queuedPlanPath', 'queued'),
      activePlanPath: _planPath(json, 'activePlanPath', 'active'),
      queuedSourceHash: _hash(json, 'queuedSourceHash'),
      activeSourceHash: _hash(json, 'activeSourceHash'),
      authorityHash: _hash(json, 'authorityHash'),
      receivedAt: _date(json, 'receivedAt'),
      completedAt: completedAt,
    );
  }
}

abstract interface class EventReceiptStore {
  void create(EventReceipt receipt);

  EventReceipt? read(String eventId);

  void write(EventReceipt receipt);

  List<EventReceipt> list();
}

class FileEventReceiptStore implements EventReceiptStore {
  const FileEventReceiptStore(this.controlRoot);

  static const maximumBytes = 16 * 1024;

  final Directory controlRoot;

  @override
  void create(EventReceipt receipt) {
    final destination = _file(receipt.eventId);
    if (destination.existsSync()) {
      throw const TaskControlError(
        'event.receipt-exists',
        'Event receipt already exists.',
      );
    }
    writePrivateFile(destination, _encode(receipt), exclusive: true);
  }

  @override
  EventReceipt? read(String eventId) {
    final source = _file(eventId);
    if (!source.existsSync()) return null;
    if (source.lengthSync() > maximumBytes) {
      throw const TaskControlError(
        'event.receipt-too-large',
        'Event receipt exceeds its size limit.',
      );
    }
    try {
      final decoded = jsonDecode(source.readAsStringSync());
      if (decoded is! Map) throw const FormatException();
      return EventReceipt.fromJson(decoded.cast<String, Object?>());
    } on TaskControlError {
      rethrow;
    } on Object {
      throw const TaskControlError(
        'event.receipt-invalid',
        'Event receipt is unreadable.',
      );
    }
  }

  @override
  void write(EventReceipt receipt) {
    if (!_file(receipt.eventId).existsSync()) {
      throw const TaskControlError(
        'event.receipt-missing',
        'Event receipt does not exist.',
      );
    }
    writePrivateFile(_file(receipt.eventId), _encode(receipt));
  }

  @override
  List<EventReceipt> list() {
    final directory = _directory;
    if (!directory.existsSync()) return const [];
    final entries = directory.listSync(followLinks: false);
    final unexpected = entries.where((entry) {
      final name = p.basename(entry.path);
      return entry is! File || !_receiptName.hasMatch(name);
    }).toList();
    if (unexpected.isNotEmpty) {
      throw const TaskControlError(
        'event.receipt-directory-invalid',
        'Event receipt directory contains an unexpected artifact.',
      );
    }
    final receipts = entries
        .cast<File>()
        .map((file) => read(p.basenameWithoutExtension(file.path))!)
        .toList();
    receipts.sort((left, right) => left.eventId.compareTo(right.eventId));
    return receipts;
  }

  Directory get _directory =>
      Directory(p.join(controlRoot.path, '.tmp', 'mobilekit', 'events'));

  File _file(String eventId) {
    if (!_hashPattern.hasMatch(eventId)) {
      throw const TaskControlError(
        'event.id-invalid',
        'Event ID must be a SHA-256 digest.',
      );
    }
    return File(p.join(_directory.path, '$eventId.json'));
  }

  String _encode(EventReceipt receipt) =>
      '${const JsonEncoder.withIndent('  ').convert(receipt.toJson())}\n';
}

EventReceiptStatus _status(String value) => switch (value) {
  'claimed' => EventReceiptStatus.claimed,
  'accepted' => EventReceiptStatus.accepted,
  _ => throw const TaskControlError(
    'event.receipt-invalid',
    'Event receipt status is invalid.',
  ),
};

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty || value.length > 512) {
    throw const TaskControlError(
      'event.receipt-invalid',
      'Event receipt contains an invalid field.',
    );
  }
  return value;
}

String _hash(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (!_hashPattern.hasMatch(value)) {
    throw const TaskControlError(
      'event.receipt-invalid',
      'Event receipt hash is invalid.',
    );
  }
  return value;
}

String _planPath(Map<String, Object?> json, String key, String folder) {
  final value = normalizeRepositoryPath(_string(json, key));
  if (!RegExp('^docs/exec-plans/$folder/[^/]+\\.md\$').hasMatch(value)) {
    throw const TaskControlError(
      'event.receipt-invalid',
      'Event receipt plan path is invalid.',
    );
  }
  return value;
}

DateTime _date(Map<String, Object?> json, String key) {
  final value = DateTime.tryParse(_string(json, key));
  if (value == null) {
    throw const TaskControlError(
      'event.receipt-invalid',
      'Event receipt timestamp is invalid.',
    );
  }
  return value.toUtc();
}

DateTime? _optionalDate(Map<String, Object?> json, String key) =>
    json[key] == null ? null : _date(json, key);

final _hashPattern = RegExp(r'^[0-9a-f]{64}$');
final _taskId = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _receiptName = RegExp(r'^[0-9a-f]{64}\.json$');
