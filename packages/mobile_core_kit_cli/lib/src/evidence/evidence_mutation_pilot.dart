import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';

typedef EligibilityPolicy = bool Function(EvidenceAssessment assessment);

class EvidenceMutationPilotResult {
  const EvidenceMutationPilotResult({
    required this.total,
    required this.killed,
    required this.survivors,
  });

  final int total;
  final int killed;
  final List<String> survivors;

  bool get passed => survivors.isEmpty;
}

EvidenceMutationPilotResult runEvidenceMutationPilot() {
  final fixtures = [
    _assessment(records: 4, risks: 2, repairs: 1),
    _assessment(records: 5, risks: 1, repairs: 1),
    _assessment(records: 5, risks: 2, repairs: 0),
    _assessment(records: 5, risks: 2, repairs: 1),
  ];
  final canonical = fixtures.map((value) => value.eligible).toList();
  final mutants = <String, EligibilityPolicy>{
    'lower-task-floor': (value) =>
        value.recordCount >= 4 &&
        value.riskClasses >= 2 &&
        value.repairOrEscalationCount >= 1,
    'ignore-risk-diversity': (value) =>
        value.recordCount >= 5 && value.repairOrEscalationCount >= 1,
    'ignore-repair-evidence': (value) =>
        value.recordCount >= 5 && value.riskClasses >= 2,
  };
  final survivors = <String>[];
  for (final mutant in mutants.entries) {
    final result = fixtures.map(mutant.value).toList();
    if (_same(result, canonical)) survivors.add(mutant.key);
  }
  return EvidenceMutationPilotResult(
    total: mutants.length,
    killed: mutants.length - survivors.length,
    survivors: List.unmodifiable(survivors),
  );
}

EvidenceAssessment _assessment({
  required int records,
  required int risks,
  required int repairs,
}) {
  final missing = <String>[
    if (records < 5) 'five-reviewed-tasks',
    if (risks < 2) 'two-risk-classes',
    if (repairs < 1) 'repair-or-escalation',
  ];
  return EvidenceAssessment(
    recordCount: records,
    riskClasses: risks,
    repairOrEscalationCount: repairs,
    profileCounts: const {},
    profileDurationMs: const {},
    missing: missing,
  );
}

bool _same(List<bool> left, List<bool> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
