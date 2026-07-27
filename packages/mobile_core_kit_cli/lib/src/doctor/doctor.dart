import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';
import 'package:path/path.dart' as p;

enum DoctorCheckStatus {
  ok,
  warning,
  error;

  String get label => switch (this) {
    DoctorCheckStatus.ok => 'OK',
    DoctorCheckStatus.warning => 'WARN',
    DoctorCheckStatus.error => 'ERROR',
  };
}

class DoctorCheck {
  const DoctorCheck({
    required this.label,
    required this.status,
    required this.detail,
  });

  final String label;
  final DoctorCheckStatus status;
  final String detail;
}

class DoctorReport {
  const DoctorReport({required this.repositoryPath, required this.checks});

  final String? repositoryPath;
  final List<DoctorCheck> checks;

  bool get hasErrors =>
      checks.any((check) => check.status == DoctorCheckStatus.error);

  void writeTo(StringSink output) {
    output.writeln('mobilekit doctor');
    output.writeln('Repository: ${repositoryPath ?? 'not found'}');

    for (final check in checks) {
      output.writeln(
        '- [${check.status.label}] ${check.label}: ${check.detail}',
      );
    }

    output.writeln();
    output.writeln(
      hasErrors ? 'Doctor found problems.' : 'Doctor checks passed.',
    );
  }
}

class Doctor {
  Doctor({
    RepositoryRootLocator? rootLocator,
    ExecutableFinder? executableFinder,
    CommandPlatform? platform,
  }) : _rootLocator = rootLocator ?? const RepositoryRootLocator(),
       _executableFinder = executableFinder ?? ExecutableFinder(),
       _platform = platform ?? CommandPlatform.host();

  final RepositoryRootLocator _rootLocator;
  final ExecutableFinder _executableFinder;
  final CommandPlatform _platform;

  DoctorReport inspect({Directory? startDirectory}) {
    final root = _rootLocator.find(startDirectory: startDirectory);
    if (root == null) {
      return const DoctorReport(
        repositoryPath: null,
        checks: [
          DoctorCheck(
            label: 'repository root',
            status: DoctorCheckStatus.error,
            detail: 'Run this command from inside the repository.',
          ),
        ],
      );
    }

    final checks = <DoctorCheck>[
      DoctorCheck(
        label: 'repository root',
        status: DoctorCheckStatus.ok,
        detail: root.path,
      ),
      _fvmrcCheck(root),
    ];

    final commandRunner = CommandRunner(
      rootDirectory: root,
      platform: _platform,
    );
    for (final executable in ['dart', 'flutter']) {
      checks.add(_sdkCommandCheck(executable, commandRunner));
    }
    for (final executable in ['git', 'npx']) {
      checks.add(_pathCommandCheck(executable));
    }

    return DoctorReport(repositoryPath: root.path, checks: checks);
  }

  DoctorCheck _fvmrcCheck(Directory root) {
    final file = File(p.join(root.path, '.fvmrc'));
    if (!file.existsSync()) {
      return const DoctorCheck(
        label: '.fvmrc',
        status: DoctorCheckStatus.warning,
        detail: 'Pinned Flutter version file is missing.',
      );
    }

    try {
      final decoded = jsonDecode(file.readAsStringSync());
      final version = decoded is Map ? decoded['flutter'] : null;
      if (version is String && version.trim().isNotEmpty) {
        return DoctorCheck(
          label: '.fvmrc',
          status: DoctorCheckStatus.ok,
          detail: 'Flutter ${version.trim()}',
        );
      }
    } on FormatException {
      // Fall through to the warning below.
    }

    return const DoctorCheck(
      label: '.fvmrc',
      status: DoctorCheckStatus.warning,
      detail: 'Flutter version could not be read.',
    );
  }

  DoctorCheck _sdkCommandCheck(String executable, CommandRunner commandRunner) {
    final resolved = commandRunner.resolve(executable);
    if (resolved.isPinned) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.ok,
        detail: 'Pinned SDK: ${resolved.executable}',
      );
    }

    final pathExecutable = _executableFinder.find(executable);
    if (pathExecutable != null) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.warning,
        detail: 'Using PATH fallback: $pathExecutable',
      );
    }

    return DoctorCheck(
      label: executable,
      status: DoctorCheckStatus.error,
      detail: 'Not found in the pinned SDK or PATH.',
    );
  }

  DoctorCheck _pathCommandCheck(String executable) {
    final resolved = _executableFinder.find(executable);
    if (resolved != null) {
      return DoctorCheck(
        label: executable,
        status: DoctorCheckStatus.ok,
        detail: resolved,
      );
    }

    return DoctorCheck(
      label: executable,
      status: DoctorCheckStatus.error,
      detail: 'Not found in PATH.',
    );
  }
}
