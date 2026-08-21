import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/evidence/evidence_mutation_pilot.dart';
import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  late Directory root;
  late Map<String, Object?> record;

  setUp(() {
    root = Directory.systemTemp.createTempSync('operating-evidence-test-');
    final relativePlan =
        'docs/exec-plans/completed/2026-08-12_test-task-authority.md';
    final plan = File(p.join(root.path, relativePlan))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(taskPlanFixture(status: 'completed'));
    final planHash = sha256.convert(plan.readAsBytesSync()).toString();
    record = <String, Object?>{
      'taskId': 'test-task-authority',
      'completedPlan': relativePlan,
      'completedPlanSha256': planHash,
      'effectiveRisk': 'medium',
      'impactCategories': ['ui'],
      'firstPass': false,
      'eventualOutcome': 'completed',
      'lanes': [
        {'id': 'full', 'status': 'passed', 'durationMs': 125000},
      ],
      'failedBoundary': 'full',
      'repairOrEscalation': 'repair',
      'review': {
        'independent': true,
        'decision': 'accepted',
        'reviewedAt': '2026-08-12',
      },
      'ci': {'reproduced': true, 'revision': 'a' * 40, 'runId': 123456},
      'harnessRevision': 'a' * 40,
    };
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('accepts a strict independently reviewed hosted-CI record', () {
    final ledger = parseOperatingEvidence(root, {
      'schemaVersion': 1,
      'records': [record],
    });

    expect(ledger.records, hasLength(1));
    expect(ledger.records.single.taskId, 'test-task-authority');
    expect(ledger.records.single.lanes.single.durationMs, 125000);
  });

  test('empty ledger is valid but ineligible', () {
    final assessment = assessOperatingEvidence(
      parseOperatingEvidence(root, {'schemaVersion': 1, 'records': []}),
    );

    expect(assessment.eligible, isFalse);
    expect(assessment.missing, [
      'five-reviewed-tasks',
      'two-risk-classes',
      'repair-or-escalation',
    ]);
  });

  for (final mutation in <String, void Function(Map<String, Object?>)>{
    'free-form field': (record) => record['notes'] = 'agent reasoning',
    'unreviewed record': (record) => record['review'] = {
      'independent': false,
      'decision': 'accepted',
      'reviewedAt': '2026-08-12',
    },
    'unreproduced CI': (record) => record['ci'] = {
      'reproduced': false,
      'revision': 'a' * 40,
      'runId': 123456,
    },
    'mismatched harness revision': (record) =>
        record['harnessRevision'] = 'b' * 40,
    'mismatched plan hash': (record) =>
        record['completedPlanSha256'] = 'b' * 64,
    'unbounded duration': (record) => record['lanes'] = [
      {'id': 'full', 'status': 'passed', 'durationMs': 86400001},
    ],
    'risk below declared risk': (record) => record['effectiveRisk'] = 'low',
  }.entries) {
    test('fails closed for ${mutation.key}', () {
      mutation.value(record);

      expect(
        () => parseOperatingEvidence(root, {
          'schemaVersion': 1,
          'records': [record],
        }),
        throwsA(isA<OperatingEvidenceError>()),
      );
    });
  }

  test('rejects duplicate and unsorted task records', () {
    expect(
      () => parseOperatingEvidence(root, {
        'schemaVersion': 1,
        'records': [record, Map<String, Object?>.from(record)],
      }),
      throwsA(isA<OperatingEvidenceError>()),
    );
  });

  test('checked-in calibration remains internally consistent', () {
    final calibration = readEvidenceCalibration(Directory.current);

    expect(calibration.observedBasisPoints, 6278);
    expect(calibration.enforcedFloorBasisPoints, 5500);
    expect(calibration.profileBudgetsMs.keys, ['fast', 'full']);
  });

  test('checked-in ledger remains empty until evidence is promoted', () {
    final ledger = readOperatingEvidence(Directory.current);

    expect(ledger.records, isEmpty);
  });

  test('narrow mutation pilot kills every representative policy mutant', () {
    final result = runEvidenceMutationPilot();

    expect(result.passed, isTrue);
    expect(result.killed, result.total);
    expect(result.total, 3);
  });

  test('reader rejects an oversized ledger before parsing', () {
    File(p.join(root.path, operatingEvidencePath))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(jsonEncode({'padding': 'x' * (257 * 1024)}));

    expect(
      () => readOperatingEvidence(root),
      throwsA(
        isA<OperatingEvidenceError>().having(
          (error) => error.code,
          'code',
          'evidence.oversized',
        ),
      ),
    );
  });
}
