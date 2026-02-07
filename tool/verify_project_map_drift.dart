import 'dart:io';

void main() {
  final agentsFile = File('AGENTS.md');
  if (!agentsFile.existsSync()) {
    stderr.writeln('AGENTS.md not found at repository root.');
    exitCode = 1;
    return;
  }

  final coreDir = Directory('lib/core');
  if (!coreDir.existsSync()) {
    stderr.writeln('lib/core directory not found.');
    exitCode = 1;
    return;
  }

  final documentedCoreDirs = _parseDocumentedCoreDirs(
    agentsFile.readAsStringSync(),
  );
  if (documentedCoreDirs.isEmpty) {
    stderr.writeln(
      'Could not parse core project map directories from AGENTS.md.\n'
      'Expected tree entries like: "│  │  ├─ <dir>/".',
    );
    exitCode = 1;
    return;
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
    stdout.writeln('AGENTS project map is aligned with lib/core.');
    return;
  }

  stderr.writeln('AGENTS project map drift detected.');
  if (missingInDocs.isNotEmpty) {
    stderr.writeln(
      'Missing in AGENTS.md core map: ${missingInDocs.join(', ')}',
    );
  }
  if (staleInDocs.isNotEmpty) {
    stderr.writeln(
      'Stale in AGENTS.md core map (not in lib/core): ${staleInDocs.join(', ')}',
    );
  }
  exitCode = 1;
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
