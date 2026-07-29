import 'dart:io';

import 'package:mobile_core_kit_cli/src/duplication/duplication_report_filter.dart';
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
    final command = _jscpdCommandFor(profile);
    if (command == null) return 2;

    final filter = _filterSpecFor(profile);
    _output.writeln('\n==> Duplication (${profile.label})');

    final result = await _execute(command);
    if (result != 0) return result;

    try {
      return DuplicationReportFilter(
        rootDirectory: _rootDirectory,
        output: _output,
        errorOutput: _errorOutput,
      ).run(
        profileName: filter.profile,
        reportPath: filter.report,
        allowlistPath: filter.allowlist,
      );
    } on FormatException catch (error) {
      _errorOutput.writeln('ERROR: Invalid duplication report data.');
      _errorOutput.writeln(error.message);
      return 2;
    }
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

  List<String>? _jscpdCommandFor(DuplicationProfile profile) {
    return switch (profile) {
      DuplicationProfile.core => _jscpdCommand(
        paths: const [
          'lib/features',
          'lib/core/foundation',
          'lib/core/runtime',
          'lib/core/infra',
          'lib/navigation',
        ],
        config: '.jscpd.json',
      ),
      DuplicationProfile.smallHelpers => _jscpdCommand(
        paths: const [
          'lib/features',
          'lib/core/foundation',
          'lib/core/runtime',
          'lib/navigation',
        ],
        config: '.jscpd.small_helpers.json',
      ),
      DuplicationProfile.presentation => _presentationJscpdCommand(),
    };
  }

  _FilterSpec _filterSpecFor(DuplicationProfile profile) {
    return switch (profile) {
      DuplicationProfile.core => const _FilterSpec(
        profile: 'core',
        report: '.tmp/jscpd-phase1/jscpd-report.json',
        allowlist: 'duplication/duplication_allowlist.json',
      ),
      DuplicationProfile.smallHelpers => const _FilterSpec(
        profile: 'small_helpers',
        report: '.tmp/jscpd-small-helpers/jscpd-report.json',
        allowlist: 'duplication/small_helper_duplication_allowlist.json',
      ),
      DuplicationProfile.presentation => const _FilterSpec(
        profile: 'presentation',
        report: '.tmp/jscpd-presentation/jscpd-report.json',
        allowlist: 'duplication/presentation_duplication_allowlist.json',
      ),
    };
  }

  List<String> _jscpdCommand({
    required List<String> paths,
    required String config,
  }) {
    return ['npx', '--yes', 'jscpd', ...paths, '--config', config, '--silent'];
  }

  List<String>? _presentationJscpdCommand() {
    final directories = _presentationDirectories();
    if (directories.isEmpty) {
      _errorOutput.writeln(
        'No presentation directories found under lib/features.',
      );
      return null;
    }

    return _jscpdCommand(
      paths: directories,
      config: '.jscpd.presentation.json',
    );
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
    return p.relative(path, from: _rootDirectory.path).replaceAll(r'\\', '/');
  }
}

class _FilterSpec {
  const _FilterSpec({
    required this.profile,
    required this.report,
    required this.allowlist,
  });

  final String profile;
  final String report;
  final String allowlist;
}
