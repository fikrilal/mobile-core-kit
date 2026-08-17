import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

enum TaskRisk {
  low,
  medium,
  high;

  static TaskRisk parse(String value, {String label = 'Risk'}) {
    return switch (value.trim().toLowerCase()) {
      'low' => low,
      'medium' => medium,
      'high' => high,
      _ => throw TaskPlanError(
        'plan.risk-invalid',
        '$label must be low, medium, or high.',
      ),
    };
  }

  static TaskRisk maximum(Iterable<TaskRisk> values) {
    return values.fold(
      low,
      (highest, value) => value.index > highest.index ? value : highest,
    );
  }
}

enum TaskAction {
  edit('edit'),
  verify('verify'),
  commit('commit'),
  push('push'),
  draftPr('draft-pr');

  const TaskAction(this.label);

  final String label;

  static TaskAction parse(String value) {
    return values.firstWhere(
      (action) => action.label == value.trim().toLowerCase(),
      orElse: () => throw TaskPlanError(
        'plan.action-invalid',
        "Unsupported task action '${value.trim()}'.",
      ),
    );
  }
}

enum TaskPlanStatus {
  active,
  queued,
  completed;

  static TaskPlanStatus parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'active' => active,
      'queued' => queued,
      'completed' => completed,
      _ => throw const TaskPlanError(
        'plan.status-invalid',
        'Status must be active, queued, or completed.',
      ),
    };
  }
}

class TaskImpactAreas {
  const TaskImpactAreas({
    required this.auth,
    required this.navigation,
    required this.api,
    required this.database,
    required this.platform,
    required this.ui,
    required this.harness,
    required this.externalSystems,
  });

  final bool auth;
  final bool navigation;
  final bool api;
  final bool database;
  final bool platform;
  final bool ui;
  final bool harness;
  final bool externalSystems;

  Map<String, Object?> toJson() => {
    'auth': auth,
    'navigation': navigation,
    'api': api,
    'database': database,
    'platform': platform,
    'ui': ui,
    'harness': harness,
    'externalSystems': externalSystems,
  };

  factory TaskImpactAreas.fromJson(Map<String, Object?> json) {
    bool field(String name) {
      final value = json[name];
      if (value is! bool) {
        throw TaskPlanError(
          'state.invalid',
          "Task impact '$name' must be boolean.",
        );
      }
      return value;
    }

    return TaskImpactAreas(
      auth: field('auth'),
      navigation: field('navigation'),
      api: field('api'),
      database: field('database'),
      platform: field('platform'),
      ui: field('ui'),
      harness: field('harness'),
      externalSystems: field('externalSystems'),
    );
  }
}

class TaskBoundaries {
  const TaskBoundaries({
    required this.allowedPaths,
    required this.allowedActions,
    required this.maximumRisk,
    required this.repairLimit,
    required this.timeout,
  });

  final List<String> allowedPaths;
  final List<TaskAction> allowedActions;
  final TaskRisk maximumRisk;
  final int repairLimit;
  final Duration timeout;

  Map<String, Object?> toJson() => {
    'allowedPaths': allowedPaths,
    'allowedActions': allowedActions.map((action) => action.label).toList(),
    'maximumRisk': maximumRisk.name,
    'repairLimit': repairLimit,
    'timeoutSeconds': timeout.inSeconds,
  };

  factory TaskBoundaries.fromJson(Map<String, Object?> json) {
    final rawPaths = json['allowedPaths'];
    final rawActions = json['allowedActions'];
    final repairLimit = json['repairLimit'];
    final timeoutSeconds = json['timeoutSeconds'];
    if (rawPaths is! List ||
        rawPaths.any((path) => path is! String) ||
        rawActions is! List ||
        rawActions.any((action) => action is! String) ||
        repairLimit is! int ||
        repairLimit < 0 ||
        timeoutSeconds is! int ||
        timeoutSeconds <= 0) {
      throw const TaskPlanError(
        'state.invalid',
        'Task boundaries are invalid.',
      );
    }
    final paths = rawPaths.cast<String>().map(normalizeAllowedPath).toList();
    final actions = rawActions.cast<String>().map(TaskAction.parse).toList();
    _assertUnique(paths, 'Allowed paths');
    _assertUnique(actions, 'Allowed actions');
    return TaskBoundaries(
      allowedPaths: List.unmodifiable(paths),
      allowedActions: List.unmodifiable(actions),
      maximumRisk: TaskRisk.parse(
        _requiredString(json, 'maximumRisk'),
        label: 'Maximum risk',
      ),
      repairLimit: repairLimit,
      timeout: Duration(seconds: timeoutSeconds),
    );
  }
}

class TaskPlan {
  const TaskPlan({
    required this.path,
    required this.taskId,
    required this.status,
    required this.owner,
    required this.risk,
    required this.authority,
    required this.boundaries,
    required this.impacts,
    required this.sourceHash,
    required this.authorityHash,
  });

  final String path;
  final String taskId;
  final TaskPlanStatus status;
  final String owner;
  final TaskRisk risk;
  final String authority;
  final TaskBoundaries boundaries;
  final TaskImpactAreas impacts;
  final String sourceHash;
  final String authorityHash;
}

class TaskPlanError implements Exception {
  const TaskPlanError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

const requiredV2Sections = <String>[
  'Objective',
  'Constraints',
  'Impact Areas',
  'Acceptance Scenarios',
  'Acceptance Criteria',
  'Implementation Checklist',
  'Decision Log',
  'Verification',
  'Runtime Evidence',
  'Rollback',
  'Risks And Mitigations',
  'Completion Notes',
  'Follow-ups',
];

TaskPlan parseTaskPlan(String path, String source) {
  if (_metadata(source, 'Plan version') != '2') {
    throw const TaskPlanError(
      'plan.version-invalid',
      'Plan version must be 2.',
    );
  }
  final taskId = _metadata(source, 'Task ID');
  if (!RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$').hasMatch(taskId)) {
    throw const TaskPlanError(
      'plan.task-id-invalid',
      'Task ID must be 3-80 lowercase kebab-case characters.',
    );
  }
  final status = TaskPlanStatus.parse(_metadata(source, 'Status'));
  final owner = _metadata(source, 'Owner');
  final risk = TaskRisk.parse(_metadata(source, 'Risk'));
  final authority = _metadata(source, 'Authority');
  final allowedPaths = _metadataList(
    source,
    'Allowed paths',
  ).map(normalizeAllowedPath).toList();
  final allowedActions = _metadataList(
    source,
    'Allowed actions',
  ).map(TaskAction.parse).toList();
  _assertUnique(allowedPaths, 'Allowed paths');
  _assertUnique(allowedActions, 'Allowed actions');
  final maximumRisk = TaskRisk.parse(
    _metadata(source, 'Maximum risk'),
    label: 'Maximum risk',
  );
  if (risk.index > maximumRisk.index) {
    throw const TaskPlanError(
      'plan.risk-above-maximum',
      'Declared Risk cannot exceed Maximum risk.',
    );
  }
  final repairLimit = _wholeNumber(_metadata(source, 'Repair limit'));
  if (repairLimit > 10) {
    throw const TaskPlanError(
      'plan.repair-limit-invalid',
      'Repair limit must be between 0 and 10.',
    );
  }
  final timeout = _duration(_metadata(source, 'Task timeout'));
  final impacts = _parseImpacts(source);
  for (final section in requiredV2Sections) {
    final count = RegExp(
      '^## ${RegExp.escape(section)}\\s*\$',
      multiLine: true,
      caseSensitive: false,
    ).allMatches(source).length;
    if (count != 1) {
      throw TaskPlanError(
        'plan.section-cardinality',
        "Plan must contain exactly one '## $section' section.",
      );
    }
  }

  final boundaries = TaskBoundaries(
    allowedPaths: List.unmodifiable(allowedPaths),
    allowedActions: List.unmodifiable(allowedActions),
    maximumRisk: maximumRisk,
    repairLimit: repairLimit,
    timeout: timeout,
  );
  final authorityMaterial = jsonEncode({
    'version': 2,
    'taskId': taskId,
    'owner': owner,
    'risk': risk.name,
    'authority': authority,
    'boundaries': boundaries.toJson(),
    'impacts': impacts.toJson(),
  });
  return TaskPlan(
    path: normalizeRepositoryPath(path),
    taskId: taskId,
    status: status,
    owner: owner,
    risk: risk,
    authority: authority,
    boundaries: boundaries,
    impacts: impacts,
    sourceHash: sha256String(source),
    authorityHash: sha256String(authorityMaterial),
  );
}

String normalizeRepositoryPath(String value) {
  final normalized = value.trim().replaceAll('\\', '/');
  final withoutPrefix = normalized.startsWith('./')
      ? normalized.substring(2)
      : normalized;
  if (withoutPrefix.isEmpty ||
      withoutPrefix == '.' ||
      p.isAbsolute(withoutPrefix) ||
      RegExp(r'^[A-Za-z]:/').hasMatch(withoutPrefix) ||
      withoutPrefix.split('/').contains('..')) {
    throw TaskPlanError(
      'plan.path-invalid',
      "Path must stay inside the repository: '$value'.",
    );
  }
  return withoutPrefix;
}

String normalizeAllowedPath(String value) {
  final normalized = normalizeRepositoryPath(value);
  if (RegExp(r'[*?\[\]{}!\s]').hasMatch(normalized) ||
      normalized.contains('//') ||
      normalized == 'lib/' ||
      normalized == 'docs/' ||
      normalized == 'packages/' ||
      normalized == '.github/' ||
      normalized == '.git' ||
      normalized.startsWith('.git/')) {
    throw TaskPlanError(
      'plan.allowed-path-ambiguous',
      "Allowed path must be an explicit file or narrow directory: '$value'.",
    );
  }
  return normalized;
}

List<String> findScopeViolations(
  Iterable<String> paths,
  List<String> allowedPaths,
) {
  return paths
      .map(normalizeRepositoryPath)
      .where(
        (path) => !allowedPaths.any(
          (allowed) => allowed.endsWith('/')
              ? path.startsWith(allowed)
              : path == allowed,
        ),
      )
      .toSet()
      .toList()
    ..sort();
}

void assertActionAllowed(TaskBoundaries boundaries, TaskAction action) {
  if (!boundaries.allowedActions.contains(action)) {
    throw TaskPlanError(
      'task.action-not-authorized',
      "Task plan does not authorize '${action.label}'.",
    );
  }
}

void assertAllowedPathsStayInRepository(
  Directory root,
  List<String> allowedPaths,
) {
  final canonicalRoot = root.resolveSymbolicLinksSync();
  for (final allowedPath in allowedPaths) {
    var candidate = p.join(root.path, allowedPath);
    while (candidate != root.path &&
        !FileSystemEntity.isFileSync(candidate) &&
        !FileSystemEntity.isDirectorySync(candidate) &&
        !FileSystemEntity.isLinkSync(candidate)) {
      candidate = p.dirname(candidate);
    }
    final canonical = _resolveExistingPath(candidate);
    if (!p.isWithin(canonicalRoot, canonical) && canonical != canonicalRoot) {
      throw TaskPlanError(
        'plan.path-symlink-escape',
        "Allowed path escapes through a symlink: '$allowedPath'.",
      );
    }
  }
}

String _resolveExistingPath(String path) {
  if (Link(path).existsSync()) return Link(path).resolveSymbolicLinksSync();
  if (Directory(path).existsSync()) {
    return Directory(path).resolveSymbolicLinksSync();
  }
  return File(path).resolveSymbolicLinksSync();
}

String sha256String(String value) =>
    sha256.convert(utf8.encode(value)).toString();

TaskImpactAreas _parseImpacts(String source) {
  return TaskImpactAreas(
    auth: _impact(source, 'Auth/session'),
    navigation: _impact(source, 'Navigation/deep links/startup'),
    api: _impact(source, 'API/contracts'),
    database: _impact(source, 'Database/migrations'),
    platform: _impact(source, 'Platform/Firebase/permissions'),
    ui: _impact(source, 'UI/UX/accessibility'),
    harness: _impact(source, 'Harness/CI/release'),
    externalSystems: _impact(source, 'External systems'),
  );
}

bool _impact(String source, String name) {
  final matches = RegExp(
    '^- ${RegExp.escape(name)}:\\s*(yes|no)\\s*\$',
    multiLine: true,
    caseSensitive: false,
  ).allMatches(source).toList();
  if (matches.length != 1) {
    throw TaskPlanError(
      'plan.impact-cardinality',
      "Plan must contain exactly one '- $name: yes | no' declaration.",
    );
  }
  return matches.single.group(1)!.toLowerCase() == 'yes';
}

String _metadata(String source, String name) {
  final matches = RegExp(
    '^\\*\\*${RegExp.escape(name)}:\\*\\*\\s*(.+)\$',
    multiLine: true,
  ).allMatches(source).toList();
  if (matches.length != 1) {
    throw TaskPlanError(
      'plan.metadata-cardinality',
      "Plan must contain exactly one non-empty '**$name:**' field.",
    );
  }
  final value = matches.single.group(1)!.trim();
  if (value.isEmpty) {
    throw TaskPlanError(
      'plan.metadata-empty',
      "Plan metadata '$name' cannot be empty.",
    );
  }
  return value;
}

List<String> _metadataList(String source, String name) {
  final values = _metadata(source, name)
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
  if (values.isEmpty) {
    throw TaskPlanError('plan.list-empty', '$name must not be empty.');
  }
  return values;
}

int _wholeNumber(String value) {
  if (!RegExp(r'^\d+$').hasMatch(value)) {
    throw const TaskPlanError(
      'plan.number-invalid',
      'Repair limit must be a whole number.',
    );
  }
  return int.parse(value);
}

Duration _duration(String value) {
  final match = RegExp(r'^(\d+)(s|m|h)$').firstMatch(value.toLowerCase());
  if (match == null) {
    throw const TaskPlanError(
      'plan.timeout-invalid',
      'Task timeout must use seconds, minutes, or hours.',
    );
  }
  final amount = int.parse(match.group(1)!);
  final duration = switch (match.group(2)) {
    's' => Duration(seconds: amount),
    'm' => Duration(minutes: amount),
    _ => Duration(hours: amount),
  };
  if (amount <= 0 || duration > const Duration(hours: 24)) {
    throw const TaskPlanError(
      'plan.timeout-invalid',
      'Task timeout must be greater than zero and at most 24h.',
    );
  }
  return duration;
}

void _assertUnique(Iterable<Object> values, String label) {
  final list = values.toList();
  if (list.toSet().length != list.length) {
    throw TaskPlanError(
      'plan.list-duplicate',
      '$label must not contain duplicates.',
    );
  }
}

String _requiredString(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value is! String || value.isEmpty) {
    throw TaskPlanError('state.invalid', "Task state '$name' is invalid.");
  }
  return value;
}
