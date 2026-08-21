import 'package:mobile_core_kit_cli/src/evidence/evidence_mutation_pilot.dart';
import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class EvidenceWorkflow {
  const EvidenceWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.length != 1 ||
        !const {
          'verify',
          'report',
          'mutation-pilot',
        }.contains(arguments.single)) {
      throw const FormatException(
        'Expected `evidence verify`, `evidence report`, or '
        '`evidence mutation-pilot`.',
      );
    }
    if (arguments.single == 'mutation-pilot') return _runMutationPilot();
    try {
      final ledger = readOperatingEvidence(context.rootDirectory);
      final calibration = readEvidenceCalibration(context.rootDirectory);
      final assessment = assessOperatingEvidence(ledger);
      if (arguments.single == 'report') {
        _writeReport(assessment, calibration);
      } else {
        context.output.writeln(
          'Operating evidence is valid: ${assessment.recordCount} reviewed '
          'record(s); improvement eligibility: '
          '${assessment.eligible ? 'eligible-for-human-review' : 'insufficient'}.',
        );
      }
      return 0;
    } on OperatingEvidenceError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    }
  }

  int _runMutationPilot() {
    final result = runEvidenceMutationPilot();
    if (!result.passed) {
      context.errorOutput.writeln(
        'FAIL [evidence.mutation-survived] Policy mutants survived: '
        '${result.survivors.join(', ')}.',
      );
      return 1;
    }
    context.output.writeln(
      'Evidence mutation pilot passed: ${result.killed}/${result.total} '
      'representative policy mutants killed.',
    );
    return 0;
  }

  void _writeReport(
    EvidenceAssessment assessment,
    EvidenceCalibration calibration,
  ) {
    context.output.writeln('Harness operating evidence');
    context.output.writeln(
      'status: ${assessment.eligible ? 'eligible-for-human-review' : 'insufficient'}',
    );
    context.output.writeln('reviewedTasks: ${assessment.recordCount}');
    context.output.writeln('riskClasses: ${assessment.riskClasses}');
    context.output.writeln(
      'repairsOrEscalations: ${assessment.repairOrEscalationCount}',
    );
    context.output.writeln(
      'missing: ${assessment.missing.isEmpty ? 'none' : assessment.missing.join(',')}',
    );
    context.output.writeln(
      'coverageObservation: ${calibration.coveredLines}/'
      '${calibration.executableLines} '
      '(${(calibration.observedBasisPoints / 100).toStringAsFixed(2)}%)',
    );
    context.output.writeln(
      'coverageFloor: '
      '${(calibration.enforcedFloorBasisPoints / 100).toStringAsFixed(2)}%',
    );
    for (final entry in calibration.profileBudgetsMs.entries) {
      context.output.writeln(
        '${entry.key}CalibrationMs: ${entry.value.observedMs}; '
        'advisoryBudgetMs: ${entry.value.advisoryBudgetMs}',
      );
    }
    for (final profile in assessment.profileCounts.keys.toList()..sort()) {
      context.output.writeln(
        '$profile: ${assessment.profileCounts[profile]} observation(s), '
        '${assessment.profileDurationMs[profile]}ms total',
      );
    }
    context.output.writeln(
      'recommendation: ${assessment.eligible ? 'human review may consider a narrow proposal; no policy changes are automatic' : 'collect missing independently reviewed hosted-CI evidence; do not change policy'}',
    );
  }
}
