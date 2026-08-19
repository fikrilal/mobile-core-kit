import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/private_artifact.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

enum HandoffStatus { prepared, executing, completed, uncertain }

class HandoffApproval {
  const HandoffApproval({
    required this.taskId,
    required this.action,
    required this.status,
    required this.taskFingerprint,
    required this.authorityHash,
    required this.attempt,
    required this.branch,
    required this.remote,
    required this.changedPaths,
    required this.challengeHash,
    required this.preparedAt,
    required this.expiresAt,
    this.completedAt,
    this.outcome,
  });

  static const schemaVersion = 1;

  final String taskId;
  final TaskAction action;
  final HandoffStatus status;
  final String taskFingerprint;
  final String authorityHash;
  final int attempt;
  final String branch;
  final String remote;
  final List<String> changedPaths;
  final String challengeHash;
  final DateTime preparedAt;
  final DateTime expiresAt;
  final DateTime? completedAt;
  final String? outcome;

  HandoffApproval transition(
    HandoffStatus next, {
    DateTime? completedAt,
    String? outcome,
  }) => HandoffApproval(
    taskId: taskId,
    action: action,
    status: next,
    taskFingerprint: taskFingerprint,
    authorityHash: authorityHash,
    attempt: attempt,
    branch: branch,
    remote: remote,
    changedPaths: changedPaths,
    challengeHash: challengeHash,
    preparedAt: preparedAt,
    expiresAt: expiresAt,
    completedAt: completedAt,
    outcome: outcome,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'taskId': taskId,
    'action': action.label,
    'status': status.name,
    'taskFingerprint': taskFingerprint,
    'authorityHash': authorityHash,
    'attempt': attempt,
    'branch': branch,
    'remote': remote,
    'changedPaths': changedPaths,
    'challengeHash': challengeHash,
    'preparedAt': preparedAt.toUtc().toIso8601String(),
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    if (completedAt != null)
      'completedAt': completedAt!.toUtc().toIso8601String(),
    if (outcome != null) 'outcome': outcome,
  };

  factory HandoffApproval.fromJson(Map<String, Object?> json) {
    const requiredKeys = {
      'schemaVersion',
      'taskId',
      'action',
      'status',
      'taskFingerprint',
      'authorityHash',
      'attempt',
      'branch',
      'remote',
      'changedPaths',
      'challengeHash',
      'preparedAt',
      'expiresAt',
    };
    const optionalKeys = {'completedAt', 'outcome'};
    if (json['schemaVersion'] != schemaVersion ||
        !json.keys.toSet().containsAll(requiredKeys) ||
        json.keys.any(
          (key) => !requiredKeys.contains(key) && !optionalKeys.contains(key),
        )) {
      return _invalid();
    }
    final action = switch (_string(json, 'action')) {
      'commit' => TaskAction.commit,
      'push' => TaskAction.push,
      'draft-pr' => TaskAction.draftPr,
      _ => _invalid(),
    };
    final status = HandoffStatus.values.firstWhere(
      (candidate) => candidate.name == _string(json, 'status'),
      orElse: _invalid,
    );
    final completedAt = _optionalDate(json, 'completedAt');
    final outcome = _optionalString(json, 'outcome');
    final terminal =
        status == HandoffStatus.completed || status == HandoffStatus.uncertain;
    if (terminal != (completedAt != null && outcome != null) ||
        (!terminal && (completedAt != null || outcome != null))) {
      return _invalid();
    }
    final attempt = json['attempt'];
    if (attempt is! int || attempt <= 0) return _invalid();
    final taskId = _string(json, 'taskId');
    final branch = _string(json, 'branch');
    final remote = _string(json, 'remote');
    final rawPaths = json['changedPaths'];
    if (!_taskId.hasMatch(taskId) ||
        !_validBranch(branch) ||
        !_remote.hasMatch(remote) ||
        rawPaths is! List ||
        rawPaths.isEmpty ||
        rawPaths.any((path) => path is! String)) {
      return _invalid();
    }
    final paths = rawPaths.cast<String>().map(normalizeRepositoryPath).toList();
    if (paths.toSet().length != paths.length) return _invalid();
    paths.sort();
    return HandoffApproval(
      taskId: taskId,
      action: action,
      status: status,
      taskFingerprint: _hash(json, 'taskFingerprint'),
      authorityHash: _hash(json, 'authorityHash'),
      attempt: attempt,
      branch: branch,
      remote: remote,
      changedPaths: List.unmodifiable(paths),
      challengeHash: _hash(json, 'challengeHash'),
      preparedAt: _date(json, 'preparedAt'),
      expiresAt: _date(json, 'expiresAt'),
      completedAt: completedAt,
      outcome: outcome,
    );
  }
}

abstract interface class HandoffApprovalStore {
  HandoffApproval? read(String taskId, TaskAction action);

  void write(HandoffApproval approval);
}

class FileHandoffApprovalStore implements HandoffApprovalStore {
  const FileHandoffApprovalStore(this.controlRoot);

  static const maximumBytes = 32 * 1024;

  final Directory controlRoot;

  @override
  HandoffApproval? read(String taskId, TaskAction action) {
    final file = _file(taskId, action);
    if (!file.existsSync()) return null;
    if (file.lengthSync() > maximumBytes) {
      throw const TaskControlError(
        'handoff.approval-too-large',
        'Handoff approval exceeds its size limit.',
      );
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) throw const FormatException();
      return HandoffApproval.fromJson(decoded.cast<String, Object?>());
    } on TaskControlError {
      rethrow;
    } on Object {
      throw const TaskControlError(
        'handoff.approval-invalid',
        'Handoff approval is unreadable.',
      );
    }
  }

  @override
  void write(HandoffApproval approval) {
    HandoffApproval.fromJson(approval.toJson());
    writePrivateFile(
      _file(approval.taskId, approval.action),
      '${const JsonEncoder.withIndent('  ').convert(approval.toJson())}\n',
    );
  }

  File _file(String taskId, TaskAction action) {
    if (!_taskId.hasMatch(taskId) ||
        !const {
          TaskAction.commit,
          TaskAction.push,
          TaskAction.draftPr,
        }.contains(action)) {
      throw const TaskControlError(
        'handoff.approval-invalid',
        'Handoff approval identity is invalid.',
      );
    }
    return File(
      p.join(
        controlRoot.path,
        '.tmp',
        'mobilekit',
        'tasks',
        taskId,
        'handoff',
        '${action.label}.json',
      ),
    );
  }
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String ||
      value.isEmpty ||
      value.length > 512 ||
      value.contains('\u0000')) {
    return _invalid();
  }
  return value;
}

String? _optionalString(Map<String, Object?> json, String key) {
  if (json[key] == null) return null;
  final value = _string(json, key);
  if (value.contains('\n') || value.contains('\r')) return _invalid();
  return value;
}

String _hash(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (!_sha256.hasMatch(value)) return _invalid();
  return value;
}

DateTime _date(Map<String, Object?> json, String key) {
  final value = DateTime.tryParse(_string(json, key));
  if (value == null) return _invalid();
  return value.toUtc();
}

DateTime? _optionalDate(Map<String, Object?> json, String key) =>
    json[key] == null ? null : _date(json, key);

bool _validBranch(String value) =>
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{0,127}$').hasMatch(value) &&
    !value.contains('..') &&
    !value.endsWith('/') &&
    value != 'main' &&
    value != 'master';

Never _invalid() => throw const TaskControlError(
  'handoff.approval-invalid',
  'Handoff approval is malformed.',
);

final _taskId = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _sha256 = RegExp(r'^[0-9a-f]{64}$');
final _remote = RegExp(r'^[a-z0-9.-]+/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$');
