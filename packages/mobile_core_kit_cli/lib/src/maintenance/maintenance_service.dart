import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/deadline_command_runner.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/private_artifact.dart';
import 'package:mobile_core_kit_cli/src/task/repository_mutation_lock.dart';
import 'package:path/path.dart' as p;

enum MaintenanceStepId {
  knowledge,
  architecture,
  duplication,
  dependencies,
  codegen,
  harnessHonesty,
}

class MaintenanceStep {
  const MaintenanceStep({
    required this.id,
    required this.title,
    required this.commands,
    this.sandboxedCodegen = false,
  });

  final MaintenanceStepId id;
  final String title;
  final List<List<String>> commands;
  final bool sandboxedCodegen;
}

const maintenanceRegistry = <MaintenanceStep>[
  MaintenanceStep(
    id: MaintenanceStepId.knowledge,
    title: 'Knowledge and plan lifecycle',
    commands: [
      ['dart', 'run', 'mobile_core_kit_cli:mobilekit', 'knowledge', 'verify'],
    ],
  ),
  MaintenanceStep(
    id: MaintenanceStepId.architecture,
    title: 'Architecture and source policy',
    commands: [
      ['dart', 'run', 'mobile_core_kit_cli:mobilekit', 'lint'],
    ],
  ),
  MaintenanceStep(
    id: MaintenanceStepId.duplication,
    title: 'Duplication observations',
    commands: [
      ['dart', 'run', 'mobile_core_kit_cli:mobilekit', 'duplication', 'check'],
    ],
  ),
  MaintenanceStep(
    id: MaintenanceStepId.dependencies,
    title: 'Dependency drift observations',
    commands: [
      ['flutter', 'pub', 'outdated', '--no-dev-dependencies'],
    ],
  ),
  MaintenanceStep(
    id: MaintenanceStepId.codegen,
    title: 'Codegen drift in disposable checkout',
    commands: [],
    sandboxedCodegen: true,
  ),
  MaintenanceStep(
    id: MaintenanceStepId.harnessHonesty,
    title: 'Harness and gate-honesty fixtures',
    commands: [
      ['dart', 'test', 'packages/mobile_core_kit_cli/test'],
      ['dart', 'test', 'packages/mobile_core_kit_lints/test'],
    ],
  ),
];

class MaintenanceStepResult {
  const MaintenanceStepResult({
    required this.id,
    required this.status,
    required this.durationMs,
  });

  final MaintenanceStepId id;
  final String status;
  final int durationMs;

  Map<String, Object?> toJson() => {
    'id': id.name,
    'status': status,
    'durationMs': durationMs,
  };
}

class MaintenanceResult {
  const MaintenanceResult({
    required this.passed,
    required this.reportPath,
    required this.steps,
  });

  final bool passed;
  final String reportPath;
  final List<MaintenanceStepResult> steps;
}

typedef MaintenanceCommandRunner =
    Future<int> Function(
      Directory workingDirectory,
      List<String> command,
      Duration timeout,
    );

class MaintenanceService {
  MaintenanceService({
    required this.root,
    required this.controlRoot,
    required this.runCommand,
    List<MaintenanceStep> steps = maintenanceRegistry,
    RepositoryMutationLock? lock,
    DateTime Function()? now,
  }) : steps = List.unmodifiable(steps),
       lock = lock ?? RepositoryMutationLock(controlRoot),
       now = now ?? DateTime.now;

  final Directory root;
  final Directory controlRoot;
  final MaintenanceCommandRunner runCommand;
  final List<MaintenanceStep> steps;
  final RepositoryMutationLock lock;
  final DateTime Function() now;

  Future<MaintenanceResult> runOnce() {
    return lock.protect(() async {
      final before = await _trackedState();
      final startedAt = now().toUtc();
      final results = <MaintenanceStepResult>[];
      var passed = true;
      for (final step in steps) {
        final stopwatch = Stopwatch()..start();
        var exitCode = 0;
        if (step.sandboxedCodegen) {
          exitCode = await _runCodegenSandbox();
        } else {
          for (final command in step.commands) {
            exitCode = await runCommand(
              root,
              _maintenanceCommand(command),
              const Duration(minutes: 15),
            );
            if (exitCode != 0) break;
          }
        }
        stopwatch.stop();
        if (exitCode != 0) passed = false;
        results.add(
          MaintenanceStepResult(
            id: step.id,
            status: exitCode == 0 ? 'passed' : 'failed',
            durationMs: stopwatch.elapsedMilliseconds,
          ),
        );
      }
      final after = await _trackedState();
      if (before != after) {
        throw const TaskControlError(
          'maintenance.source-mutated',
          'Maintenance changed tracked repository state.',
        );
      }
      final reportPath = '.tmp/mobilekit/maintenance/latest.json';
      final report = <String, Object?>{
        'schemaVersion': 1,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': now().toUtc().toIso8601String(),
        'outcome': passed ? 'passed' : 'failed',
        'steps': results.map((result) => result.toJson()).toList(),
        'observations': _observations(),
      };
      writePrivateFile(
        File(p.join(controlRoot.path, reportPath)),
        '${const JsonEncoder.withIndent('  ').convert(report)}\n',
      );
      return MaintenanceResult(
        passed: passed,
        reportPath: reportPath,
        steps: List.unmodifiable(results),
      );
    });
  }

  Future<int> _runCodegenSandbox() async {
    final sandbox = Directory.systemTemp.createTempSync('mobilekit-codegen-');
    final checkout = Directory(p.join(sandbox.path, 'checkout'));
    try {
      var exitCode = await runCommand(root, [
        'git',
        'clone',
        '--quiet',
        '--shared',
        '--no-checkout',
        root.path,
        checkout.path,
      ], const Duration(minutes: 2));
      if (exitCode != 0) return exitCode;
      exitCode = await runCommand(checkout, [
        'git',
        'checkout',
        '--quiet',
        '--detach',
        'HEAD',
      ], const Duration(minutes: 2));
      if (exitCode != 0) return exitCode;
      Directory(p.join(checkout.path, '.tmp')).createSync(recursive: true);
      return runCommand(
        checkout,
        _sandboxCodegenCommand(),
        const Duration(minutes: 25),
      );
    } finally {
      if (sandbox.existsSync()) sandbox.deleteSync(recursive: true);
    }
  }

  String _sandboxTool(String executable) {
    final relativePath = executable == 'dart'
        ? p.join(
            'bin',
            'cache',
            'dart-sdk',
            'bin',
            Platform.isWindows ? 'dart.exe' : 'dart',
          )
        : p.join('bin', Platform.isWindows ? 'flutter.bat' : 'flutter');
    final pinned = File(p.join(root.path, '.fvm', 'flutter_sdk', relativePath));
    return pinned.existsSync() ? pinned.path : executable;
  }

  List<String> _maintenanceCommand(List<String> command) {
    if (command.first != 'flutter') return command;
    final flutter = _sandboxTool('flutter');
    if (Platform.isWindows) {
      return [
        'powershell.exe',
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'& $args[0] $args[1..($args.Length - 1)]; exit $LASTEXITCODE',
        flutter,
        ...command.skip(1),
      ];
    }
    return [
      '/bin/bash',
      '-c',
      '"\$1" "\${@:2}"',
      'mobilekit-flutter',
      flutter,
      ...command.skip(1),
    ];
  }

  List<String> _sandboxCodegenCommand() {
    final flutter = _sandboxTool('flutter');
    final dart = _sandboxTool('dart');
    if (Platform.isWindows) {
      return [
        'powershell.exe',
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'& $args[0] pub get; '
            r'if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; '
            r'& $args[1] run mobile_core_kit_cli:mobilekit codegen verify; '
            r'exit $LASTEXITCODE',
        flutter,
        dart,
      ];
    }
    return [
      '/bin/bash',
      '-c',
      '"\$1" pub get && "\$2" run '
          'mobile_core_kit_cli:mobilekit codegen verify',
      'mobilekit-codegen',
      flutter,
      dart,
    ];
  }

  Future<String> _trackedState() async {
    final result = await Process.run(
      'git',
      const ['status', '--porcelain=v1', '-z', '--untracked-files=all'],
      workingDirectory: root.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      throw const TaskControlError(
        'maintenance.git-unavailable',
        'Maintenance could not inspect tracked repository state.',
      );
    }
    return result.stdout as String;
  }

  Map<String, Object?> _observations() {
    final activePlans = _v2PlanPaths('active');
    final queuedPlans = _v2PlanPaths('queued');
    final evidence = _runtimeEvidence();
    return {
      'activeV2Plans': activePlans,
      'queuedV2Plans': queuedPlans,
      'runtimeEvidenceCount': evidence.length,
      'staleRuntimeEvidence': evidence
          .where((entry) => entry.stale)
          .map((entry) => entry.path)
          .toList(),
    };
  }

  List<String> _v2PlanPaths(String lifecycle) {
    final directory = Directory(
      p.join(root.path, 'docs', 'exec-plans', lifecycle),
    );
    if (!directory.existsSync()) return const [];
    final result = <String>[];
    for (final file
        in directory.listSync(followLinks: false).whereType<File>()) {
      if (!file.path.endsWith('.md') || file.lengthSync() > 64 * 1024) continue;
      if (!RegExp(
        r'^\*\*Plan version:\*\*\s*2\s*$',
        multiLine: true,
      ).hasMatch(file.readAsStringSync())) {
        continue;
      }
      result.add(_relative(file.path));
    }
    result.sort();
    return result;
  }

  List<_EvidenceObservation> _runtimeEvidence() {
    final directory = Directory(p.join(root.path, '_artifacts', 'mobile'));
    if (!directory.existsSync()) return const [];
    final threshold = now().toUtc().subtract(const Duration(days: 30));
    final result = directory
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => p.basename(file.path) == 'evidence.json')
        .map(
          (file) => _EvidenceObservation(
            path: _relative(file.path),
            stale: file.lastModifiedSync().toUtc().isBefore(threshold),
          ),
        )
        .toList();
    result.sort((left, right) => left.path.compareTo(right.path));
    return result;
  }

  String _relative(String path) =>
      p.relative(path, from: root.path).replaceAll('\\', '/');
}

class _EvidenceObservation {
  const _EvidenceObservation({required this.path, required this.stale});

  final String path;
  final bool stale;
}

MaintenanceCommandRunner maintenanceCommandRunner({
  required StringSink output,
  required StringSink errorOutput,
}) {
  return (workingDirectory, command, timeout) async {
    final runner = DeadlineCommandRunner(
      rootDirectory: workingDirectory,
      deadline: DateTime.now().toUtc().add(timeout),
      output: output,
      errorOutput: errorOutput,
    );
    return runner.run(command);
  };
}
