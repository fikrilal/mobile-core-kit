import 'package:mobile_core_kit_cli/src/evidence/operating_evidence.dart';
import 'package:mobile_core_kit_cli/src/improvement/harness_improvement.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class ImprovementWorkflow {
  const ImprovementWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.length != 1 ||
        !const {'check', 'analyze', 'shadow'}.contains(arguments.single)) {
      throw const FormatException(
        'Expected `improve check`, `improve analyze`, or `improve shadow`.',
      );
    }
    try {
      final evidence = readOperatingEvidence(context.rootDirectory);
      final ledger = readHarnessImprovements(context.rootDirectory, evidence);
      final trend = aggregateHarnessTrend(evidence);
      switch (arguments.single) {
        case 'check':
          context.output.writeln(
            'Harness improvement ledger is valid: '
            '${ledger.hypotheses.length} hypothesis/hypotheses.',
          );
        case 'analyze':
          _writeTrend(trend, ledger);
        case 'shadow':
          _writeShadow(evaluateShadow(evidence, ledger));
      }
      return 0;
    } on OperatingEvidenceError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    } on HarnessImprovementError catch (error) {
      context.errorOutput.writeln('FAIL [${error.code}] ${error.message}');
      return 1;
    }
  }

  void _writeTrend(HarnessTrend trend, HarnessImprovementLedger ledger) {
    context.output.writeln('Harness improvement analysis');
    context.output.writeln(
      'status: ${trend.evidence.eligible ? 'eligible-for-human-hypothesis' : 'disabled'}',
    );
    context.output.writeln('evidenceRecords: ${trend.evidence.recordCount}');
    context.output.writeln('riskClasses: ${trend.evidence.riskClasses}');
    context.output.writeln(
      'repairRateBasisPoints: ${trend.repairRateBasisPoints}',
    );
    context.output.writeln(
      'blockedRateBasisPoints: ${trend.blockedRateBasisPoints}',
    );
    context.output.writeln(
      'recurringBoundaries: ${trend.recurringBoundaries.isEmpty ? 'none' : trend.recurringBoundaries.entries.map((entry) => '${entry.key}=${entry.value}').join(',')}',
    );
    context.output.writeln('hypotheses: ${ledger.hypotheses.length}');
    context.output.writeln(
      'authority: ${trend.evidence.eligible ? 'human may propose a separate high-risk plan' : 'none; collect qualifying evidence'}',
    );
  }

  void _writeShadow(ShadowResult result) {
    context.output.writeln('Harness shadow evaluation');
    context.output.writeln('status: ${result.status}');
    context.output.writeln('reason: ${result.reason}');
    context.output.writeln(
      'recommendation: ${result.recommendation ?? 'none'}',
    );
    context.output.writeln(
      'evaluatedTaskIds: ${result.evaluatedTaskIds.isEmpty ? 'none' : result.evaluatedTaskIds.join(',')}',
    );
    if (result.status == 'evaluated') {
      context.output.writeln(
        'baselineRateBasisPoints: ${result.baselineRateBasisPoints}',
      );
      context.output.writeln(
        'observedRateBasisPoints: ${result.observedRateBasisPoints}',
      );
      context.output.writeln('effectBasisPoints: ${result.effectBasisPoints}');
      context.output.writeln(
        'durationIncreaseMs: ${result.durationIncreaseMs}',
      );
    }
    context.output.writeln('mutation: none');
  }
}
