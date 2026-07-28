import 'package:args/args.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

/// Auto-fix workflow for common, safe style issues in this repo.
///
/// This tool is intentionally conservative:
/// - It only applies `dart fix` for `directives_ordering`
/// - It runs `dart format`
///
/// Why:
/// - `directives_ordering` is enforced by `flutter analyze` and causes noisy diffs.
/// - `dart format` keeps formatting consistent across teams using this template.
class FixWorkflow {
  const FixWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> argv) async {
    final parser = ArgParser()
      ..addFlag('apply', defaultsTo: false, help: 'Apply fixes (writes files).')
      ..addFlag(
        'dry-run',
        defaultsTo: false,
        help: 'Preview actions; does not write files (format uses check mode).',
      );

    final args = parser.parse(argv);
    final apply = args.flag('apply');
    final dryRun = args.flag('dry-run');

    if (apply && dryRun) {
      context.errorOutput.writeln('Use only one of: --apply or --dry-run');
      return 2;
    }

    final mode = apply ? _FixMode.apply : _FixMode.dryRun;

    var exitCode = 0;

    if (mode == _FixMode.apply) {
      exitCode = await context.step('Dart fix (apply: directives_ordering)', [
        'dart',
        'fix',
        '--apply',
        '--code',
        'directives_ordering',
      ]);
      if (exitCode != 0) return exitCode;

      exitCode = await context.step('Dart format (apply)', [
        'dart',
        'format',
        '.',
      ]);
      if (exitCode != 0) return exitCode;
    } else {
      // Note: `dart fix --dry-run` does not fail when changes are suggested.
      // This step is informational; `flutter analyze` in `mobilekit verify` is the
      // gate that enforces directives ordering.
      exitCode = await context.step('Dart fix (dry-run: directives_ordering)', [
        'dart',
        'fix',
        '--dry-run',
        '--code',
        'directives_ordering',
      ]);
      if (exitCode != 0) return exitCode;

      exitCode = await context.step('Dart format (check)', [
        'dart',
        'format',
        '--output',
        'none',
        '--set-exit-if-changed',
        '.',
      ]);
      if (exitCode != 0) return exitCode;
    }

    context.output.writeln('\nOK');
    return 0;
  }
}

enum _FixMode { dryRun, apply }
