import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

/// Codegen freshness gate.
///
/// This workflow ensures `build_runner` outputs are checked in and up-to-date.
///
/// In CI, this prevents PRs from forgetting to run codegen after changing:
/// - Freezed models (`*.freezed.dart`)
/// - JsonSerializable models (`*.g.dart`)
///
/// Local usage:
/// - Run this after `flutter pub get`.
/// - If it fails, run the suggested `build_runner` command and commit the
///   generated outputs.
class CodegenWorkflow {
  const CodegenWorkflow(this.context);

  final WorkflowContext context;

  Future<int> generate() {
    return context.step('Dart build_runner', [
      'dart',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
  }

  Future<int> run(List<String> _) async {
    var exitCode = await generate();
    if (exitCode != 0) return exitCode;

    final diffExitCode = await _verifyGeneratedFilesClean(
      context.rootDirectory,
      context.errorOutput,
    );
    if (diffExitCode != 0) return diffExitCode;

    context.output.writeln('\nOK');
    return 0;
  }
}

Future<int> _verifyGeneratedFilesClean(
  Directory rootDirectory,
  StringSink errorOutput,
) async {
  final changedFiles = await _gitDiffNameOnly(rootDirectory);
  if (changedFiles == null) {
    errorOutput.writeln(
      'Unable to run `git diff`. Is git installed and on PATH?',
    );
    return 2;
  }

  final generatedChanges =
      changedFiles
          .where(
            (path) =>
                path.endsWith('.g.dart') ||
                path.endsWith('.freezed.dart') ||
                path.endsWith('.gr.dart'),
          )
          .toList()
        ..sort();

  if (generatedChanges.isEmpty) return 0;

  errorOutput.writeln(
    'Codegen outputs are out-of-date (build_runner produced changes).',
  );
  errorOutput.writeln('');
  errorOutput.writeln('Changed generated files:');
  for (final path in generatedChanges) {
    errorOutput.writeln('- $path');
  }
  errorOutput.writeln('');
  errorOutput.writeln('Fix:');
  errorOutput.writeln(
    '  dart run build_runner build --delete-conflicting-outputs',
  );
  return 1;
}

Future<List<String>?> _gitDiffNameOnly(Directory rootDirectory) async {
  try {
    final result = await Process.run(
      'git',
      const ['diff', '--name-only'],
      workingDirectory: rootDirectory.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      return null;
    }
    final out = (result.stdout as String).trim();
    if (out.isEmpty) return const [];
    return out
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } on ProcessException {
    return null;
  }
}
