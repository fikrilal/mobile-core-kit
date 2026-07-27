import 'dart:io';

import 'package:path/path.dart' as p;

class ExecutableFinder {
  ExecutableFinder({Map<String, String>? environment, bool? isWindows})
    : environment = Map.unmodifiable(environment ?? Platform.environment),
      isWindows = isWindows ?? Platform.isWindows;

  final Map<String, String> environment;
  final bool isWindows;

  String? find(String executable) {
    final pathValue = environment['PATH'];
    if (pathValue == null || pathValue.isEmpty) return null;

    final pathSeparator = isWindows ? ';' : ':';
    for (final directory in pathValue.split(pathSeparator)) {
      if (directory.isEmpty) continue;

      for (final candidateName in _candidateNames(executable)) {
        final candidate = File(p.join(directory, candidateName));
        if (candidate.existsSync()) return candidate.path;
      }
    }

    return null;
  }

  List<String> _candidateNames(String executable) {
    if (!isWindows) return [executable];
    return [
      executable,
      '$executable.exe',
      '$executable.bat',
      '$executable.cmd',
    ];
  }
}
