import 'dart:io';

import 'package:path/path.dart' as p;

enum DuplicationProfile {
  core('core'),
  smallHelpers('small-helpers'),
  presentation('presentation');

  const DuplicationProfile(this.label);

  final String label;
}

class DuplicationRunner {
  DuplicationRunner({
    required Directory rootDirectory,
    required Future<int> Function(List<String> command) execute,
    StringSink? output,
    StringSink? errorOutput,
  }) : _rootDirectory = rootDirectory,
       _execute = execute,
       _output = output ?? stdout,
       _errorOutput = errorOutput ?? stderr;

  final Directory _rootDirectory;
  final Future<int> Function(List<String> command) _execute;
  final StringSink _output;
  final StringSink _errorOutput;

  Future<int> run(DuplicationProfile profile) async {
    final commands = _commandsFor(profile);
    if (commands == null) return 2;

    _output.writeln('\n==> Duplication (${profile.label})');
    for (final command in commands) {
      final result = await _execute(command);
      if (result != 0) return result;
    }
    return 0;
  }

  Future<int> runDefault() async {
    for (final profile in [
      DuplicationProfile.core,
      DuplicationProfile.smallHelpers,
    ]) {
      final result = await run(profile);
      if (result != 0) return result;
    }
    return 0;
  }

  List<List<String>>? _commandsFor(DuplicationProfile profile) {
    return switch (profile) {
      DuplicationProfile.core => [
        _jscpdCommand(
          paths: const [
            'lib/features',
            'lib/core/foundation',
            'lib/core/runtime',
            'lib/core/infra',
            'lib/navigation',
          ],
          config: '.jscpd.json',
        ),
        _filterCommand(
          report: '.tmp/jscpd-phase1/jscpd-report.json',
          allowlist: 'tool/duplication_allowlist.json',
        ),
      ],
      DuplicationProfile.smallHelpers => [
        _jscpdCommand(
          paths: const [
            'lib/features',
            'lib/core/foundation',
            'lib/core/runtime',
            'lib/navigation',
          ],
          config: '.jscpd.small_helpers.json',
        ),
        _filterCommand(
          profile: 'small_helpers',
          report: '.tmp/jscpd-small-helpers/jscpd-report.json',
          allowlist: 'tool/small_helper_duplication_allowlist.json',
        ),
      ],
      DuplicationProfile.presentation => _presentationCommands(),
    };
  }

  List<String> _jscpdCommand({
    required List<String> paths,
    required String config,
  }) {
    return ['npx', '--yes', 'jscpd', ...paths, '--config', config, '--silent'];
  }

  List<String> _filterCommand({
    String? profile,
    required String report,
    required String allowlist,
  }) {
    return [
      'dart',
      'tool/filter_duplication_report.dart',
      if (profile != null) ...['--profile', profile],
      '--report',
      report,
      '--allowlist',
      allowlist,
    ];
  }

  List<List<String>>? _presentationCommands() {
    final directories = _presentationDirectories();
    if (directories.isEmpty) {
      _errorOutput.writeln(
        'No presentation directories found under lib/features.',
      );
      return null;
    }

    return [
      _jscpdCommand(paths: directories, config: '.jscpd.presentation.json'),
      _filterCommand(
        profile: 'presentation',
        report: '.tmp/jscpd-presentation/jscpd-report.json',
        allowlist: 'tool/presentation_duplication_allowlist.json',
      ),
    ];
  }

  List<String> _presentationDirectories() {
    final featuresDirectory = Directory(
      p.join(_rootDirectory.path, 'lib', 'features'),
    );
    if (!featuresDirectory.existsSync()) return const [];

    try {
      final directories = featuresDirectory
          .listSync(recursive: true)
          .whereType<Directory>()
          .map((directory) => _relativePath(directory.path))
          .where((path) => p.posix.basename(path) == 'presentation')
          .toList();
      directories.sort();
      return directories;
    } on FileSystemException {
      return const [];
    }
  }

  String _relativePath(String path) {
    return p.relative(path, from: _rootDirectory.path).replaceAll(r'\', '/');
  }
}
