import 'dart:io';

import 'package:mobile_core_kit_cli/src/workflows/workflow_context.dart';

class ProjectMapWorkflow {
  const ProjectMapWorkflow(this.context);

  final WorkflowContext context;

  Future<int> run(List<String> _) async {
    final agentsFile = context.file('AGENTS.md');
    if (!agentsFile.existsSync()) {
      context.errorOutput.writeln('AGENTS.md not found at repository root.');
      return 1;
    }

    final coreDir = context.directory('lib/core');
    if (!coreDir.existsSync()) {
      context.errorOutput.writeln('lib/core directory not found.');
      return 1;
    }

    final documentedCoreDirs = _parseDocumentedCoreDirs(
      agentsFile.readAsStringSync(),
    );
    if (documentedCoreDirs.isEmpty) {
      context.errorOutput.writeln(
        'AGENTS.md does not define the required `lib/core` project map.',
      );
      return 1;
    }

    final actualCoreDirs = coreDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => _basename(dir.path))
        .where((name) => !name.startsWith('.'))
        .toSet();

    final missingInDocs = actualCoreDirs.difference(documentedCoreDirs).toList()
      ..sort();
    final staleInDocs = documentedCoreDirs.difference(actualCoreDirs).toList()
      ..sort();

    if (missingInDocs.isEmpty && staleInDocs.isEmpty) {
      context.output.writeln('AGENTS project map is aligned with lib/core.');
      return 0;
    }

    context.errorOutput.writeln('AGENTS project map drift detected.');
    if (missingInDocs.isNotEmpty) {
      context.errorOutput.writeln(
        'Missing in AGENTS.md core map: ${missingInDocs.join(', ')}',
      );
    }
    if (staleInDocs.isNotEmpty) {
      context.errorOutput.writeln(
        'Stale in AGENTS.md core map (not in lib/core): ${staleInDocs.join(', ')}',
      );
    }
    return 1;
  }
}

Set<String> _parseDocumentedCoreDirs(String content) {
  final lines = content.split('\n');
  final coreStart = lines.indexWhere(
    (line) => line.contains('├─ core/') || line.contains('└─ core/'),
  );
  if (coreStart == -1) return <String>{};

  final dirs = <String>{};
  final coreLinePattern = RegExp(r'^\s*│\s*[├└]─\s*([a-z_]+)/');

  for (var i = coreStart + 1; i < lines.length; i += 1) {
    final line = lines[i];
    if (line.startsWith('├─ features/')) break;
    if (line.startsWith('└─ navigation/')) break;

    final match = coreLinePattern.firstMatch(line);
    if (match == null) continue;
    dirs.add(match.group(1)!);
  }

  return dirs;
}

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.substring(normalized.lastIndexOf('/') + 1);
}
