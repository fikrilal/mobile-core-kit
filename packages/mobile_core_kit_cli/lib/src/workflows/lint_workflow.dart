import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class LintWorkflow {
  const LintWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    if (argv.isNotEmpty) {
      throw FormatException("Unexpected argument '${argv.first}'.");
    }

    var exitCode = await context.step('Flutter analyze', [
      'flutter',
      'analyze',
    ]);
    if (exitCode != 0) return exitCode;

    exitCode = await context.step('Custom lint', [
      'dart',
      'run',
      'custom_lint',
    ]);
    if (exitCode != 0) return exitCode;

    return 0;
  }
}
