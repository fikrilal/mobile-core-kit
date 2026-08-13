import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

const harnessImprovementPath = 'docs/engineering/harness_improvements.json';

class HarnessImprovementError implements Exception {
  const HarnessImprovementError(this.code, this.message);

  final String code;
  final String message;
}

class HarnessTrend {
  const HarnessTrend({
    required this.evidence,
    required this.repairRateBasisPoints,
    required this.blockedRateBasisPoints,
    required this.recurringBoundaries,
  });

  final EvidenceAssessment evidence;
  final int repairRateBasisPoints;
  final int blockedRateBasisPoints;
  final Map<String, int> recurringBoundaries;
}

class ImprovementEvaluation {
  const ImprovementEvaluation({
    required this.recommendation,
    required this.baselineRateBasisPoints,
    required this.observedRateBasisPoints,
    required this.effectBasisPoints,
    required this.durationIncreaseMs,
    required this.evaluatedTaskIds,
    required this.humanDecision,
    required this.decidedBy,
  });

  final String recommendation;
  final int baselineRateBasisPoints;
  final int observedRateBasisPoints;
  final int effectBasisPoints;
  final int durationIncreaseMs;
  final List<String> evaluatedTaskIds;
  final String humanDecision;
  final String decidedBy;
}

class ImprovementHypothesis {
  const ImprovementHypothesis({
    required this.id,
    required this.status,
    required this.patternBoundary,
    required this.baselineTaskIds,
    required this.targetComponent,
    required this.targetPaths,
    required this.metric,
    required this.minimumEffectBasisPoints,
    required this.maxDurationIncreaseMs,
    required this.evaluationWindow,
    required this.requiredRisk,
    required this.rollbackPaths,
    required this.invariants,
    required this.ownerId,
    required this.approverId,
    required this.approvedAt,
    required this.plan,
    required this.evaluation,
  });

  final String id;
  final String status;
  final String patternBoundary;
  final List<String> baselineTaskIds;
  final String targetComponent;
  final List<String> targetPaths;
  final String metric;
  final int minimumEffectBasisPoints;
  final int maxDurationIncreaseMs;
  final int evaluationWindow;
  final String requiredRisk;
  final List<String> rollbackPaths;
  final List<String> invariants;
  final String ownerId;
  final String? approverId;
  final DateTime? approvedAt;
  final String plan;
  final ImprovementEvaluation? evaluation;
}

class HarnessImprovementLedger {
  const HarnessImprovementLedger(this.hypotheses);

  final List<ImprovementHypothesis> hypotheses;
}

class ShadowResult {
  const ShadowResult({
    required this.status,
    required this.reason,
    required this.recommendation,
    required this.baselineRateBasisPoints,
    required this.observedRateBasisPoints,
    required this.effectBasisPoints,
    required this.durationIncreaseMs,
    required this.evaluatedTaskIds,
  });

  final String status;
  final String reason;
  final String? recommendation;
  final int? baselineRateBasisPoints;
  final int? observedRateBasisPoints;
  final int? effectBasisPoints;
  final int? durationIncreaseMs;
  final List<String> evaluatedTaskIds;
}

HarnessTrend aggregateHarnessTrend(OperatingEvidenceLedger ledger) {
  final assessment = assessOperatingEvidence(ledger);
  final boundaries = <String, int>{};
  for (final record in ledger.records) {
    if (record.failedBoundary == 'none') continue;
    boundaries.update(
      record.failedBoundary,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  boundaries.removeWhere((_, count) => count < 2);
  return HarnessTrend(
    evidence: assessment,
    repairRateBasisPoints: _rate(
      ledger.records,
      (record) => record.repairOrEscalation != 'none',
    ),
    blockedRateBasisPoints: _rate(
      ledger.records,
      (record) => record.eventualOutcome == 'blocked',
    ),
    recurringBoundaries: Map.unmodifiable(
      Map.fromEntries(boundaries.entries.toList()..sort(_entryOrder)),
    ),
  );
}

HarnessImprovementLedger readHarnessImprovements(
  Directory root,
  OperatingEvidenceLedger evidence,
) {
  final file = File(p.join(root.path, harnessImprovementPath));
  if (!file.existsSync()) {
    throw const HarnessImprovementError(
      'improvement.missing',
      'Harness improvement ledger is missing.',
    );
  }
  if (file.lengthSync() > 256 * 1024) {
    throw const HarnessImprovementError(
      'improvement.oversized',
      'Harness improvement ledger exceeds 256 KiB.',
    );
  }
  Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException {
    throw const HarnessImprovementError(
      'improvement.unreadable',
      'Harness improvement ledger is not valid JSON.',
    );
  }
  return parseHarnessImprovements(root, decoded, evidence);
}

HarnessImprovementLedger parseHarnessImprovements(
  Directory root,
  Object? value,
  OperatingEvidenceLedger evidence,
) {
  final map = _object(value);
  _exactKeys(map, const {'schemaVersion', 'hypotheses'});
  if (map['schemaVersion'] != 1 || map['hypotheses'] is! List) {
    throw _invalid();
  }
  final raw = map['hypotheses']! as List;
  if (raw.length > 20) throw _invalid();
  if (!assessOperatingEvidence(evidence).eligible && raw.isNotEmpty) {
    throw const HarnessImprovementError(
      'improvement.ineligible',
      'Improvement ledger must remain empty until operating evidence is eligible.',
    );
  }
  final evidenceById = {
    for (final record in evidence.records) record.taskId: record,
  };
  final hypotheses = raw
      .map((item) => _parseHypothesis(root, item, evidenceById))
      .toList(growable: false);
  final ids = hypotheses.map((item) => item.id).toList();
  if (!_strictlySorted(ids) || ids.toSet().length != ids.length) {
    throw _invalid();
  }
  if (hypotheses.where((item) => item.status == 'evaluating').length > 1) {
    throw const HarnessImprovementError(
      'improvement.concurrent',
      'At most one harness hypothesis may be evaluating.',
    );
  }
  final ledger = HarnessImprovementLedger(hypotheses);
  for (final hypothesis in hypotheses) {
    if (hypothesis.evaluation == null) continue;
    final result = evaluateShadow(
      evidence,
      ledger,
      hypothesisId: hypothesis.id,
    );
    final evaluation = hypothesis.evaluation!;
    if (result.status != 'evaluated' ||
        result.recommendation != evaluation.recommendation ||
        result.baselineRateBasisPoints != evaluation.baselineRateBasisPoints ||
        result.observedRateBasisPoints != evaluation.observedRateBasisPoints ||
        result.effectBasisPoints != evaluation.effectBasisPoints ||
        result.durationIncreaseMs != evaluation.durationIncreaseMs ||
        !_same(result.evaluatedTaskIds, evaluation.evaluatedTaskIds) ||
        evaluation.humanDecision != evaluation.recommendation ||
        (hypothesis.status == 'kept') != (evaluation.humanDecision == 'keep')) {
      throw _invalid();
    }
  }
  return ledger;
}

ShadowResult evaluateShadow(
  OperatingEvidenceLedger evidence,
  HarnessImprovementLedger ledger, {
  String? hypothesisId,
}) {
  final assessment = assessOperatingEvidence(evidence);
  if (!assessment.eligible) {
    return const ShadowResult(
      status: 'disabled',
      reason: 'operating-evidence-insufficient',
      recommendation: null,
      baselineRateBasisPoints: null,
      observedRateBasisPoints: null,
      effectBasisPoints: null,
      durationIncreaseMs: null,
      evaluatedTaskIds: [],
    );
  }
  final candidates = ledger.hypotheses.where(
    (item) => hypothesisId == null
        ? item.status == 'evaluating'
        : item.id == hypothesisId,
  );
  if (candidates.isEmpty) {
    return const ShadowResult(
      status: 'idle',
      reason: 'no-evaluating-hypothesis',
      recommendation: null,
      baselineRateBasisPoints: null,
      observedRateBasisPoints: null,
      effectBasisPoints: null,
      durationIncreaseMs: null,
      evaluatedTaskIds: [],
    );
  }
  if (candidates.length != 1) throw _invalid();
  final hypothesis = candidates.single;
  if (!const {'evaluating', 'kept', 'reverted'}.contains(hypothesis.status) ||
      hypothesis.approvedAt == null) {
    return const ShadowResult(
      status: 'idle',
      reason: 'hypothesis-not-evaluating',
      recommendation: null,
      baselineRateBasisPoints: null,
      observedRateBasisPoints: null,
      effectBasisPoints: null,
      durationIncreaseMs: null,
      evaluatedTaskIds: [],
    );
  }
  final byId = {for (final record in evidence.records) record.taskId: record};
  final baseline = hypothesis.baselineTaskIds
      .map((id) => byId[id]!)
      .toList(growable: false);
  final later =
      evidence.records
          .where(
            (record) =>
                !hypothesis.baselineTaskIds.contains(record.taskId) &&
                record.effectiveRisk == hypothesis.requiredRisk &&
                record.reviewedAt.isAfter(hypothesis.approvedAt!),
          )
          .toList()
        ..sort((left, right) {
          final date = left.reviewedAt.compareTo(right.reviewedAt);
          return date != 0 ? date : left.taskId.compareTo(right.taskId);
        });
  if (later.length < hypothesis.evaluationWindow) {
    return ShadowResult(
      status: 'inconclusive',
      reason: 'evaluation-window-incomplete',
      recommendation: null,
      baselineRateBasisPoints: null,
      observedRateBasisPoints: null,
      effectBasisPoints: null,
      durationIncreaseMs: null,
      evaluatedTaskIds: later.map((record) => record.taskId).toList(),
    );
  }
  final evaluated = later.take(hypothesis.evaluationWindow).toList();
  final baselineRate = _rate(
    baseline,
    (record) => record.repairOrEscalation != 'none',
  );
  final observedRate = _rate(
    evaluated,
    (record) => record.repairOrEscalation != 'none',
  );
  final effect = baselineRate - observedRate;
  final durationIncrease =
      _averageDuration(evaluated) - _averageDuration(baseline);
  final keep =
      effect >= hypothesis.minimumEffectBasisPoints &&
      durationIncrease <= hypothesis.maxDurationIncreaseMs;
  return ShadowResult(
    status: 'evaluated',
    reason: keep ? 'contract-met' : 'contract-not-met',
    recommendation: keep ? 'keep' : 'revert',
    baselineRateBasisPoints: baselineRate,
    observedRateBasisPoints: observedRate,
    effectBasisPoints: effect,
    durationIncreaseMs: durationIncrease,
    evaluatedTaskIds: evaluated.map((record) => record.taskId).toList(),
  );
}

ImprovementHypothesis _parseHypothesis(
  Directory root,
  Object? value,
  Map<String, OperatingEvidenceRecord> evidence,
) {
  final map = _object(value);
  _exactKeys(map, const {
    'id',
    'status',
    'patternBoundary',
    'baselineTaskIds',
    'targetComponent',
    'targetPaths',
    'metric',
    'minimumEffectBasisPoints',
    'maxDurationIncreaseMs',
    'evaluationWindow',
    'requiredRisk',
    'rollbackPaths',
    'invariants',
    'ownerId',
    'approverId',
    'approvedAt',
    'plan',
    'evaluation',
  });
  final id = _stable(map['id'], _id);
  final status = _category(map['status'], const {
    'proposed',
    'approved',
    'evaluating',
    'kept',
    'reverted',
  });
  final patternBoundary = _category(map['patternBoundary'], const {
    'preflight',
    'fast',
    'full',
    'runtime',
    'ci',
  });
  final baselineTaskIds = _stringList(map['baselineTaskIds'], _id);
  if (baselineTaskIds.length < 2 ||
      baselineTaskIds.any((id) => !evidence.containsKey(id))) {
    throw _invalid();
  }
  final baseline = baselineTaskIds.map((id) => evidence[id]!).toList();
  if (baseline.any(
    (record) =>
        record.failedBoundary != patternBoundary ||
        record.repairOrEscalation == 'none',
  )) {
    throw _invalid();
  }
  final targetComponent = _category(map['targetComponent'], const {
    'controller',
    'diagnostic',
    'documentation',
    'oracle',
    'sensor',
  });
  final targetPaths = _safePaths(map['targetPaths']);
  final metric = _category(map['metric'], const {'repair-or-escalation-rate'});
  final minimumEffectBasisPoints = _boundedInt(
    map['minimumEffectBasisPoints'],
    min: 1,
    max: 10000,
  );
  final maxDurationIncreaseMs = _boundedInt(
    map['maxDurationIncreaseMs'],
    max: 86400000,
  );
  final evaluationWindow = _boundedInt(
    map['evaluationWindow'],
    min: 2,
    max: 20,
  );
  final requiredRisk = _category(map['requiredRisk'], const {
    'low',
    'medium',
    'high',
  });
  if (baseline.any((record) => record.effectiveRisk != requiredRisk)) {
    throw _invalid();
  }
  final rollbackPaths = _safePaths(map['rollbackPaths']);
  final invariants = _stringList(map['invariants'], _invariant);
  if (!_same(invariants, _requiredInvariants)) throw _invalid();
  final ownerId = _stable(map['ownerId'], _humanId);
  final approverId = map['approverId'] == null
      ? null
      : _stable(map['approverId'], _humanId);
  final approvedAt = map['approvedAt'] == null
      ? null
      : _date(map['approvedAt']);
  final planPath = _stable(map['plan'], _planPath);
  final planFile = File(p.join(root.path, planPath));
  if (!planFile.existsSync()) throw _invalid();
  final plan = parseTaskPlan(planPath, planFile.readAsStringSync());
  final approved = status != 'proposed';
  if (approved != (approverId != null && approvedAt != null) ||
      (approverId != null && approverId == ownerId)) {
    throw _invalid();
  }
  if (approved) _validateImprovementPlan(plan, targetPaths, rollbackPaths);
  final evaluation = map['evaluation'] == null
      ? null
      : _parseEvaluation(map['evaluation']);
  if (const {'kept', 'reverted'}.contains(status) != (evaluation != null)) {
    throw _invalid();
  }
  if (const {'kept', 'reverted'}.contains(status) &&
      plan.status != TaskPlanStatus.completed) {
    throw _invalid();
  }
  return ImprovementHypothesis(
    id: id,
    status: status,
    patternBoundary: patternBoundary,
    baselineTaskIds: baselineTaskIds,
    targetComponent: targetComponent,
    targetPaths: targetPaths,
    metric: metric,
    minimumEffectBasisPoints: minimumEffectBasisPoints,
    maxDurationIncreaseMs: maxDurationIncreaseMs,
    evaluationWindow: evaluationWindow,
    requiredRisk: requiredRisk,
    rollbackPaths: rollbackPaths,
    invariants: invariants,
    ownerId: ownerId,
    approverId: approverId,
    approvedAt: approvedAt,
    plan: planPath,
    evaluation: evaluation,
  );
}

ImprovementEvaluation _parseEvaluation(Object? value) {
  final map = _object(value);
  _exactKeys(map, const {
    'recommendation',
    'baselineRateBasisPoints',
    'observedRateBasisPoints',
    'effectBasisPoints',
    'durationIncreaseMs',
    'evaluatedTaskIds',
    'humanDecision',
    'decidedBy',
  });
  return ImprovementEvaluation(
    recommendation: _category(map['recommendation'], const {'keep', 'revert'}),
    baselineRateBasisPoints: _boundedInt(
      map['baselineRateBasisPoints'],
      max: 10000,
    ),
    observedRateBasisPoints: _boundedInt(
      map['observedRateBasisPoints'],
      max: 10000,
    ),
    effectBasisPoints: _boundedInt(
      map['effectBasisPoints'],
      min: -10000,
      max: 10000,
    ),
    durationIncreaseMs: _boundedInt(
      map['durationIncreaseMs'],
      min: -86400000,
      max: 86400000,
    ),
    evaluatedTaskIds: _stringList(map['evaluatedTaskIds'], _id),
    humanDecision: _category(map['humanDecision'], const {'keep', 'revert'}),
    decidedBy: _stable(map['decidedBy'], _humanId),
  );
}

void _validateImprovementPlan(
  TaskPlan plan,
  List<String> targetPaths,
  List<String> rollbackPaths,
) {
  if (plan.risk != TaskRisk.high ||
      !plan.impacts.harness ||
      plan.impacts.auth ||
      plan.impacts.navigation ||
      plan.impacts.api ||
      plan.impacts.database ||
      plan.impacts.platform ||
      plan.impacts.ui ||
      plan.boundaries.allowedActions.length != 2 ||
      !plan.boundaries.allowedActions.contains(TaskAction.edit) ||
      !plan.boundaries.allowedActions.contains(TaskAction.verify)) {
    throw _invalid();
  }
  for (final path in {...targetPaths, ...rollbackPaths}) {
    if (findScopeViolations([path], plan.boundaries.allowedPaths).isNotEmpty) {
      throw _invalid();
    }
  }
}

int _rate(
  List<OperatingEvidenceRecord> records,
  bool Function(OperatingEvidenceRecord record) matches,
) {
  if (records.isEmpty) return 0;
  return (records.where(matches).length * 10000 / records.length).round();
}

int _averageDuration(List<OperatingEvidenceRecord> records) {
  if (records.isEmpty) return 0;
  final total = records.fold<int>(
    0,
    (sum, record) =>
        sum +
        record.lanes.fold<int>(0, (value, lane) => value + lane.durationMs),
  );
  return (total / records.length).round();
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

String _stable(Object? value, RegExp pattern) {
  if (value is! String || !pattern.hasMatch(value)) throw _invalid();
  return value;
}

String _category(Object? value, Set<String> values) {
  if (value is! String || !values.contains(value)) throw _invalid();
  return value;
}

List<String> _stringList(Object? value, RegExp pattern) {
  if (value is! List || value.isEmpty) throw _invalid();
  final result = value.whereType<String>().toList(growable: false);
  if (result.length != value.length ||
      result.any((item) => !pattern.hasMatch(item)) ||
      !_strictlySorted(result) ||
      result.toSet().length != result.length) {
    throw _invalid();
  }
  return result;
}

List<String> _safePaths(Object? value) {
  final paths = _stringList(value, _safePath);
  if (paths.any(
    (path) =>
        path.startsWith('/') ||
        path.split('/').contains('..') ||
        path == '.' ||
        path.startsWith('.git/'),
  )) {
    throw _invalid();
  }
  return paths;
}

int _boundedInt(Object? value, {int min = 0, required int max}) {
  if (value is! int || value < min || value > max) throw _invalid();
  return value;
}

DateTime _date(Object? value) {
  final text = _stable(value, _isoDate);
  final parsed = DateTime.tryParse(text);
  if (parsed == null || parsed.toIso8601String().substring(0, 10) != text) {
    throw _invalid();
  }
  return parsed;
}

bool _strictlySorted(List<String> values) {
  for (var index = 1; index < values.length; index++) {
    if (values[index - 1].compareTo(values[index]) >= 0) return false;
  }
  return true;
}

bool _same(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

int _entryOrder(MapEntry<String, int> left, MapEntry<String, int> right) =>
    left.key.compareTo(right.key);

HarnessImprovementError _invalid() => const HarnessImprovementError(
  'improvement.schema-invalid',
  'Harness improvement data does not match strict schema version 1.',
);

final _id = RegExp(r'^[a-z0-9][a-z0-9-]{2,79}$');
final _humanId = RegExp(r'^human:[a-z0-9][a-z0-9-]{1,63}$');
final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
final _safePath = RegExp(r'^[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*/?$');
final _planPath = RegExp(
  r'^docs/exec-plans/(?:active|completed)/[a-z0-9][a-z0-9_.-]{2,119}\.md$',
);
final _invariant = RegExp(r'^[a-z]+(?:[.-][a-z]+)+$');
const _requiredInvariants = [
  'authority.no-expansion',
  'evidence.no-sensitive-data',
  'publication.no-expansion',
  'risk.no-lowering',
  'verification.no-weakening',
];
