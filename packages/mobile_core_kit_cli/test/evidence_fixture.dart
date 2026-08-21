import 'dart:io';

import 'package:path/path.dart' as p;

void writeEvidenceFixture(Directory root) {
  const sourcePlan = 'docs/exec-plans/completed/baseline.md';
  File(p.join(root.path, sourcePlan))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('Baseline.\n');
  File(p.join(root.path, 'docs/engineering/harness_operating_evidence.json'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('{"schemaVersion":1,"records":[]}\n');
  File(p.join(root.path, 'docs/engineering/harness_improvements.json'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('{"schemaVersion":1,"hypotheses":[]}\n');
  File(p.join(root.path, 'harness/evidence_calibration.json'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('''
{"schemaVersion":1,"coverage":{"observedAt":"2026-08-10","sourcePlan":"$sourcePlan","coveredLines":1,"executableLines":1,"observedBasisPoints":10000,"enforcedFloorBasisPoints":10000},"profiles":[{"id":"fast","observedDurationMs":1,"advisoryBudgetMs":1,"sourcePlan":"$sourcePlan"},{"id":"full","observedDurationMs":1,"advisoryBudgetMs":1,"sourcePlan":"$sourcePlan"}]}
''');
  File(p.join(root.path, '.github/workflows/governance.yml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('env:\n  COVERAGE_MIN: "100.0"\n');
}
