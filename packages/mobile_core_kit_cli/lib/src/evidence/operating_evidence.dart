import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

const operatingEvidencePath =
    'docs/engineering/harness_operating_evidence.json';
const evidenceCalibrationPath = 'harness/evidence_calibration.json';

class OperatingEvidenceError implements Exception {
  const OperatingEvidenceError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}

class EvidenceLane {
  const EvidenceLane({required this.id, required this.durationMs});

  final String id;
  final int durationMs;
}

class OperatingEvidenceRecord {
  const OperatingEvidenceRecord({
    required this.taskId,
    required this.completedPlan,
    required this.completedPlanSha256,
    required this.effectiveRisk,
    required this.impactCategories,
    required this.firstPass,
    required this.eventualOutcome,
    required this.lanes,
    required this.failedBoundary,
    required this.repairOrEscalation,
    required this.reviewedAt,
    required this.ciRevision,
    required this.ciRunId,
    required this.harnessRevision,
  });

  final String taskId;
  final String completedPlan;
  final String completedPlanSha256;
  final String effectiveRisk;
  final List<String> impactCategories;
  final bool firstPass;
  final String eventualOutcome;
  final List<EvidenceLane> lanes;
  final String failedBoundary;
  final String repairOrEscalation;
  final DateTime reviewedAt;
  final String ciRevision;
  final int ciRunId;
  final String harnessRevision;
}

class OperatingEvidenceLedger {
  const OperatingEvidenceLedger(this.records);

  final List<OperatingEvidenceRecord> records;
}

class EvidenceAssessment {
  const EvidenceAssessment({
    required this.recordCount,
    required this.riskClasses,
    required this.repairOrEscalationCount,
    required this.profileCounts,
    required this.profileDurationMs,
    required this.missing,
  });

  final int recordCount;
  final int riskClasses;
  final int repairOrEscalationCount;
  final Map<String, int> profileCounts;
  final Map<String, int> profileDurationMs;
  final List<String> missing;

  bool get eligible => missing.isEmpty;
}

class EvidenceCalibration {
  const EvidenceCalibration({
    required this.observedAt,
    required this.coveredLines,
    required this.executableLines,
    required this.observedBasisPoints,
    required this.enforcedFloorBasisPoints,
    required this.profileBudgetsMs,
  });

  final DateTime observedAt;
  final int coveredLines;
  final int executableLines;
  final int observedBasisPoints;
  final int enforcedFloorBasisPoints;
  final Map<String, ({int observedMs, int advisoryBudgetMs})> profileBudgetsMs;
}

OperatingEvidenceLedger readOperatingEvidence(Directory root) {
  final file = File(p.join(root.path, operatingEvidencePath));
  final decoded = _readJson(file, kind: 'Operating evidence');
  return parseOperatingEvidence(root, decoded);
}

OperatingEvidenceLedger parseOperatingEvidence(Directory root, Object? value) {
  final map = _object(value);
  _exactKeys(map, const {'schemaVersion', 'records'});
  if (map['schemaVersion'] != 1 || map['records'] is! List) {
    throw _invalid();
  }
  final rawRecords = map['records']! as List;
  if (rawRecords.length > 100) throw _invalid();
  final records = rawRecords
      .map((record) => _parseRecord(root, record))
      .toList(growable: false);
  final taskIds = records.map((record) => record.taskId).toList();
  if (taskIds.toSet().length != taskIds.length || !_isStrictlySorted(taskIds)) {
    throw _invalid();
  }
  return OperatingEvidenceLedger(records);
}

EvidenceCalibration readEvidenceCalibration(Directory root) {
  final file = File(p.join(root.path, evidenceCalibrationPath));
  final decoded = _readJson(file, kind: 'Evidence calibration');
  final map = _object(decoded);
  _exactKeys(map, const {'schemaVersion', 'coverage', 'profiles'});
  final coverage = _object(map['coverage']);
  _exactKeys(coverage, const {
    'observedAt',
    'sourcePlan',
    'coveredLines',
    'executableLines',
    'observedBasisPoints',
    'enforcedFloorBasisPoints',
  });
  if (map['schemaVersion'] != 1 || map['profiles'] is! List) throw _invalid();
  final observedAt = _date(coverage['observedAt']);
  final sourcePlan = _completedPlanPath(coverage['sourcePlan']);
  _requireExistingFile(root, sourcePlan);
  final coveredLines = _boundedInt(coverage['coveredLines'], max: 10000000);
  final executableLines = _boundedInt(
    coverage['executableLines'],
    min: 1,
    max: 10000000,
  );
  final observedBasisPoints = _boundedInt(
    coverage['observedBasisPoints'],
    max: 10000,
  );
  final enforcedFloorBasisPoints = _boundedInt(
    coverage['enforcedFloorBasisPoints'],
    max: 10000,
  );
  if (coveredLines > executableLines ||
      (coveredLines * 10000 ~/ executableLines) != observedBasisPoints ||
      enforcedFloorBasisPoints > observedBasisPoints) {
    throw _invalid();
  }
  _validateCoverageFloor(root, enforcedFloorBasisPoints);

  final profiles = <String, ({int observedMs, int advisoryBudgetMs})>{};
  for (final value in map['profiles']! as List) {
    final profile = _object(value);
    _exactKeys(profile, const {
      'id',
      'observedDurationMs',
      'advisoryBudgetMs',
      'sourcePlan',
    });
    final id = profile['id'];
    if (id is! String || !const {'fast', 'full'}.contains(id)) throw _invalid();
    final profileSource = _completedPlanPath(profile['sourcePlan']);
    _requireExistingFile(root, profileSource);
    final observedMs = _boundedInt(
      profile['observedDurationMs'],
      min: 1,
      max: 86400000,
    );
    final advisoryBudgetMs = _boundedInt(
      profile['advisoryBudgetMs'],
      min: observedMs,
      max: 86400000,
    );
    if (profiles.containsKey(id)) throw _invalid();
    profiles[id] = (observedMs: observedMs, advisoryBudgetMs: advisoryBudgetMs);
  }
  if (profiles.keys.join(',') != 'fast,full') throw _invalid();
  return EvidenceCalibration(
    observedAt: observedAt,
    coveredLines: coveredLines,
    executableLines: executableLines,
    observedBasisPoints: observedBasisPoints,
    enforcedFloorBasisPoints: enforcedFloorBasisPoints,
    profileBudgetsMs: Map.unmodifiable(profiles),
  );
}

EvidenceAssessment assessOperatingEvidence(OperatingEvidenceLedger ledger) {
  final risks = ledger.records.map((record) => record.effectiveRisk).toSet();
  final repaired = ledger.records
      .where((record) => record.repairOrEscalation != 'none')
      .length;
  final counts = <String, int>{};
  final durations = <String, int>{};
  for (final lane in ledger.records.expand((record) => record.lanes)) {
    counts.update(lane.id, (value) => value + 1, ifAbsent: () => 1);
    durations.update(
      lane.id,
      (value) => value + lane.durationMs,
      ifAbsent: () => lane.durationMs,
    );
  }
  final missing = <String>[
    if (ledger.records.length < 5) 'five-reviewed-tasks',
    if (risks.length < 2) 'two-risk-classes',
    if (repaired < 1) 'repair-or-escalation',
  ];
  return EvidenceAssessment(
    recordCount: ledger.records.length,
    riskClasses: risks.length,
    repairOrEscalationCount: repaired,
    profileCounts: Map.unmodifiable(counts),
    profileDurationMs: Map.unmodifiable(durations),
    missing: List.unmodifiable(missing),
  );
}

OperatingEvidenceRecord _parseRecord(Directory root, Object? value) {
  final map = _object(value);
  _exactKeys(map, const {
    'taskId',
    'completedPlan',
    'completedPlanSha256',
    'effectiveRisk',
    'impactCategories',
    'firstPass',
    'eventualOutcome',
    'lanes',
    'failedBoundary',
    'repairOrEscalation',
    'review',
    'ci',
    'harnessRevision',
  });
  final taskId = _stableId(map['taskId'], _taskId);
  final completedPlan = _completedPlanPath(map['completedPlan']);
  final planFile = _requireExistingFile(root, completedPlan);
  final completedPlanSha256 = _hash(map['completedPlanSha256']);
  if (sha256.convert(planFile.readAsBytesSync()).toString() !=
      completedPlanSha256) {
    throw _invalid();
  }
  final plan = parseTaskPlan(completedPlan, planFile.readAsStringSync());
  if (plan.taskId != taskId || plan.status != TaskPlanStatus.completed) {
    throw _invalid();
  }
  final effectiveRisk = map['effectiveRisk'];
  if (effectiveRisk is! String ||
      !const {'low', 'medium', 'high'}.contains(effectiveRisk)) {
    throw _invalid();
  }
  final effectiveRiskValue = TaskRisk.parse(effectiveRisk);
  if (effectiveRiskValue.index < plan.risk.index ||
      effectiveRiskValue.index > plan.boundaries.maximumRisk.index) {
    throw _invalid();
  }
  final impactCategories = _stringList(
    map['impactCategories'],
    allowed: _impactCategories,
    requireNonEmpty: true,
  );
  if (_planImpacts(
    plan,
  ).toSet().difference(impactCategories.toSet()).isNotEmpty) {
    throw _invalid();
  }
  if (map['firstPass'] is! bool) throw _invalid();
  final eventualOutcome = map['eventualOutcome'];
  if (eventualOutcome != 'completed' && eventualOutcome != 'blocked') {
    throw _invalid();
  }
  final lanes = _laneList(map['lanes']);
  final requiredLane = effectiveRisk == 'low' ? 'fast' : 'full';
  if (!lanes.any((lane) => lane.id == requiredLane)) throw _invalid();
  final failedBoundary = map['failedBoundary'];
  if (failedBoundary is! String ||
      !const {
        'none',
        'preflight',
        'fast',
        'full',
        'runtime',
        'ci',
      }.contains(failedBoundary)) {
    throw _invalid();
  }
  final repairOrEscalation = map['repairOrEscalation'];
  if (repairOrEscalation is! String ||
      !const {'none', 'repair', 'escalation'}.contains(repairOrEscalation) ||
      (repairOrEscalation == 'none') != (failedBoundary == 'none')) {
    throw _invalid();
  }
  if ((map['firstPass'] == true) != (repairOrEscalation == 'none')) {
    throw _invalid();
  }
  final review = _object(map['review']);
  _exactKeys(review, const {'independent', 'decision', 'reviewedAt'});
  if (review['independent'] != true || review['decision'] != 'accepted') {
    throw _invalid();
  }
  final ci = _object(map['ci']);
  _exactKeys(ci, const {'reproduced', 'revision', 'runId'});
  if (ci['reproduced'] != true) throw _invalid();
  final ciRevision = _gitRevision(ci['revision']);
  final harnessRevision = _gitRevision(map['harnessRevision']);
  if (ciRevision != harnessRevision) throw _invalid();
  return OperatingEvidenceRecord(
    taskId: taskId,
    completedPlan: completedPlan,
    completedPlanSha256: completedPlanSha256,
    effectiveRisk: effectiveRisk,
    impactCategories: impactCategories,
    firstPass: map['firstPass']! as bool,
    eventualOutcome: eventualOutcome! as String,
    lanes: lanes,
    failedBoundary: failedBoundary,
    repairOrEscalation: repairOrEscalation,
    reviewedAt: _date(review['reviewedAt']),
    ciRevision: ciRevision,
    ciRunId: _boundedInt(ci['runId'], min: 1, max: 9007199254740991),
    harnessRevision: harnessRevision,
  );
}

List<EvidenceLane> _laneList(Object? value) {
  if (value is! List || value.isEmpty) throw _invalid();
  final lanes = value
      .map((raw) {
        final lane = _object(raw);
        _exactKeys(lane, const {'id', 'status', 'durationMs'});
        final id = lane['id'];
        if (id is! String ||
            !const {'fast', 'full', 'runtime', 'ci'}.contains(id) ||
            lane['status'] != 'passed') {
          throw _invalid();
        }
        return EvidenceLane(
          id: id,
          durationMs: _boundedInt(lane['durationMs'], max: 86400000),
        );
      })
      .toList(growable: false);
  final ids = lanes.map((lane) => lane.id).toList();
  if (ids.toSet().length != ids.length || !_isStrictlySorted(ids)) {
    throw _invalid();
  }
  return lanes;
}

Object? _readJson(File file, {required String kind}) {
  if (!file.existsSync()) {
    throw OperatingEvidenceError('evidence.missing', '$kind file is missing.');
  }
  if (file.lengthSync() > 256 * 1024) {
    throw OperatingEvidenceError(
      'evidence.oversized',
      '$kind file exceeds 256 KiB.',
    );
  }
  try {
    return jsonDecode(file.readAsStringSync());
  } on FormatException {
    throw OperatingEvidenceError(
      'evidence.unreadable',
      '$kind file is not valid JSON.',
    );
  }
}

Map<String, Object?> _object(Object? value) {
  if (value is! Map) throw _invalid();
  try {
    return value.cast<String, Object?>();
  } on TypeError {
    throw _invalid();
  }
}

void _exactKeys(Map<String, Object?> value, Set<String> expected) {
  if (value.keys.toSet().difference(expected).isNotEmpty ||
      expected.difference(value.keys.toSet()).isNotEmpty) {
    throw _invalid();
  }
}

List<String> _stringList(
  Object? value, {
  required Set<String> allowed,
  bool requireNonEmpty = false,
}) {
  if (value is! List || (requireNonEmpty && value.isEmpty)) throw _invalid();
  final items = value.whereType<String>().toList(growable: false);
  if (items.length != value.length ||
      items.any((item) => !allowed.contains(item)) ||
      items.toSet().length != items.length ||
      !_isStrictlySorted(items)) {
    throw _invalid();
  }
  return items;
}

bool _isStrictlySorted(List<String> values) {
  for (var index = 1; index < values.length; index++) {
    if (values[index - 1].compareTo(values[index]) >= 0) return false;
  }
  return true;
}

List<String> _planImpacts(TaskPlan plan) => <String>[
  if (plan.impacts.api) 'api',
  if (plan.impacts.auth) 'auth',
  if (plan.impacts.database) 'database',
  if (plan.impacts.externalSystems) 'external-systems',
  if (plan.impacts.harness) 'harness',
  if (plan.impacts.navigation) 'navigation',
  if (plan.impacts.platform) 'platform',
  if (plan.impacts.ui) 'ui',
];

void _validateCoverageFloor(Directory root, int basisPoints) {
  final workflow = File(
    p.join(root.path, '.github', 'workflows', 'governance.yml'),
  );
  if (!workflow.existsSync()) throw _invalid();
  final match = RegExp(
    r'^\s*COVERAGE_MIN:\s*"(\d+(?:\.\d+)?)"\s*$',
    multiLine: true,
  ).firstMatch(workflow.readAsStringSync());
  final value = match == null ? null : double.tryParse(match.group(1)!);
  if (value == null || (value * 100).round() != basisPoints) throw _invalid();
}

String _completedPlanPath(Object? value) {
  if (value is! String || !_completedPlan.hasMatch(value)) throw _invalid();
  return value;
}

File _requireExistingFile(Directory root, String relativePath) {
  final file = File(p.join(root.path, relativePath));
  if (!file.existsSync()) throw _invalid();
  return file;
}

String _stableId(Object? value, RegExp pattern) {
  if (value is! String || !pattern.hasMatch(value)) throw _invalid();
  return value;
}

String _hash(Object? value) => _stableId(value, _sha256);

String _gitRevision(Object? value) => _stableId(value, _revision);

int _boundedInt(Object? value, {int min = 0, required int max}) {
  if (value is! int || value < min || value > max) throw _invalid();
  return value;
}

DateTime _date(Object? value) {
  if (value is! String || !_isoDate.hasMatch(value)) throw _invalid();
  final parsed = DateTime.tryParse(value);
  if (parsed == null || parsed.toIso8601String().substring(0, 10) != value) {
    throw _invalid();
  }
  return parsed;
}

OperatingEvidenceError _invalid() => const OperatingEvidenceError(
  'evidence.schema-invalid',
  'Operating evidence does not match sanitized schema version 1.',
);

final _taskId = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _sha256 = RegExp(r'^[0-9a-f]{64}$');
final _revision = RegExp(r'^[0-9a-f]{40}$');
final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _completedPlan = RegExp(
  r'^docs/exec-plans/completed/[a-z0-9][a-z0-9_.-]{2,119}\.md$',
);
const _impactCategories = {
  'api',
  'auth',
  'database',
  'external-systems',
  'harness',
  'navigation',
  'platform',
  'ui',
};
