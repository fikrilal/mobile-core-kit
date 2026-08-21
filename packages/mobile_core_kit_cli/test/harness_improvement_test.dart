import 'dart:io';

import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';
import 'package:mobile_core_kit_cli/src/improvement/harness_improvement.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  late Directory root;
  late OperatingEvidenceLedger evidence;
  late Map<String, Object?> hypothesis;

  setUp(() {
    root = Directory.systemTemp.createTempSync('improvement-test-');
    const planPath = 'docs/exec-plans/active/improvement.md';
    File(p.join(root.path, planPath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        taskPlanFixture(
          taskId: 'improvement-plan',
          risk: 'high',
          allowedPaths:
              '$planPath, packages/mobile_core_kit_cli/lib/src/improvement/',
          oracleIds: 'harness.full',
          impacts: _harnessImpacts,
        ),
      );
    evidence = OperatingEvidenceLedger([
      _record(
        id: 'baseline-one',
        risk: 'medium',
        repaired: true,
        reviewedAt: DateTime.utc(2026, 8, 1),
      ),
      _record(
        id: 'baseline-two',
        risk: 'medium',
        repaired: true,
        reviewedAt: DateTime.utc(2026, 8, 2),
      ),
      _record(
        id: 'diverse-low',
        risk: 'low',
        reviewedAt: DateTime.utc(2026, 8, 3),
      ),
      _record(
        id: 'control-high',
        risk: 'high',
        reviewedAt: DateTime.utc(2026, 8, 4),
      ),
      _record(
        id: 'shadow-one',
        risk: 'medium',
        reviewedAt: DateTime.utc(2026, 8, 6),
      ),
      _record(
        id: 'shadow-two',
        risk: 'medium',
        reviewedAt: DateTime.utc(2026, 8, 7),
      ),
    ]);
    hypothesis = <String, Object?>{
      'id': 'improve-diagnostics',
      'status': 'evaluating',
      'patternBoundary': 'full',
      'baselineTaskIds': ['baseline-one', 'baseline-two'],
      'targetComponent': 'diagnostic',
      'targetPaths': ['packages/mobile_core_kit_cli/lib/src/improvement/'],
      'metric': 'repair-or-escalation-rate',
      'minimumEffectBasisPoints': 5000,
      'maxDurationIncreaseMs': 10000,
      'evaluationWindow': 2,
      'requiredRisk': 'medium',
      'rollbackPaths': ['packages/mobile_core_kit_cli/lib/src/improvement/'],
      'invariants': [
        'authority.no-expansion',
        'evidence.no-sensitive-data',
        'publication.no-expansion',
        'risk.no-lowering',
        'verification.no-weakening',
      ],
      'ownerId': 'human:owner',
      'approverId': 'human:reviewer',
      'approvedAt': '2026-08-05',
      'plan': planPath,
      'evaluation': null,
    };
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('empty evidence keeps improvement analysis disabled', () {
    final result = evaluateShadow(
      const OperatingEvidenceLedger([]),
      const HarnessImprovementLedger([]),
    );

    expect(result.status, 'disabled');
    expect(result.recommendation, isNull);
  });

  test('ineligible evidence requires an empty hypothesis ledger', () {
    expect(
      () => parseHarnessImprovements(root, {
        'schemaVersion': 1,
        'hypotheses': [hypothesis],
      }, const OperatingEvidenceLedger([])),
      throwsA(
        isA<HarnessImprovementError>().having(
          (error) => error.code,
          'code',
          'improvement.ineligible',
        ),
      ),
    );
  });

  test('aggregates only recurring stable categorical boundaries', () {
    final trend = aggregateHarnessTrend(evidence);

    expect(trend.evidence.eligible, isTrue);
    expect(trend.repairRateBasisPoints, 3333);
    expect(trend.blockedRateBasisPoints, 0);
    expect(trend.recurringBoundaries, {'full': 2});
  });

  test('shadow evaluation recommends keep from disjoint later evidence', () {
    final ledger = parseHarnessImprovements(root, {
      'schemaVersion': 1,
      'hypotheses': [hypothesis],
    }, evidence);

    final result = evaluateShadow(evidence, ledger);

    expect(result.status, 'evaluated');
    expect(result.recommendation, 'keep');
    expect(result.effectBasisPoints, 10000);
    expect(result.evaluatedTaskIds, ['shadow-one', 'shadow-two']);
  });

  test('terminal human decision must match deterministic evaluation', () {
    final plan = File(p.join(root.path, hypothesis['plan']! as String));
    plan.writeAsStringSync(
      plan.readAsStringSync().replaceFirst(
        '**Status:** active',
        '**Status:** completed',
      ),
    );
    hypothesis['status'] = 'kept';
    hypothesis['evaluation'] = {
      'recommendation': 'keep',
      'baselineRateBasisPoints': 10000,
      'observedRateBasisPoints': 0,
      'effectBasisPoints': 10000,
      'durationIncreaseMs': 0,
      'evaluatedTaskIds': ['shadow-one', 'shadow-two'],
      'humanDecision': 'keep',
      'decidedBy': 'human:decider',
    };

    expect(
      parseHarnessImprovements(root, {
        'schemaVersion': 1,
        'hypotheses': [hypothesis],
      }, evidence).hypotheses.single.status,
      'kept',
    );

    (hypothesis['evaluation']! as Map<String, Object?>)['humanDecision'] =
        'revert';
    expect(
      () => parseHarnessImprovements(root, {
        'schemaVersion': 1,
        'hypotheses': [hypothesis],
      }, evidence),
      throwsA(isA<HarnessImprovementError>()),
    );
  });

  test('shadow evaluation is inconclusive before its declared window', () {
    final shortEvidence = OperatingEvidenceLedger(
      evidence.records
          .where((record) => record.taskId != 'shadow-two')
          .toList(),
    );
    final ledger = parseHarnessImprovements(root, {
      'schemaVersion': 1,
      'hypotheses': [hypothesis],
    }, shortEvidence);

    final result = evaluateShadow(shortEvidence, ledger);

    expect(result.status, 'inconclusive');
    expect(result.recommendation, isNull);
  });

  test('shadow evaluation recommends revert when effect contract fails', () {
    hypothesis['minimumEffectBasisPoints'] = 6000;
    final repairedEvidence = OperatingEvidenceLedger(
      [
        ...evidence.records.where((record) => record.taskId != 'shadow-one'),
        _record(
          id: 'shadow-one',
          risk: 'medium',
          repaired: true,
          reviewedAt: DateTime.utc(2026, 8, 6),
        ),
      ]..sort((left, right) => left.taskId.compareTo(right.taskId)),
    );
    final ledger = parseHarnessImprovements(root, {
      'schemaVersion': 1,
      'hypotheses': [hypothesis],
    }, repairedEvidence);

    expect(evaluateShadow(repairedEvidence, ledger).recommendation, 'revert');
  });

  for (final mutation in <String, void Function(Map<String, Object?>)>{
    'privacy field': (value) => value['notes'] = 'agent reasoning',
    'missing invariant': (value) => (value['invariants']! as List).removeLast(),
    'same owner and approver': (value) => value['approverId'] = 'human:owner',
    'publication action in plan': (value) {
      File(p.join(root.path, value['plan']! as String)).writeAsStringSync(
        taskPlanFixture(
          taskId: 'improvement-plan',
          risk: 'high',
          allowedPaths:
              '${value['plan']}, packages/mobile_core_kit_cli/lib/src/improvement/',
          allowedActions: 'edit, verify, push',
          oracleIds: 'harness.full',
          impacts: _harnessImpacts,
        ),
      );
    },
    'escaping path': (value) => value['targetPaths'] = ['../outside'],
    'risk mismatch': (value) => value['requiredRisk'] = 'low',
  }.entries) {
    test('fails closed for ${mutation.key}', () {
      mutation.value(hypothesis);

      expect(
        () => parseHarnessImprovements(root, {
          'schemaVersion': 1,
          'hypotheses': [hypothesis],
        }, evidence),
        throwsA(isA<HarnessImprovementError>()),
      );
    });
  }

  test('rejects multiple evaluating hypotheses', () {
    final second = Map<String, Object?>.from(hypothesis)
      ..['id'] = 'second-hypothesis';

    expect(
      () => parseHarnessImprovements(root, {
        'schemaVersion': 1,
        'hypotheses': [hypothesis, second],
      }, evidence),
      throwsA(
        isA<HarnessImprovementError>().having(
          (error) => error.code,
          'code',
          'improvement.concurrent',
        ),
      ),
    );
  });
}

OperatingEvidenceRecord _record({
  required String id,
  required String risk,
  required DateTime reviewedAt,
  bool repaired = false,
}) {
  final lane = risk == 'low' ? 'fast' : 'full';
  return OperatingEvidenceRecord(
    taskId: id,
    completedPlan: 'docs/exec-plans/completed/$id.md',
    completedPlanSha256: 'a' * 64,
    effectiveRisk: risk,
    impactCategories: const ['harness'],
    firstPass: !repaired,
    eventualOutcome: 'completed',
    lanes: [EvidenceLane(id: lane, durationMs: 100000)],
    failedBoundary: repaired ? 'full' : 'none',
    repairOrEscalation: repaired ? 'repair' : 'none',
    reviewedAt: reviewedAt,
    ciRevision: 'b' * 40,
    ciRunId: 123,
    harnessRevision: 'b' * 40,
  );
}

const _harnessImpacts = '''
- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no
''';
