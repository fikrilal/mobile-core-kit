import 'dart:io';

import 'package:mobile_core_kit_cli/src/evidence/evidence_workflow.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
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
    final evidenceResult = await EvidenceWorkflow(
      context,
    ).run(const ['verify']);
    if (evidenceResult != 0) return evidenceResult;

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
    p.join(root.path, '.github', 'workflows', 'required.yml'),
  );
  if (!workflow.existsSync()) {
    return const ['.github/workflows/required.yml is missing.'];
  }

  final content = workflow.readAsStringSync();
  final errors = <String>[];
  if (!content.contains('mobilekit verify --profile ci')) {
    errors.add(
      '.github/workflows/required.yml does not delegate canonical verification '
      'to `mobilekit verify --profile ci`.',
    );
  }
  if (RegExp(
        r'^    name: CI Required$',
        multiLine: true,
      ).allMatches(content).length !=
      1) {
    errors.add(
      '.github/workflows/required.yml must expose exactly one `CI Required` job.',
    );
  }
  return errors;
}

List<String> _validatePlanLifecycle(Directory root) {
  final errors = <String>[];
  final taskIds = <String, String>{};
  var activeV2Count = 0;
  for (final lifecycle in const ['active', 'queued', 'completed']) {
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
      final isV2 = content.contains('**Plan version:**');
      if (!isV2) {
        if (lifecycle != 'completed' && !_isGrandfatheredLegacyPlan(content)) {
          errors.add('$relative must use execution-plan version 2.');
        } else if (lifecycle != 'completed') {
          errors.addAll(_validateLegacyPlan(relative, content, lifecycle));
        }
        continue;
      }

      try {
        final plan = parseTaskPlan(relative, content);
        if (plan.status.name != lifecycle) {
          errors.add(
            '$relative declares status `${plan.status.name}` but is stored '
            'under `$lifecycle/`.',
          );
        }
        final duplicate = taskIds[plan.taskId];
        if (duplicate != null) {
          errors.add(
            '$relative duplicates task ID `${plan.taskId}` from $duplicate.',
          );
        } else {
          taskIds[plan.taskId] = relative;
        }
        if (lifecycle == 'active') activeV2Count += 1;
        if (lifecycle == 'completed' &&
            RegExp(r'^- \[ \]', multiLine: true).hasMatch(content)) {
          errors.add(
            '$relative is completed but has unchecked checklist items.',
          );
        }
      } on TaskPlanError catch (error) {
        errors.add('$relative: ${error.code}: ${error.message}');
      }
    }
  }
  if (activeV2Count > 1) {
    errors.add(
      'Only one V2 execution plan may be active for the current agent.',
    );
  }
  return errors;
}

bool _isGrandfatheredLegacyPlan(String content) {
  final value = RegExp(
    r'^Date:\s*(\d{4}-\d{2}-\d{2})',
    multiLine: true,
  ).firstMatch(content)?.group(1);
  final date = value == null ? null : DateTime.tryParse(value);
  return date != null && date.isBefore(DateTime.utc(2026, 8, 11));
}

List<String> _validateLegacyPlan(
  String relative,
  String content,
  String lifecycle,
) {
  final errors = <String>[];
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
      errors.add('$relative is missing legacy field `$field`.');
    }
  }
  final status = RegExp(
    r'^Status:\s*(.+)$',
    multiLine: true,
  ).firstMatch(content)?.group(1)?.trim().toLowerCase();
  if (status != null && !status.startsWith(lifecycle)) {
    errors.add(
      '$relative declares status `$status` but is stored under `$lifecycle/`.',
    );
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
