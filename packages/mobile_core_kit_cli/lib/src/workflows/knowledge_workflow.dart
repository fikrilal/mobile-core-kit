import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/project_map_workflow.dart';
import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';
import 'package:path/path.dart' as p;

class KnowledgeWorkflow {
  const KnowledgeWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> arguments) async {
    if (arguments.isNotEmpty) {
      throw FormatException("Unexpected argument '${arguments.first}'.");
    }

    final projectMapResult = await ProjectMapWorkflow(context).run(const []);
    if (projectMapResult != 0) return projectMapResult;

    final errors = <String>[
      ..._validatePlanLifecycle(context.rootDirectory),
      ..._validateLocalMarkdownLinks(context.rootDirectory),
      ..._validateCiProfileOwnership(context.rootDirectory),
    ];
    if (errors.isNotEmpty) {
      context.errorOutput.writeln('Repository knowledge validation failed:');
      for (final error in errors) {
        context.errorOutput.writeln('- $error');
      }
      return 1;
    }

    context.output.writeln('Repository knowledge is internally consistent.');
    return 0;
  }
}

List<String> _validateCiProfileOwnership(Directory root) {
  final workflow = File(
    p.join(root.path, '.github', 'workflows', 'android.yml'),
  );
  if (!workflow.existsSync()) {
    return const ['.github/workflows/android.yml is missing.'];
  }

  final content = workflow.readAsStringSync();
  if (!content.contains('mobilekit verify --profile ci')) {
    return const [
      '.github/workflows/android.yml does not delegate canonical verification '
          'to `mobilekit verify --profile ci`.',
    ];
  }
  return const [];
}

List<String> _validatePlanLifecycle(Directory root) {
  final errors = <String>[];
  for (final lifecycle in const ['active', 'queued']) {
    final directory = Directory(
      p.join(root.path, 'docs', 'exec-plans', lifecycle),
    );
    if (!directory.existsSync()) continue;

    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final relative = _relative(root, file.path);
      final content = file.readAsStringSync();
      for (final field in const [
        'Date',
        'Owner',
        'Status',
        'Risk class',
        'Related issue/PR',
      ]) {
        if (!RegExp(
          '^${RegExp.escape(field)}:\\s*\\S+',
          multiLine: true,
        ).hasMatch(content)) {
          errors.add('$relative is missing required field `$field`.');
        }
      }

      final status = RegExp(
        r'^Status:\s*(.+)$',
        multiLine: true,
      ).firstMatch(content)?.group(1)?.trim().toLowerCase();
      if (status != null && !status.startsWith(lifecycle)) {
        errors.add(
          '$relative declares status `$status` but is stored under '
          '`$lifecycle/`.',
        );
      }

      final risk = RegExp(
        r'^Risk class:\s*(\S+)',
        multiLine: true,
      ).firstMatch(content)?.group(1)?.toLowerCase();
      if (risk != null && !const {'low', 'medium', 'high'}.contains(risk)) {
        errors.add('$relative declares unsupported risk class `$risk`.');
      }
    }
  }
  return errors;
}

List<String> _validateLocalMarkdownLinks(Directory root) {
  final files = <File>[];
  for (final path in const ['AGENTS.md', 'README.md']) {
    final file = File(p.join(root.path, path));
    if (file.existsSync()) files.add(file);
  }
  for (final directoryPath in const ['ADR', 'docs']) {
    final directory = Directory(p.join(root.path, directoryPath));
    if (!directory.existsSync()) continue;
    files.addAll(
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .where((file) => !p.split(file.path).contains('_WIP')),
    );
  }
  files.sort((a, b) => a.path.compareTo(b.path));

  final errors = <String>[];
  final linkPattern = RegExp(r'!?\[[^\]]*\]\(([^)]+)\)');
  for (final file in files) {
    final content = file.readAsStringSync();
    for (final match in linkPattern.allMatches(content)) {
      var target = match.group(1)!.trim();
      if (target.startsWith('<') && target.endsWith('>')) {
        target = target.substring(1, target.length - 1);
      }
      if (target.isEmpty ||
          target.startsWith('#') ||
          target.startsWith('mailto:') ||
          target.contains('://')) {
        continue;
      }
      target = target.split('#').first.split('?').first;
      if (target.isEmpty) continue;
      try {
        target = Uri.decodeComponent(target);
      } on FormatException {
        errors.add('${_relative(root, file.path)} has invalid link `$target`.');
        continue;
      }
      final resolved = p.normalize(p.join(file.parent.path, target));
      if (!File(resolved).existsSync() && !Directory(resolved).existsSync()) {
        errors.add(
          '${_relative(root, file.path)} links to missing path `$target`.',
        );
      }
    }
  }
  return errors;
}

String _relative(Directory root, String path) =>
    p.relative(path, from: root.path).replaceAll('\\', '/');
